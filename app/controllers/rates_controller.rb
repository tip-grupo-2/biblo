class RatesController < ApplicationController


  def book_rating
    @book = Book.find(params[:id])
    @ratings = Rate.where(book_id: params[:id]).all

  end
end