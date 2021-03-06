require 'rails_helper'

feature 'Navigating between sections of the site' do
  context 'As a middle-ranking person' do
    let(:me) { create(:user, name: "Bob", manager: create(:user)) }
    let!(:direct_report) { create(:user, name: "Charlie", manager: me) }
    let(:token) { me.tokens.create }

    context 'During the review period' do
      before do
        open_review_period
      end

      scenario 'Visiting dashboard with no reviews' do
        # /reviews

        visit token_url(token)

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
        expect_page_subheader 'Feedback participants'
      end

      scenario 'Visiting dashboard with reviews' do
        # /reviews

        create :review, subject: me
        visit token_url(token)

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
      end

      scenario 'Viewing a review I have received' do
        # /reviews/[n]

        create :submitted_review, subject: me, author_name: 'Momotaro'
        visit token_url(token)
        click_link 'View feedback'

        expect_back_link '/reviews'
        expect_page_header 'Feedback for you'
        expect_no_tabs
        expect_page_subheader 'Given by Momotaro'
      end

      scenario 'Visiting dashboard for direct reports' do
        # /users

        visit token_url(token)
        click_link 'Manage feedback'

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
      end

      scenario 'Viewing direct report with no reviews' do
        # /users/[n]/reviews

        visit token_url(token)
        click_link 'Manage feedback'
        click_link 'Charlie'

        expect_back_link '/users'
        expect_page_header 'Feedback for Charlie'
        expect_no_tabs
        expect_page_subheader 'Feedback participants'
      end

      scenario 'Viewing direct report with reviews' do
        # /users/[n]/reviews

        create :submitted_review, subject: direct_report, author_name: 'Momotaro'
        visit token_url(token)
        click_link 'Manage feedback'
        click_link 'Charlie'

        expect_back_link '/users'
        expect_page_header 'Feedback for Charlie'
        expect_no_tabs
      end

      scenario 'Viewing a review a direct report has received' do
        # /users/[n]/reviews/[m]

        create :submitted_review, subject: direct_report, author_name: 'Momotaro'
        visit token_url(token)
        click_link 'Manage feedback'
        click_link 'Charlie'
        click_link 'View feedback'

        expect_back_link '/users'
        expect_back_link "/users/#{direct_report.to_param}/reviews"
        expect_page_header 'Feedback for Charlie'
        expect_no_tabs
        expect_page_subheader 'Given by Momotaro'
      end

      scenario 'Viewing my feedback requests' do
        # /replies

        create :review, author_email: me.email
        visit token_url(token)
        click_link 'Give feedback'

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
      end

      scenario 'Submitting feedback' do
        # /submissions/[n]/edit

        create :accepted_review,
          author_email: me.email,
          subject: direct_report
        visit token_url(token)
        click_link 'Give feedback'
        click_link 'Add feedback'

        expect_back_link '/replies'
        expect_page_header 'Feedback for Charlie'
        expect_no_tabs
      end

      scenario "Viewing an info page in a new window" do
        create :accepted_review,
          author_email: me.email,
          subject: direct_report
        visit token_url(token)
        click_link 'Give feedback'
        click_link 'Add feedback'
        click_link 'Leadership Model'

        expect_page_header 'The Leadership Model'
        expect_no_tabs
        expect_no_back_link
      end

      scenario 'Viewing feedback I gave' do
        # /reviews/[n]

        create :submitted_review,
          author_email: me.email,
          subject: direct_report
        visit token_url(token)
        click_link 'Give feedback'
        click_link 'View feedback'

        expect_back_link '/replies'
        expect_page_header 'Feedback for Charlie'
        expect_no_tabs
        expect_page_subheader 'Given by you'
      end
    end

    context 'After the end of the review period' do
      before do
        close_review_period
      end

      scenario 'Viewing reviews I have received' do
        # /results/reviews

        create :submitted_review, subject: me, author_name: 'Momotaro'
        visit token_url(token)

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
        expect_page_subheader 'All your feedback'
      end

      scenario 'Visiting dashboard for direct reports' do
        # /results/users

        visit token_url(token)
        click_link 'Manage feedback'

        expect_no_back_link
        expect_no_page_header
        expect_introductory_text
        expect_tabs
        expect_page_subheader 'Feedback for your direct reports'
      end

      scenario 'Viewing reviews for a direct report' do
        # /results/users/[n]/reviews

        create :submitted_review, subject: direct_report, author_name: 'Momotaro'
        visit token_url(token)
        click_link 'Manage feedback'
        click_link 'Charlie'

        expect_back_link '/results/users'
        expect_page_header 'All feedback for Charlie'
        expect_no_tabs
      end
    end
  end

  def expect_back_link(path)
    expect(page).to have_css(".top-left a[href$='#{path}']")
  end

  def expect_no_back_link
    expect(page).not_to have_css(".top-left a")
    expect(page).not_to have_selector('a', text: 'Back')
  end

  def expect_no_page_header
    expect(page).not_to have_selector('h1')
  end

  def expect_introductory_text
    expect(page).to have_selector('p', 'Welcome to the SCS 360° Appraisals')
  end

  def expect_page_header(text)
    expect(page).to have_selector('h1', text: text)
  end

  def expect_page_subheader(text)
    expect(page).to have_selector('h2', text: text)
  end

  def expect_tabs
    expect(page).to have_selector('ul#tab_navigation li a')
  end

  def expect_no_tabs
    expect(page).not_to have_selector('ul#tab_navigation')
  end
end
