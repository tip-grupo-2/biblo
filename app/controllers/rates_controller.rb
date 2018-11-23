class RatesController < ApplicationController


  def book_rating
    @donation = Donation.find(params[:id])
    @book_ratings = Rate.where(book_id: @donation.copy.book.id).all
    @copy_ratings = Rate.where(copy_id: @donation.copy.id).all

  end
end