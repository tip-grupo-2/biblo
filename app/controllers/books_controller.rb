require 'openlibrary'
class BooksController < ApplicationController

  # Algunos ISBN para probar:
  # 9788478884452
  # 9788498384482
  # 9788498381405


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

    if book_data.nil?
      raise "El libro con isbn " + isbn + " no existe en la base de datos, por favor agregarlo a mano."
    end

    @book = Book.new(isbn: isbn, title: book_data.title, author: book_data.authors.collect {|auth| auth['name']})

    current_user.donate(@book)
    redirect_to @book
  end


  def show
    @book = Book.find(params[:id])
  end

  def index_my_donations
    @books = Book.joins(copies: :user).where('users.id = ?', current_user.id).select('books.id, books.title, books.author, books.isbn')
  end

  def index
    @books = Book.joins(copies: :user).where.not('books.user_id = ?', current_user.id).select('books.id, books.title, books.author, books.isbn')
  end

  def index_my_books
    @books = Book.where('books.user_id = ?', current_user.id)
  end

  def edit
    @book = Book.find(params[:id])
    current_user.rent(@book)

    redirect_to '/books'
  end
end
