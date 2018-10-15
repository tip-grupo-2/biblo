# frozen_string_literal: true
require 'open-uri'
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
    @isbn = params[:book][:isbn]
    response = RestClient.get "https://www.googleapis.com/books/v1/volumes?q=isbn:#{@isbn}"
    response_data = JSON.parse(response)
    @book_data = response_data.dig(:items, 0, :volumeInfo)
    raise Book::ISBN_PROVIDER_ERROR if @book_data.nil?
  rescue Book::ISBN_PROVIDER_ERROR
    flash[:notice] = 'No pudimos encontrar ese ISBN en nuestra base de datos'
    redirect_to :back
  end

  def create
    isbn = params[:isbn]
    create_book(isbn)
    redirect_to '/my_books'
  end

  def show
    @book = Book.find(params[:id])
  end

  def index_my_donations
    @copies = Copy.where(original_owner: current_user.id, for_donation: true)
  end

  def index
    filtered_books =  Copy.where('user_id = ? OR requested = ?', current_user, true).pluck(:book_id).uniq
    @books = Book.where.not(id: filtered_books)
  end

  def index_my_books
    @copies = Copy.where(user_id: current_user)
  end

  def edit
    @copy = Copy.find(params[:id])
    Notification.create!(requester_id: current_user.id, recipient_id: @copy.user_id, copy_id: @copy.book.id,
                        action: 'solicitado')
    current_user.request(@copy)
    flash[:success] = 'Tu solicitud de prestamo fue enviada satisfactoriamente!'
    redirect_to '/books'
  rescue Copy::ALREADY_REQUESTED_ERROR
    flash[:danger] = 'Oops! Lo sentimos, la copia del libro fue solicitada por otro usuario.'
    redirect_to '/books'
  end

  private

   def create_book(isbn)
     response = RestClient.get "https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}"
     response_data = JSON.parse(response)
     book_info = response_data['items'][0]['volumeInfo']
     @book = Book.find_by(isbn: isbn)
     unless @book.present?
       @book = Book.create!(isbn: isbn,
                            title: book_info['title'],
                            author: book_info['authors'][0],
                            picture_url: book_info['imageLinks']['thumbnail'],
                            description: book_info['description'],
                            country: book_info['language'])
     end
     current_user.add(@book)
   end
end
