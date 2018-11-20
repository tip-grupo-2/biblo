class Rate < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :user
  belongs_to :copy
  belongs_to :book

  validates :amount, inclusion: 0..5

  def self.create_for_book(book, rating, current_user)
    Rate.create!(
            owner_id: current_user.id,
            book_id: book.id,
            amount: rating
    )
  end

end