class Rate < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :user
  belongs_to :copy
  belongs_to :book

  validates :amount, inclusion: 0..5

  def self.create_for_book(book, current_user, rating, comment)
    Rate.create!(
        owner_id: current_user.id,
        book_id: book.id,
        amount: rating,
        comment: comment
    )
  end
  def self.create_for_copy(copy, current_user, rating, comment)
    Rate.create!(
        owner_id: current_user.id,
        copy_id: copy.id,
        amount: rating,
        comment: comment
    )
  end
  def self.create_for_user(user, current_user, rating, comment)
    Rate.create!(
        owner_id: current_user.id,
        user_id: user.id,
        amount: rating,
        comment: comment
    )
  end



end