# frozen_string_literal: true
class BooksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new
    @book = Book.new
  end

  def preview
    if !params[:book]
      @book = Book.new
      @isbn = params[:isbn]
    else
      @isbn = params[:book][:isbn]
    end
    response_data = getGoogleApiBooks("isbn:#{@isbn}")
    @book_data = response_data.dig('items', 0, 'volumeInfo')
    raise Book::ISBN_LENGTH_ERROR if @isbn.length != 13
    raise Book::ISBN_PROVIDER_ERROR if @book_data.nil?
  rescue Book::ISBN_LENGTH_ERROR
    flash[:notice] = 'El ISBN debe tener 13 números.'
    @book = Book.new
    @book.isbn = @isbn
    render :new and return
  rescue Book::ISBN_PROVIDER_ERROR
    flash[:notice] = 'No pudimos encontrar ese ISBN en nuestra base de datos.'
    enter_manual
  end

  def enter_manual
    @book = Book.new
    @book.isbn = @isbn
    render :manual_new and return
  end

  def preview_title
    @title = params[:book][:title].gsub(/\s/,'+')
    response_data = getGoogleApiBooks(@title)
    @books = response_data['items']
  rescue RestClient::BadRequest
    flash[:notice] = 'Por favor verificá los datos ingresados.'
    redirect_to :back
  end

  def getGoogleApiBooks(queryBy)
    response = RestClient.get "https://www.googleapis.com/books/v1/volumes?q=#{queryBy}"
    response_data = JSON.parse(response)
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
    create_book(params[:book][:isbn], params[:book][:title], params[:book][:author], nil, params[:book][:description], 'ES')
    redirect_to '/my_books'
  end
  def show
    @book = Book.find(params[:id])
  end

  def index
    title = params[:search_title]
    author = params[:search_author]
    donations = Donation
                     .joins("INNER JOIN copies ON copies.id = donations.copy_id
                             INNER JOIN books ON copies.book_id = books.id")
                     .where('books.title LIKE ?', "%#{title}%")
                     .where('books.author LIKE ?', "%#{author}%")
                     .where.not(giver_id: current_user.id)
                     .where(state: :available)
    filtered_donations = filter_by_max_distance(donations, current_user)
    @donations = sort_by_distance(filtered_donations, current_user)
  end

  def index_my_books
    @donations = Donation.joins(:copy)
                     .where("copies.user_id = ?", current_user.id)
                     .where.not(state: 'finished')
                     .where.not(state: 'rejected')
  end
  def index_my_donations
    ids = Donation.select("MIN(id) as id").group(:copy_id).collect(&:id)
    @donations = Donation.joins(:copy).where("copies.original_owner_id = ?", current_user.id).where(id: ids)
  end

  def edit
    @donation = Donation.find(params[:id])
    raise Copy::ALREADY_REQUESTED_ERROR unless @donation.available? || @donation.unavailable?
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
    @donation.make_unavailable!
    @donation.save
    redirect_to :back
  end

  def finish
    @donation = Donation.find(params[:id])
    rating = params[:rating]
    Rate.create_for_book(@donation.copy.book, rating, current_user)
    @donation.make_available!
    @donation.save
    redirect_to :back
  end

  def rate
    @donation = Donation.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def mark_as_private
    donation = Donation.find(params[:id])
    raise Copy::NOT_IN_POSSESSION_ERROR unless donation.copy.current_owner(current_user)
    raise Copy::ALREADY_REQUESTED_ERROR unless donation.available? or donation.rejected?
    if(donation.available?)
      donation.make_unavailable!
    else
      donation.make_available!
    end
    donation.save
    flash[:notice] = mark_as_message(donation.copy.book.title, donation.available?)
    redirect_to :back
  rescue Copy::NOT_IN_POSSESSION_ERROR
    flash[:notice] = "Oops! El libro seleccionado no se encuentra actualmente en tu poder."
    redirect_to :back
  rescue Copy::ALREADY_REQUESTED_ERROR
    flash[:notice] = "Oops! Alguien ha solicitado el prestamo de esta copia. Por favor responde la solicitud antes de
                      restringir su disponibilidad."
    redirect_to :back
  end

  def capture_barcode
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

  def mark_as_message(title, available)
    if available
      "Tu ejemplar de #{title} se encuentra disponible para todos los usuarios de Biblo!"
    else
      "Restringiste la disponibilidad de tu ejemplar de #{title}. Solo será visible en tu colección y desaparecerá de
       los catalogos de prestamo de Biblo."
    end
  end

  def filter_by_max_distance(donations, current_user)
    donations.select do |donation|
      giver = donation.giver
      distance = calculate_distance_between([giver.latitude, giver.longitude],
                                            [current_user.latitude, current_user.longitude])
      distance <= current_user.max_distance
    end
  end

  def sort_by_distance(donations, current_user)
    donations.sort! do |donation_a, donation_b|
      giver_a = donation_a.giver
      giver_b = donation_b.giver
      calculate_distance_between([giver_a.latitude, giver_a.longitude],
                                 [current_user.latitude, current_user.longitude]) <=>
          calculate_distance_between([giver_b.latitude, giver_b.longitude],
                                     [current_user.latitude, current_user.longitude])
    end
  end

  def calculate_distance_between(point_a, point_b)
    Geocoder::Calculations.distance_between(point_a, point_b)
  end
end
