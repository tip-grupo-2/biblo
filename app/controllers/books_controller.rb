# frozen_string_literal: true
class BooksController < ApplicationController
  def new
    @book = Book.new
  end

  def preview
    @isbn = params[:book][:isbn]
    response = RestClient.get "https://www.googleapis.com/books/v1/volumes?q=isbn:#{@isbn}"
    response_data = JSON.parse(response)
    @book_data = response_data.dig('items', 0, 'volumeInfo')
    raise Book::ISBN_LENGTH_ERROR if @isbn.length != 13
    raise Book::ISBN_PROVIDER_ERROR if @book_data.nil?
  rescue Book::ISBN_LENGTH_ERROR
    flash[:notice] = 'El ISBN debe tener 13 numeros'
    @book = Book.new
    @book.isbn = @isbn
    render :new and return
  rescue Book::ISBN_PROVIDER_ERROR
    flash[:notice] = 'No pudimos encontrar ese ISBN en nuestra base de datos'
    enter_manual
  end

  def enter_manual
    @book = Book.new
    @book.isbn = @isbn
    render :manual_new and return
  end

  def preview_title
    @title = params[:book][:title].gsub(/\s/,'+')
    response = RestClient.get "https://www.googleapis.com/books/v1/volumes?q=#{@title}"
    response_data = JSON.parse(response)
    @books = response_data['items']
  end

  def create
    isbn = params[:isbn]
    title = params[:title]
    authors = params[:authors]
    picture_url = params[:picture_url]
    description = params[:description]
    country = params[:country]
    create_book(isbn, title, authors, picture_url, description, country)
    redirect_to '/my_books'
  end
  def create_manual
    #TODO: Estos 2 metodos quedaron re parecidos
    # Intente en el metodo create pasar un book con title, author, y isbn desde preview.html, pero no pude
    # Tambien intente no pasar un book en el create manual, desde el form_for y no encontre como hacerlo.
    create_book(params[:book][:isbn], params[:book][:title], params[:book][:author], nil, params[:book][:description], 'ES')
    redirect_to '/my_books'
  end
  def show
    @book = Book.find(params[:id])
  end

  def index

    #TODO: filtrar donaciones por distancia maxima.
    title = params[:search_title]
    author = params[:search_author]
    @donations = Donation
                     .joins("INNER JOIN copies ON copies.id = donations.copy_id
                             INNER JOIN books ON copies.book_id = books.id")
                     .where('books.title LIKE ?', "%#{title}%")
                     .where('books.author LIKE ?', "%#{author}%")
                     .where.not(giver_id: current_user.id)
                     .where(state: :donated)
                     .near(current_user.address, current_user.max_distance, units: :km).reorder('distance DESC')
  end

  def index_my_books
    @donations = Donation.joins(:copy).where("copies.user_id = ?", current_user.id)
  end
  def index_my_donations
    @donations = Donation.joins(:copy).where("copies.original_owner_id = ?", current_user.id)
    #@copies = Copy.where(original_owner: current_user.id)
  end

  def edit
    @donation = Donation.find(params[:id])
    raise Copy::ALREADY_REQUESTED_ERROR unless @donation.donated? || @donation.locked?
    #request = BookRequest.new(requester_id: current_user.id, recipient_id: @copy.user_id, copy_id: @copy.id)
    @donation.request(current_user)
    ActiveRecord::Base.transaction do
      Notification.create!(requester_id: current_user.id, recipient_id: @donation.giver.id, copy_id: @donation.copy.id,
                           action: 'solicitado', donation: @donation)
      @donation.save
    end
    flash[:success] = 'Tu solicitud de prestamo fue enviada satisfactoriamente!'
    redirect_to '/books'
  rescue Copy::ALREADY_REQUESTED_ERROR
    flash[:danger] = 'Oops! Lo sentimos, la copia del libro fue solicitada por otro usuario.'
    redirect_to '/books'
  end

  def start
    @donation = Donation.find(params[:id])
    @donation.lock
    @donation.save
    redirect_to :back
  end

  def finish
    @donation = Donation.find(params[:id])
    @donation.unlock
    @donation.save
    redirect_to :back
  end

  def mark_as_private
    donation = Donation.find(params[:id])
    raise Copy::NOT_IN_POSSESSION_ERROR unless donation.copy.current_and_original_owner(current_user)
    raise Copy::ALREADY_REQUESTED_ERROR unless donation.donated? or donation.locked?
    if(donation.donated?)
      donation.lock
    else
      donation.unlock
    end
    donation.save
    flash[:notice] = mark_as_message(donation.copy.book.title, donation.donated?)
    redirect_to :back
  rescue Copy::NOT_IN_POSSESSION_ERROR
    flash[:notice] = "Oops! El libro seleccionado no se encuentra actualmente en tu poder."
    redirect_to :back
  rescue Copy::ALREADY_REQUESTED_ERROR
    flash[:notice] = "Oops! Alguien ha solicitado el prestamo de esta copia. Por favor responde la solicitud antes de
                      restringir su disponibilidad"
    redirect_to :back
  end

  private

   def create_book(isbn, title, author, picture_url, description, country)
     @book = Book.find_by_isbn(isbn)
     unless @book
       @book = Book.create!(isbn: isbn,
                            title: title,
                            author: author,
                            picture_url: picture_url,
                            description: description,
                            country: country)
     end
     current_user.add(@book)
   end

  def mark_as_message(title, unlocked)
    if unlocked
      "Tu ejemplar de #{title} se encuentra disponible para todos los usuarios de Biblo!"
    else
      "Restringiste la disponibilidad de tu ejemplar de #{title}. Solo será visible en tu colección y desaparecerá de
       los catalogos de prestamo de Biblo."
    end
  end
end
