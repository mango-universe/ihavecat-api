# frozen_string_literal: true

require 'digest'
class BaseApiController < ActionController::API
  # include ForceDbWriterRole
  # around_action :force_writer_db_role unless Rails.env.production? || Rails.env.stage?

  include AbstractController::Translation
  include Pundit

  before_action :set_locale

  respond_to :json

  rescue_from ApiExceptions::BaseException, :with => :render_base_exception_response
  rescue_from ApiExceptions::CustomException, :with => :render_custom_exception_response
  rescue_from ActiveModel::UnknownAttributeError, with: :not_acceptable
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :not_acceptable
  rescue_from AASM::InvalidTransition, with: :unprocessable_entity
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from RailsParam::Param::InvalidParameterError, with: :not_acceptable

  def self.add_common_params(api)
    api.param :header, 'access-token', :string, :required, 'Authentication token'
  end

  def self.add_common_response(api)
    api.response :forbidden
    api.response :unauthorized
    api.response :not_found
    api.response :not_acceptable
  end

  protected

  def authenticate_user!
    @current_user = User.find_for_database_authentication(email: params.dig(:user, :email))
    raise ApiExceptions::LoginFailed.new unless @current_user
    raise ApiExceptions::LoginFailed.new unless @current_user.valid_password?(params.dig(:user, :password))

    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user = @current_user.decorate
  end

  def authenticate_user_from_token!
    token = request.headers['access-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?

    jwt = JsonWebToken.decode(token)
    jti = jwt.dig('jti')
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'user_agent').eql?(request.headers['user-agent'])

    @current_user = User.find_by(email: jti, access_token: token)
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user

    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user = @current_user.decorate
  end

  def authenticate_user_from_refresh_token!
    token = request.headers['refresh-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?

    jwt = JsonWebToken.decode(token)
    jti = jwt.dig('jti')
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'user_agent').eql?(request.headers['user-agent'])

    @current_user = User.find_by(email: jti, refresh_token: token)
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user

    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user = @current_user.decorate
  end

  def check_admin
    raise ApiExceptions::CustomException.new(:forbidden,t('common.messages.partner.not_found_user')) unless @current_user.admin?
  end

  def user_not_authorized(exception)
    render json: {
      meta: meta_status(
        result: 'error',
        code: -1,
        alert_type: 1,
        result_msg: t("#{exception.policy.class.to_s.underscore}.#{exception.query}", scope: "pundit", default: :default)
      )
    }, status: :forbidden
  end

  def check_api_authorized!
    authenticate_user_from_token!
    check_permission
    check_uuid
  end

  def check_api_authorized_with_meta!
    check_api_authorized!
    set_meta
  end

  # def requires!(name, opts = {})
  #   opts[:require] = true
  #   optional!(name, opts)
  # end

  def optional!(name, opts = {})
    raise ActionController::ParameterMissing, name if opts[:require] && !params.key?(name)

    if opts[:values] && params.key?(name)
      values = opts[:values].to_a
      raise ParameterValueNotAllowed.new(name, opts[:values]) if !values.include?(params[name]) && !values.include?(params[name].to_i)
    end

    params[name] ||= opts[:default]
  end

  def valid_json?(json)
    return false unless json.present?
    !!JSON.parse(json)
  rescue JSON::ParserError => _e
    false
  end

  def not_found
    render json: {
      meta: {
        result: 'error', code: -1, alert_type: 1, result_msg: t('common.messages.not_found')
      }
    }, status: :not_found
  end

  def not_acceptable
    render json: {
      meta: {
        result: 'error', code: -1, alert_type: 1, result_msg: t('common.messages.not_acceptable')
      }
    }, status: :not_acceptable
  end

  def authentication_error
    render json: {
      meta: {
        result: 'error', code: -1, alert_type: 1, result_msg: t('common.messages.unauthorized')
      }
    }, status: :unauthorized
  end

  def unprocessable_entity
    render json: {
      meta: {
        result: 'error', code: -1, alert_type: 1, result_msg: t('common.messages.unprocessable_entity')
      }
    }, status: :unprocessable_entity
  end

  def get_page_info(object)
    return nil unless (object && object.respond_to?(:current_page))

    {
        currentPage: object.current_page,
        nextPage: object.next_page == nil ? 0 : object.next_page,
        prevPage: object.prev_page == nil ? 0 : object.prev_page,
        totalPage: object.total_pages == nil ? 0 : object.total_pages,
        totalCount: object.total_count == nil ? 0 : object.total_count
    }
  end

  # without_count 를 사용하기 위한 함수
  def get_page_info_without_count(object)
    return nil unless (object && object.respond_to?(:current_page))

    {
        currentPage: object.current_page,
        nextPage: object.next_page == nil ? 0 : object.next_page,
        prevPage: object.prev_page == nil ? 0 : object.prev_page
    }
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

  def render_base_exception_response(error)
    render json: {
      meta: meta_status(result: error.result, code: error.code, alert_type: error.alert_type, result_msg: error.result_msg)
    }, status: :forbidden
  end

  def render_custom_exception_response(error)
    render json: {
      meta: meta_status(result: error.result, code: error.code, alert_type: error.alert_type, result_msg: error.result_msg)
    }, status: error.status
  end

  def render_response(resource: {}, meta: {})
    meta = meta.merge(meta_status)
    resource = resource.merge({meta: meta})
    render json: resource
  end

  def render_json(resource: {}, meta: {}, include: {})
    meta = meta.merge(meta_status)
    render json: resource, relations: include, meta: meta, adapter: :json
  end

  def meta_status(result: 'ok', code: 0, alert_type: 0, result_msg: '')
    {
      result: result,
      code: code,
      alert_type: alert_type,
      result_msg: result_msg
    }
  end

  def default_meta
    {}
  end

  def set_locale
    ActiveRecord::Base.establish_connection if !ActiveRecord::Base.connected? && (Rails.env.production? || Rails.env.stage?)
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_meta
    @meta = meta_status
  end

  def no_cache_control
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 0
  end

  def pundit_user
    @current_user
  end

end
