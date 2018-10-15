require 'rails_helper'

describe BooksController do
  let(:new_book) { FactoryBot.create(:book) }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
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
end