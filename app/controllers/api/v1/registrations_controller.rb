# frozen_string_literal: true

class Api::V1::RegistrationsController < BaseDeviseController

  swagger_controller :registrations, 'Registration Management'

  swagger_api :create do |api|
    summary '회원 가입'
    param :form, "user[email]", :string, :required
    param :form, "user[password]", :string, :required
    param :form, "user[password_confirmation]", :string, :required
    param :form, "user[nickname]", :string, :required
    param :form, "user[username]", :string, :optional
    param :form, "user[avatar]", :string, :optional
    param :form, "user[description]", :string, :optional
    param :form, "user[birth]", :string, :optional
    BaseApiController.add_common_response(api)
  end

  swagger_api :validate_email do |api|
    summary '이메일 중복체크'
    param :form, "email", :string, :required
    BaseApiController.add_common_response(api)
  end

  swagger_api :validate_nickname do |api|
    summary '닉네임 중복체크'
    param :form, "nickname", :string, :required
    BaseApiController.add_common_response(api)
  end

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :set_meta

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    respond_to do |format|
      format.json do
        begin
          @user = User.create!(user_params)
        rescue Exception => e
          render_error :unprocessable_entity, (e.class == ApiExceptions::CustomException ? e.result_msg : e.message)
        end
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def validate_email
    if User.find_by(email: params[:email]).present?
      render_error :unprocessable_entity, I18n.t('common.messages.registrations.duplicate_email')
    else
      render_response
    end
  end

  def validate_nickname
    if User.find_by(nickname: params[:nickname]).present?
      render_error :unprocessable_entity, I18n.t('common.messages.registrations.duplicate_nickname')
    else
      render_response
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :username,
      :nickname,
      :avatar,
      :description,
      :birth
    )
  end
end
