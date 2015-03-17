require 'rails_helper'

feature 'Getting feedback' do
  let(:manager) { create(:user) }
  let(:direct_report) { create(:user, manager: manager) }

  before do
    open_review_period
    ReviewPeriod.closes_at = Time.new(2020, 12, 9, 16, 30)
  end

  def authenticate_as(user)
    token = create(:token, user: user)
    visit token_path(token)
  end

  scenario 'Invite a new person to give my direct report feedback' do
    authenticate_as manager
    clear_emails!

    visit user_reviews_path(direct_report)

    fill_in 'Name', with: 'Bob Reviewer'
    fill_in 'Email address', with: 'bob@example.com'
    select 'Peer', from: 'Working relationship'
    click_button 'Send'

    review = direct_report.reviews.last
    expect(review.author_email).to eql('bob@example.com')

    expect(last_email.subject).to eq('360 feedback request from you')
    expect(last_email.from).to include(direct_report.email)
    expect(last_email.to).to include('bob@example.com')

    expect(current_path).to eq(user_reviews_path(direct_report))
  end

  scenario 'Send a reminder on behalf of my direct report' do
    review = create(:no_response_review, subject: direct_report)

    authenticate_as manager
    clear_emails!

    visit user_reviews_path(direct_report)
    click_button 'Send reminder'

    expect(last_email.subject).to eq('360 feedback request from you')
    expect(last_email.from).to include(direct_report.email)
    expect(last_email.to).to include(review.author_email)

    expect(current_path).to eq(user_reviews_path(direct_report))
  end
end
