class Donation < ActiveRecord::Base
  include AASM
  belongs_to :giver, class_name: User           #El donante de la copia
  has_one :requester, class_name: User    #El que pidio la copia
  has_one :copy                           #La copia donada
  assm column: 'state' do
    state :donated, initial: true
    state :requested
    state :accepted
    state :delivery_confirmed
    state :receive_confirmed
    state :finished

    event :request, after: :set_requester do
      transitions from: [:donated], to: :requested
    end
    event :accept do
      transitions from: [:requested], to: :accepted
    end
    event :reject do
      transitions from: [:requested, :accepted], to: :donated
    end
    event :confirm_delivery do
      transitions from: [:receive_confirmed], to: :finished
      transitions from: [:accepted], to: :delivery_confirmed
    end
    event :confirm_receive do
      transitions from: [:delivery_confirmed], to: :finished
      transitions from: [:accepted], to: :receive_confirmed
    end
  end

  def set_requester(requester)
    self.requester = requester
  end



end