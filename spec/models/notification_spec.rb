require 'rails_helper'

describe Notification do
  describe 'validations' do
    it { should validate_presence_of(:requester) }
    it { should validate_presence_of(:recipient) }
    it { should validate_presence_of(:action) }
  end
end
