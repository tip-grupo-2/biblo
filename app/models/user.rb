class User < ActiveRecord::Base
  has_many :copies

  def donate a_book
    Copy.create(
            book: a_book,
            user: self
    )
  end
end