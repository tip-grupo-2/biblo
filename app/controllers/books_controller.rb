# frozen_string_literal: true

require 'openlibrary'
class BooksController < ApplicationController
  # Algunos ISBN para probar:
  # 9788478884452
  # 9788498384482
  # 9788498381405

  def new
    @book = Book.new
  end

  def preview
    data = Openlibrary::Data
    @isbn = params[:book][:isbn]
    @book_data = data.find_by_isbn(@isbn)
    raise Book::ISBN_PROVIDER_ERROR if @book_data.nil?
  rescue Book::ISBN_PROVIDER_ERROR
    flash[:notice] = 'No pudimos encontrar ese ISBN en nuestra base de datos'
    redirect_to :back
  end

  def create
    # view = Openlibrary::View
    # details = Openlibrary::Details
    # book_view = view.find_by_isbn(isbn)
    # book_details = details.find_by_isbn(isbn)
    data = Openlibrary::Data
    isbn = params[:isbn]
    book_data = data.find_by_isbn(isbn)
    create_book(book_data, isbn)
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
    @books = Book.where.not(id: filtered_books)
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

  private

   def create_book(book_data, isbn)
     @book = Book.find_by(isbn: isbn)
     unless @book.present?
       book_response = RestClient.get"http://openlibrary.org/api/books?bibkeys=isbn:#{isbn}&format=json&jscmd=details"
       book_details = JSON.parse(book_response)
       details = book_details.dig("isbn:#{isbn}".to_sym, :details, :description, :value)
       @book = Book.create!(isbn: isbn,
                            title: book_data.title,
                            author: book_data.authors.collect { |auth| auth['name'] }.to_sentence,
                            picture_url: book_data.cover['medium'],
                            description: details)
     end
     current_user.donate(@book)
   end
end
