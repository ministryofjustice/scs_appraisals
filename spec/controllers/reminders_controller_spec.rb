require 'rails_helper'
RSpec.describe RemindersController, type: :controller do
  let(:subject) { create(:recipient) }
  let(:review) { create(:review, subject: subject) }

  before do
    open_review_period
  end

  describe 'POST create' do
    context 'with the subject as an authenticated user' do
      before do
        authenticate_as subject
      end

      it 'sends a reminder' do
        notifier = double(FeedbackRequestNotification)
        expect(FeedbackRequestNotification).to receive(:new).
          with(review).and_return(notifier)
        expect(notifier).to receive(:notify)
        post :create, review: { review_id: review.id }
      end

      it 'redirects to the review list' do
        post :create, review: { review_id: review.id }
        expect(response).to redirect_to(reviews_path)
      end

      it 'shows an information message' do
        post :create, review: { review_id: review.id }
        expect(flash[:notice]).to match(/.+reminder.+/)
      end
    end

    context 'with a different authenticated user' do
      before do
        authenticate_as create(:user)
      end

      it 'returns 403 forbidden' do
        post :create, review: { review_id: review.id }
        expect(response).to be_forbidden
      end
    end

    context 'for a direct report' do
      before do
        authenticate_as subject.manager
      end

      it 'sends a reminder' do
        notifier = double(FeedbackRequestNotification)
        expect(FeedbackRequestNotification).to receive(:new).
          with(review).and_return(notifier)
        expect(notifier).to receive(:notify)
        post :create, user_id: subject.id, review: { review_id: review.id }
      end

      it 'redirects to the review list' do
        post :create, user_id: subject.id, review: { review_id: review.id }
        expect(response).to redirect_to(user_reviews_path(subject))
      end

      it 'shows an information message' do
        post :create, user_id: subject.id, review: { review_id: review.id }
        expect(flash[:notice]).to match(/.+reminder.+/)
      end
    end
  end
end
