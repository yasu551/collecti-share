class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: %i[create failure]

  def create
    user = User.find_or_create_from_auth_hash(request.env["omniauth.auth"])
    if user.present?
      login user
      redirect_to root_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "ログインに失敗しました"
    end
  end

  def failure
    alert = "認証に失敗しました: #{params[:message]}"
    redirect_to root_path, alert:
  end

  def destroy
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
