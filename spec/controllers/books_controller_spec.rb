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
      let(:new_copy) { FactoryBot.create(:copy, user: FactoryBot.create(:user)) }
      let(:requested_copy) { FactoryBot.create(:copy, requested: true, user: FactoryBot.create(:user)) }
      it 'gets redirected and a success message is shown' do
        get :edit, id: new_copy.id
        expect(response).to redirect_to('/books')
        expect(flash[:success]).to match('Tu solicitud de prestamo fue enviada satisfactoriamente!')
      end
      it 'gets redirected and a error message is shown' do
        get :edit, id: requested_copy.id
        expect(response).to redirect_to('/books')
        expect(flash[:danger]).to match('Oops! Lo sentimos, la copia del libro fue solicitada por otro usuario.')
      end
    end
  end

  describe 'mark_as_private' do
    let(:copy) { FactoryBot.create(:copy, book: new_book, user_id: @current_user.id, original_owner_id: @current_user.id) }
    let(:private_copy) { FactoryBot.create(:copy, book: new_book, user_id: @current_user.id, original_owner_id: @current_user.id, in_donation: false) }
    let(:lent_copy) { FactoryBot.create(:copy, book: new_book, user_id: FactoryBot.create(:user).id, original_owner_id: @current_user.id, in_donation: false) }
    context 'when a copy changes its privacy from public to private' do
      it 'displays a message and updates the copy to be private' do
        post :mark_as_private, id: copy.id
        expect(flash[:notice]).to match("Restringiste la disponibilidad de tu ejemplar de #{copy.book.title}. Solo será visible en tu colección y desaparecerá de
       los catalogos de prestamo de Biblo.")
        expect(copy.reload.in_donation).to be_falsey
      end
    end
    context 'when a copy changes its privacy from private to public' do
      it 'displays a message and updates the copy to be public' do
        post :mark_as_private, id: private_copy.id
        expect(flash[:notice]).to match("Tu ejemplar de #{copy.book.title} se encuentra disponible para todos los usuarios de Biblo!")
        expect(private_copy.reload.in_donation).to be_truthy
      end
    end
    context 'when a copy tries to change its privacy' do
      it 'but the current user it is no its original owner' do
        post :mark_as_private, id: lent_copy.id
        expect(flash[:notice]).to match('Oops! El libro seleccionado no se encuentra actualmente en tu poder.')
      end
    end
  end

end