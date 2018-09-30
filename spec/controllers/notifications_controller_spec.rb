require 'rails_helper'

describe NotificationsController do
  let(:book) { FactoryBot.create(:book) }
  let(:requester) { FactoryBot.create(:user) }
  let(:owner) { FactoryBot.create(:user, email: 'juan@gmail.com') }
  #let(:notification) { FactoryBot.create(:notification, recipient_id: owner.id, requester_id: requester.id, copy_id: book.id ) }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = owner
    sign_in @current_user
  end

  describe 'index' do
    it 'gets the last notifications' do
      notification = FactoryBot.create(:notification, recipient_id: owner.id, requester_id: requester.id, copy_id: book.id )
      params = {user: owner.id}
      get :index, params
      expected_response = [{ 'id' => notification.id, 'requester' => notification.requester.email,
                             'book_title' => notification.copy.title, 'action' => notification.action,
                             'read_at' => notification.read_at }]
      expect(JSON(response.body)).to eq(expected_response)
    end
  end

  describe 'mark_as_read' do
    it 'marks as read the visualized notifications' do
      notification = FactoryBot.create(:notification, recipient_id: owner.id, requester_id: requester.id, copy_id: book.id )
      post :mark_as_read, {ids: notification.id}
      expect(Notification.find(notification.id).read_at).not_to eq(nil)
      ok_msg = 'Notificaciones marcadas como leidas.'
      expect_json_response(ok_msg ,200)
    end
  end

  def expect_json_response(msg, status)
    body = JSON(response.body)
    expect(body['msg']).to eq msg
    expect(response.status).to eq status
  end

end