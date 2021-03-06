require 'rails_helper'
RSpec.describe UsersController, type: :controller do
  let(:me) { create(:user) }

  before do
    authenticate_as me
    open_review_period
  end

  describe 'GET index' do
    it 'lists all my direct reports in alphabetical order' do
      user_a = create(:user, manager: me, name: 'Zelda')
      user_b = create(:user, manager: me, name: 'Ada')
      create(:user)
      get :index

      expect(assigns[:users].to_a).to eql([user_b, user_a])
    end
  end
end
