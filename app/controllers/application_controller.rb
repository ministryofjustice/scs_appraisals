class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :ensure_user
  before_action :check_review_period_is_open
  before_action :tell_browser_not_to_cache

private

  def tell_browser_not_to_cache
    response.headers["Last-Modified"] = Time.now.httpdate
    response.headers["Expires"] = '0'
    # HTTP 1.0
    response.headers["Pragma"] = "no-cache"
    # HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
    response.headers["Cache-Control"] = %w[
      no-store no-cache must-revalidate max-age=0
      pre-check=0 post-check=0
    ].join(', ')
  end

  def scoped_by_subject?
    params[:user_id].present?
  end
  helper_method :scoped_by_subject?

  def load_scoped_subject
    if scoped_by_subject?
      @subject = current_user.direct_reports.find(params[:user_id])
    end
    true
  end

  def show_tabs
    @show_tabs = true
  end

  def show_tabs?
    @show_tabs
  end
  helper_method :show_tabs?

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def administrator?
    current_user && current_user.administrator?
  end
  helper_method :administrator?

  def ensure_user
    logged_in? || forbidden
  end

  def forbidden
    render 'shared/forbidden', status: :forbidden, layout: 'error'
    false
  end

  def redirect_to_goal
    goal = session[:goal] || root_path
    session.delete :goal
    redirect_to goal
  end

  def ensure_participant
    forbidden unless current_user.participant
  end

  def review_period_closed?
    ReviewPeriod.closed?
  end
  helper_method :review_period_closed?

  def check_review_period_is_open
    redirect_to results_reviews_path if review_period_closed?
  end

  def i18n_flash(type, partial_key, options = {})
    full_key = [
      'controllers',
      *controller_path.split('/'),
      partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def error(partial_key, options = {})
    i18n_flash :error, partial_key, options
  end

  def notice(partial_key, options = {})
    i18n_flash :notice, partial_key, options
  end
end
