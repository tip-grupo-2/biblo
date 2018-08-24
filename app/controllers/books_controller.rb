# just require
require 'openlibrary'

class BooksController < ApplicationController
  def new
  end

  def create
    data = Openlibrary::Data
    book_data = data.find_by_isbn(params[:book][:isbn])

    render plain: book_data.title
  end
end
