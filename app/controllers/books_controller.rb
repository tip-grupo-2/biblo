require 'openlibrary'
class BooksController < ApplicationController
  def new
    @book = Book.new
  end

  def create

    #view = Openlibrary::View
    #details = Openlibrary::Details
    #book_view = view.find_by_isbn(isbn)
    #book_details = details.find_by_isbn(isbn)

    data = Openlibrary::Data
    isbn = params[:book][:isbn]
    book_data = data.find_by_isbn(isbn)
    #
    raise "El libro con isbn " + isbn +
              " no existe en la base de datos, por favor agregarlo a mano." if book_data.nil?
    @book = Book.new(isbn: isbn, title: book_data.title, author: book_data.authors.collect {|auth| auth['name']})
    if @book.save
      redirect_to @book
    else
      render 'new'
    end
  end


  def show
    @book = Book.find(params[:id])
  end

  def index
    @books = Book.all
  end
end
