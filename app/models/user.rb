# frozen_string_literal: true

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  # :recoverable
  #
  has_many :copies # Donaciones
  has_many :books  # Libros que lee
  has_many :notifications, foreign_key: :recipient_id
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :timeoutable, :omniauthable,
         omniauth_providers: %i[facebook google_oauth2]

  validates :name, presence: true

  def self.from_omniauth(auth_info)
    User.where(provider: auth_info.provider, uid: auth_info.uid).first_or_create do |user|
      user.provider = auth_info.provider
      user.uid = auth_info.uid
      user.email = auth_info.info.email
      user.name = auth_info.info.name
      user.address = ''
      user.avatar = auth_info.info.image
    end
  end

  def password_required?
    super && provider.blank?
  end

  def add a_book
    copy = Copy.create(
        book: a_book,
        user: self,
        original_owner: self
    )
    Donation.create(
        giver: self,
        copy: copy,
        address: self.address
    )
    rent a_book
  end

  def receive_donated_copy(a_copy)
    a_copy.update!(user_id: self.id)
    Donation.create!(
        giver: self,
        copy: a_copy,
        address: self.address,
        state: 'unavailable',
    )
    rent a_copy.book
  end

  def rent(a_book)
    a_book.user_id = id
    a_book.save
  end

  def average_rate()
    rates = Rate.where(:user_id => self.id).pluck(:amount)
    average = 0
    if rates.count > 0
      average = rates.sum.to_f / rates.count
    end

    average
  end
end
