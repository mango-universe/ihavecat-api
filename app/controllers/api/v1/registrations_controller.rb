# frozen_string_literal: true

class Api::V1::RegistrationsController < Devise::RegistrationsController

  swagger_controller :registratinos, 'Registration Management'

  swagger_api :create do |api|
    summary '회원 가입'
    param :form, "email", :string, :required
    param :form, "password", :string, :required
    param :form, "password_confirmation", :string, :required
    param :form, "nickname", :string, :required
    param :form, "username", :string, :optional
    param :form, "avatar", :string, :optional
    param :form, "description", :string, :optional
    param :form, "birth", :string, :optional
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

  def set_meta
    @meta = meta_status
  end

  def meta_status(result: 'ok', code: 0, alert_type: 0, result_msg: '')
    {
      result: result,
      alert_type: alert_type,
      result_msg: result_msg
    }
  end

  def render_response(resource: {}, meta: {})
    meta = meta.merge(meta_status)
    resource = resource.merge({meta: meta})
    render json: resource
  end

  def render_error(status, message, data = nil)
    message = message.full_messages.first if message.respond_to?('full_messages')
    response = {
      result: 'fail',
      code: -1,
      alert_type: 1,
      result_msg: message
    }
    response = response.merge(data) if data
    render json: {meta: response}, status: status
  end
end
