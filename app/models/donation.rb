class Donation < ActiveRecord::Base
  include AASM

  belongs_to :giver, class_name: User        #El donante de la copia
  belongs_to :requester, class_name: User    #El que pidio la copia
  belongs_to :copy                           #La copia donada
  has_many :notifications

  aasm(:state) do
    #Los estados posibles de la donacion
    state :available, initial: true
    state :unavailable
    state :requested
    state :accepted
    state :delivery_confirmed
    state :reception_confirmed
    state :finished

    #Como cambiar de un estado a otro:
    # donacion = Donation.new
    # donacion.state # returns available
    #
    # donacion.request(requester_user)
    # donacion.state # returns requested
    #
    # donacion.accept
    # donacion.state # returns accepted
    # donacion.confirm_delivery || donacion.confirm_receive
    # donacion.state # returns delivery_confirmed || receive_confirmed
    # donacion.confirm_delivery || donacion.confirm_receive (el que falte de los 2)
    # donacion.state # returns finished
    #
    # Osea:
    #                                    -> receive_confirmed -> deliver_confirmed v
    # available -> requested -> accepted -x                                           x> finished
    #     ^--------------reject          -> deliver_confirmed -> receive_confirmed ^

    event :make_unavailable do
      transitions :from => :available, :to => :unavailable
    end
    event :make_available do
      transitions :from => :unavailable, :to => :available
    end
    event :request, after: :set_requester do
      transitions :from => :available, :to => :requested
    end
    event :accept do
      transitions :from => :requested, :to => :accepted
    end
    event :reject do
      before do
        self.requester = nil
      end
      transitions :from => :requested, :to => :available
    end
    event :confirm_delivery do
      transitions :from => :reception_confirmed, :to => :finished
      transitions :from => :accepted, :to => :delivery_confirmed
    end
    event :confirm_reception do
      transitions :from => :delivery_confirmed, :to => :finished
      transitions :from => :accepted, :to => :reception_confirmed
    end
  end

  def set_requester(requester)
    self.requester = requester
  end

  def getStateName
    case self.state
    when 'available'            then "Publico"
    when 'unavailable'          then "Privado"
    when 'requested'            then "Pedido"
    when 'accepted'             then "Aceptado"
    when 'delivery_confirmed'   then "Con entrega confirmada"
    when 'reception_confirmed'  then "Con recivo confirmado"
    when 'finished'             then "Donacion finalizada"
    else
      raise "Incorrect donation state"
    end
  end

end