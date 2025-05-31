class User::UserProfilesController < ApplicationController
  before_action :set_user_profile
  before_action :redirect_if_no_user_profile_versions, only: %i[show edit update]

  def show
  end

  def new
    @user_profile_version = @user_profile.user_profile_versions.build
  end

  def create
    @user_profile_version = @user_profile.user_profile_versions.build(user_profile_version_params)
    if @user_profile_version.save
      redirect_to user_profile_path, notice: "ユーザープロフィールを作成しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @user_profile_version = @user_profile.user_profile_versions.build(address: @user_profile.address, phone_number: @user_profile.phone_number)
  end

  def update
    @user_profile_version = @user_profile.user_profile_versions.build(user_profile_version_params)
    if @user_profile_version.save
      redirect_to user_profile_path, notice: "ユーザープロフィールを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    def set_user_profile
      @user_profile = current_user.user_profile
    end

    def user_profile_version_params
      params.expect(user_profile_version: %i[address phone_number])
    end

    def redirect_if_no_user_profile_versions
      unless @user_profile.user_profile_versions.exists?
        redirect_to new_user_profile_path, notice: "ユーザープロフィールを作成してください"
      end
    end
end
