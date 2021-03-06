class FeedbackRequestNotification
  def initialize(review)
    @review = review
  end

  def notify
    token = @review.tokens.create!
    ReviewMailer.feedback_request(@review, token).deliver
  end
end
