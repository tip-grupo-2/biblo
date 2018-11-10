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
    state :rejected
    state :delivery_confirmed
    state :reception_confirmed
    state :finished

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
    event :reject, after: :rejectedAction do
      transitions :from => :requested, :to => :rejected
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
    when 'available'            then "Pública"
    when 'unavailable'          then "Privada"
    when 'requested'            then "Donación Solicitada"
    when 'accepted'             then "Donación Aceptada"
    when 'rejected'             then "Donación rechazada"
    when 'delivery_confirmed'   then "Entrega confirmada"
    when 'reception_confirmed'  then "Recepción confirmada"
    when 'finished'             then "Donación finalizada"
    else
      raise "Incorrect donation state"
    end
  end

  def rejectedAction
    Donation.create!(
        requester_id: nil,
        giver_id: giver_id,
        copy_id: copy_id,
        address: address,
        latitude: latitude,
        longitude: longitude
    )
  end

end