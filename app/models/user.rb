# frozen_string_literal: true

class User < ActiveRecord::Base

  geocoded_by :address
  after_validation :geocode
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  # :recoverable
  #
  has_many :copies # Donaciones
  has_many :books  # Libros que lee
  has_many :notifications, foreign_key: :recipient_id
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :timeoutable, :omniauthable,
         omniauth_providers: %i[facebook google_oauth2]

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

  def donate(a_book)
    Copy.create(
      book: a_book,
      user: self,
      original_owner: self
    )
    rent a_book
  end

  def rent(a_book)
    a_book.user_id = id
    a_book.save
  end

  def count_donated_copies_of(a_book)
    Copy.where(book_id: a_book.id, original_owner_id: self.id).count
  end
  def count_reading_copies_of(a_book)
    Copy.where(book_id: a_book.id, user_id: self.id).count
  end

end
