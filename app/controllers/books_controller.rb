# frozen_string_literal: true

require 'openlibrary'
class BooksController < ApplicationController
  # Algunos ISBN para probar:
  # 9788478884452
  # 9788498384482
  # 9788498381405
  # 9788408057031

  def new
    @book = Book.new
  end

  def preview
    data = Openlibrary::Data
    @isbn = params[:book][:isbn]
    @book_data = data.find_by_isbn(@isbn)
    raise Book::ISBN_LENGTH_ERROR if @isbn.length != 13
    raise Book::ISBN_PROVIDER_ERROR if @book_data.nil?
  rescue Book::ISBN_LENGTH_ERROR
    flash[:notice] = 'El ISBN debe tener 13 numeros'
    @book = Book.new
    @book.isbn = @isbn
    render :new and return
  rescue Book::ISBN_PROVIDER_ERROR
    flash[:notice] = 'No pudimos encontrar ese ISBN en nuestra base de datos'
    @book = Book.new
    @book.isbn = @isbn
    render :manual_new and return
  end



  def create
    create_book(params[:title], params[:authors], params[:isbn])
    redirect_to '/my_books'
  end
  def create_manual
    #TODO: Estos 2 metodos quedaron re parecidos
    # Intente en el metodo create pasar un book con title, author, y isbn desde preview.html, pero no pude
    # Tambien intente no pasar un book en el create manual, desde el form_for y no encontre como hacerlo.
    create_book(params[:book][:title], params[:book][:author], params[:book][:isbn])
    redirect_to '/my_books'
  end
  def show
    @book = Book.find(params[:id])
  end

  def index_my_donations
    my_copies = Copy.where(original_owner: current_user.id).pluck(:book_id).uniq
    @books = Book.find(my_copies)
  end

  def index
    filtered_books =  Copy.where(user_id: current_user).pluck(:book_id).uniq
    @books = []
    Book.where.not(id: filtered_books).each do |book|
      unless(book.copies.count == 1 && book.reading)
        @books.push(book)
      end
    end
  end

  def index_my_books
    my_copies = Copy.where(user_id: current_user).pluck(:book_id).uniq
    @books = Book.find(my_copies)
  end

  def edit
    @book = Copy.find(params[:id])
    Notification.create!(requester_id: current_user.id, recipient_id: @book.user_id, copy_id: @book.book.id,
                        action: 'solicitado')
    current_user.rent(@book)
    redirect_to '/books'
  end

  def start
    @book = Book.find(params[:id])
    @book.reading = true
    @book.save
    redirect_to :back
  end

  def finish
    @book = Book.find(params[:id])
    @book.reading = false
    @book.save
    redirect_to :back
  end

  private

   def create_book(title, authors, isbn)
     @book = Book.find_by(isbn: isbn)
     unless @book.present?
       @book = Book.create!(isbn: isbn, title: title,
                                       author: authors)
     end
     current_user.donate(@book)
   end
end
