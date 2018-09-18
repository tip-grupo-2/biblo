class Copy < ActiveRecord::Base
  #TODO: cambiar nombre de copy a donations
  belongs_to :book
  belongs_to :user
end