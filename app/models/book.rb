# frozen_string_literal: true

class Book < ActiveRecord::Base
  validates :isbn, uniqueness: true, length: { is: 13 }, presence: true
  has_many :copies
  has_one :user # TODO: agregar tabla intermedia para dueño actual
end
