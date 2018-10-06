require 'rails_helper'

describe UsersController do

  let(:user) { FactoryBot.create(:user) }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = user
    sign_in @current_user
  end

  describe 'edit' do
    it 'should render the user edit page' do
      edit_request = { id: user.id }
      get :edit, edit_request

      expect(response).to render_template :edit
    end

    it 'should redirect to home when a user tries to edit another users profile' do
      another_user = FactoryBot.create(:user)
      edit_request = { id: another_user.id}
      get :edit, edit_request

      expect(response).to redirect_to root_path
    end
  end

  describe 'update' do

    it 'should update his information when the user changes it in edit profile' do
      update_request = { id: user.id, user: { name: 'new name', address: 'new address 123', avatar: 'new_avatar.jpg' } }
      patch :update, update_request

      current_user = User.find(user.id)
      expect(current_user.name).to eq update_request[:user][:name]
      expect(current_user.address).to eq update_request[:user][:address]
      expect(current_user.avatar).to eq update_request[:user][:avatar]
    end
  end
end