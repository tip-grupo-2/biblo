class RatesController < ApplicationController
  before_action :authenticate_user!

  def book_rating
    @donation = Donation.find(params[:id])
    @book_ratings = Rate.where(book_id: @donation.copy.book.id).all
    @copy_ratings = Rate.where(copy_id: @donation.copy.id).all
  end

  def user_rating
    @user = User.find(params[:id])
    @user_ratings = Rate.where(user_id: params[:id])
  end
end