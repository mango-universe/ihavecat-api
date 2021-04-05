# frozen_string_literal: true

class Api::V1::SessionsController < BaseDeviseController

  swagger_controller :sessions, 'Session Management'

  swagger_api :create do
    summary '로그인'
    notes '로그인 API'
    param :form, :email, :string, :required
    param :form, :password, :string, :required
  end

  swagger_api :destroy do |api|
    summary '로그아웃'
    BaseApiController.add_common_params(api)
    BaseApiController.add_common_response(api)
  end

  before_action :configure_sign_in_params, only: [:create]
  before_action :authenticate_user!, only: [:create]
  after_action :update_current_login_date, only: [:create]
  after_action :update_last_login_date, only: [:destroy]
  before_action :authenticate_user_from_access_token!, only: [:destroy]
  before_action :set_meta

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    param! :email, String, required: true
    param! :password, String, required: true

    @session_dto = SessionDto.new(@current_user)
    @session_service = SessionService.new(@current_user)

    @result_code = 0
    @result_msg = ''

    begin
      @session_service.authorize
    rescue => e
      @error = e
      @result_code = e.respond_to?('code')? e.code : -1
      @result_msg = e.respond_to?('result_msg')? e.result_msg : e.message
    end

    if @error.blank?
      session_success_response
    else
      @meta = meta_status(result: 'fail', code: @result_code, alert_type: 1, result_msg: @result_msg)
      render status: :forbidden
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    added_attrs = [:email, :username, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  def authenticate_user!
    @current_user = User.find_for_database_authentication(email: params[:email])
    raise ApiExceptions::LoginFailed.new unless @current_user
    raise ApiExceptions::LoginFailed.new unless @current_user.valid_password?(params[:password])

    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user = @current_user.decorate
  end

  def update_current_login_date
    @current_user.update!(
      online: true,
      current_sign_in_at: Time.current,
      current_sign_in_ip: @current_user.request_ip,
      sign_in_count: @current_user.sign_in_count+1) unless @error.present?
  end

  def update_last_login_date
    @current_user.update!(
      access_token: '',
      refresh_token: '',
      online: false,
      last_sign_in_at: Time.current,
      last_sign_in_ip: request.ip)
  end

  def session_success_response
    @current_user.generate_tokens
    if @current_user.save
      @session_service.set_dto(@session_dto)
    else
      render status: :not_acceptable
    end
  end
end
