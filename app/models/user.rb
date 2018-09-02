class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  # :recoverable
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :timeoutable
end
