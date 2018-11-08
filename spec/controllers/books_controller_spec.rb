require 'rails_helper'

describe BooksController do
  let(:new_book) { FactoryBot.create(:book, title: 'Demian') }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
    request.env['HTTP_REFERER'] = '/'
  end

  describe 'edit' do
    context 'when a user requests a book' do
      let(:new_user)     { FactoryBot.create(:user)}
      let(:new_copy) { FactoryBot.create(:copy, user: FactoryBot.create(:user)) }
      let(:donation) { FactoryBot.create(:donated_donation, copy: new_copy, giver: new_user)}
      let(:requested_donation) { FactoryBot.create(:requested_donation, copy: new_copy, giver: new_user)}
      it 'gets redirected and a success message is shown' do
        get :edit, id: donation.id
        expect(response).to redirect_to('/books')
        expect(flash[:success]).to match('Tu solicitud de prestamo fue enviada satisfactoriamente!')
      end
      it 'gets redirected and a error message is shown' do
        get :edit, id: requested_donation.id
        expect(response).to redirect_to('/books')
        expect(flash[:danger]).to match('Oops! Lo sentimos, la copia del libro fue solicitada por otro usuario.')
      end
    end
  end

  describe 'mark_as_private' do
    let(:user) { FactoryBot.create(:user)}
    let(:copy) { FactoryBot.create(:copy, book: new_book, user_id: @current_user.id, original_owner_id: @current_user.id) }
    let(:lent_copy) { FactoryBot.create(:copy, book: new_book, user_id: FactoryBot.create(:user).id, original_owner_id: @current_user.id) }

    let(:public_donation) { FactoryBot.create(:donated_donation, copy: copy, giver: user)}
    let(:locked_donation) { FactoryBot.create(:locked_donation, copy: copy, giver: user)}
    let(:lent_donation)   { FactoryBot.create(:donated_donation, copy:lent_copy, giver:user)}

    context 'when a copy changes its privacy from public to private' do
      it 'displays a message and updates the copy to be private' do
        post :mark_as_private, id: public_donation.id
        expect(flash[:notice]).to match("Restringiste la disponibilidad de tu ejemplar de #{copy.book.title}. Solo será visible en tu colección y desaparecerá de
       los catalogos de prestamo de Biblo.")
        expect(public_donation.reload.donated?).to be_falsey
      end
    end
    context 'when a copy changes its privacy from private to public' do
      it 'displays a message and updates the copy to be public' do
        post :mark_as_private, id: locked_donation.id
        expect(flash[:notice]).to match("Tu ejemplar de #{copy.book.title} se encuentra disponible para todos los usuarios de Biblo!")
        expect(locked_donation.reload.donated?).to be_truthy
      end
    end
    context 'when a copy tries to change its privacy' do
      it 'but the current user it is no its original owner' do
        post :mark_as_private, id: lent_donation.id
        expect(flash[:notice]).to match('Oops! El libro seleccionado no se encuentra actualmente en tu poder.')
      end
    end
  end

end