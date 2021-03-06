module Admin
  class PasswordResetsController < AdminController
    skip_before_action :ensure_administrator
    before_action :load_identity, only: [:edit, :update]
    before_action :verify_reset_permitted, only: [:edit, :update]

    def new
      @password_reset = PasswordReset.new
    end

    def create
      email = params[:password_reset][:email]
      @password_reset = PasswordReset.new(email: email)
      if @password_reset.save
        PasswordResetMailingJob.perform_later email
        notice :link_sent
        redirect_to new_login_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @identity.update(password_params)
        redirect_to new_login_path
      else
        render :edit
      end
    end

  private

    def load_identity
      @identity = Identity.find_by_password_reset_token(token)
    end

    def verify_reset_permitted
      if @identity.can_reset_password?
        true
      else
        notice :token_expired
        redirect_to new_admin_password_reset_path
      end
    end

    def token
      params[:token] || params[:identity][:password_reset_token]
    end

    def password_params
      params.require(:identity).permit(:password, :password_confirmation)
    end
  end
end
