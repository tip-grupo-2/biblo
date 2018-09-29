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
      it 'gets redirected afterwards' do
        get :edit, id: new_copy.id
        expect(response).to redirect_to('/books')
      end
    end
  end
end