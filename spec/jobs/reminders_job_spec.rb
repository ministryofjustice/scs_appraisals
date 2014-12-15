require 'rails_helper'

RSpec.describe RemindersJob do
  it 'sends feedback-not-received reminders when 8 ≤ days left < 9' do
    user = create(:user)
    create(:no_response_review, subject: user)
    notification = instance_double(FeedbackNotReceivedNotification)

    expect(FeedbackNotReceivedNotification).to receive(:new).with(user).
      and_return(notification)
    expect(notification).to receive(:notify)

    ReviewPeriod.closes_at = 8.5.days.from_now
    described_class.perform_later
  end

  it 'sends no reminders when there are a different number of days left' do
    user = create(:user)
    create(:no_response_review, subject: user)

    expect(FeedbackNotReceivedNotification).not_to receive(:new)

    ReviewPeriod.closes_at = 6.5.days.from_now
    described_class.perform_later
  end

  it 'emails people with feedback to receive only once' do
    user = create(:user)
    2.times do
      create(:no_response_review, subject: user)
    end
    notification = instance_double(FeedbackNotReceivedNotification)

    expect(FeedbackNotReceivedNotification).to receive(:new).once.
      and_return(notification)
    allow(notification).to receive(:notify)

    ReviewPeriod.closes_at =
      (described_class::FEEDBACK_TO_RECEIVE_DAYS + 0.5).days.from_now
    described_class.perform_later
  end
end
