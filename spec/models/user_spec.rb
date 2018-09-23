# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:new_user) { FactoryBot.create(:user) }
  let(:new_book) { FactoryBot.create(:book) }
  subject { new_user.donate new_book }

  describe 'donate' do
    context 'when a user donates a book' do
      it 'a new copy of that book is added to its stack' do
        subject

        expect(Copy.find_by(user: new_user)).to eq(new_user.copies.first)
        expect(new_book.copies.count).to eq(1)
      end
    end
  end
end
