class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_user
    user_id = session[:user_id]
    return if user_id.blank?

    @current_user ||= User.find_by(id: user_id)
  end
  helper_method :current_user

  private

    def login(user)
      session[:user_id] = user.id
    end

    def logout
      session.delete(:user_id)
      @current_user = nil
    end

    def authenticate_user!
      if current_user.blank?
        redirect_to root_path, alert: "ログインしてください"
      end
    end
end
