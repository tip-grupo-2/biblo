class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  # :recoverable
  #
  has_many :copies
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :timeoutable, :omniauthable,
         omniauth_providers: [:facebook, :google_oauth2]

  def self.from_omniauth(auth_info)
    User.where(provider: auth_info.provider, uid: auth_info.uid).first_or_create do |user|
      user.provider = auth_info.provider
      user.uid = auth_info.uid
      user.email = auth_info.info.email
    end
  end

  def password_required?
    super && provider.blank?
  end

  def donate a_book
    Copy.create(
            book: a_book,
            user: self
    )
  end
end