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
    api.param :header, 'uuid', :string, :optional, 'device uuid'
  end

  def self.add_common_response(api)
    api.response :forbidden
    api.response :unauthorized
    api.response :not_found
    api.response :not_acceptable
  end

  protected

  def authenticate_nosnos_account!
    nosnos_api_key = Rails.application.credentials.dig(Rails.env.to_sym, :dealibird, :nosnos, :dealibird_api_key)
    request_token = request.headers['access-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless nosnos_api_key.eql?(request_token)
  end

  def authenticate_ssm_account!
    @current_user = User.where("userid = ? and passwd = UPPER(SHA2(?, 256))", params[:user], params[:password])[0]
    raise ApiExceptions::LoginFailed.new unless @current_user

    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user.uuid = params[:uuid]
    @current_user.platform = (request.headers[:platform] || 'WEB')
    @current_user = @current_user.decorate
  end

  def authenticate_user_from_access_token!
    token = request.headers['access-token']

    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?

    jwt = JsonWebToken.decode(token)
    uid = jwt.dig('jti')

    if request.headers['uuid'].present?
      raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'uuid').eql?(request.headers['uuid'])
    else
      raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'user_agent').eql?(request.headers['user-agent'])
    end

    # ActiveRecord::Base.connected_to(role: :writing) do
      if jwt.dig('data', 'uuid').nil?
        @current_user = User.find_by(userid: uid, web_access_token: token)
      else
        @current_user = User.find_by(userid: uid, mobile_access_token: token)
        @current_user.uuid = jwt.dig('data', 'uuid') if @current_user.present?
      end
    # end

    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user
    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user.platform = (request.headers[:platform] || 'WEB')
    @current_user = @current_user.decorate

    NewRelic::Agent.add_custom_attributes({ userid: @current_user.userid })

    # web 플랫폼의 경우 매장 certification 권한 체크
    valid_store_permission
  end

  def authenticate_user_from_refresh_token!
    token = request.headers['refresh-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?

    jwt = JsonWebToken.decode(token)
    uid = jwt.dig('jti')

    if request.headers['uuid'].present?
      raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'uuid').eql?(request.headers['uuid'])
    else
      raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless jwt.dig('data', 'user_agent').eql?(request.headers['user-agent'])
    end

    if jwt.dig('data', 'uuid').nil?
      @current_user = User.find_by(userid: uid, web_refresh_token: token)
    else
      @current_user = User.find_by(userid: uid, mobile_refresh_token: token)
      @current_user.uuid = jwt.dig('data', 'uuid')
    end

    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user
    @current_user.request_ip = request.ip
    @current_user.user_agent = request.user_agent
    @current_user.platform = (request.headers[:platform] || 'WEB')
    @current_user = @current_user.decorate
  end

  def check_permission
    raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_permission_failed')) if @current_user.permission.eql?('Denied')
  end

  def check_order_permission
    raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_order_permission_failed')) if @current_user.ssm_retail_store.blank? || @current_user.ssm_retail_store.orderPermission.eql?('Denied')
  end

  def check_retailer
    raise ApiExceptions::CustomException.new(:forbidden,t('common.messages.partner.not_found_user')) unless @current_user.retailer?
  end

  def check_wholesaler
    raise ApiExceptions::CustomException.new(:forbidden,t('common.messages.partner.not_found_user')) unless @current_user.wholesaler?
  end

  def check_admin
    raise ApiExceptions::CustomException.new(:forbidden,t('common.messages.partner.not_found_user')) unless @current_user.admin?
  end

  def check_sinil
    uid = request.headers['uid']
    token = request.headers['access-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?
    raise ApiExceptions::CustomException.new(:not_found,t('common.messages.sinil.good.not_found_user')) unless uid.eql?('sinil')
    raise ApiExceptions::CustomException.new(:not_found,t('common.messages.sinil.good.invalid_token_response')) unless token.eql?(Rails.application.credentials.dig(Rails.env.to_sym, :sinil_token))

    @current_user = User.find_by(userid: uid, web_access_token: token)
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user

    NewRelic::Agent.add_custom_attributes({ userid: @current_user.userid })
  end

  # 외부 api 연동
  def check_partner
    uid = request.headers['uid']
    token = request.headers['access-token']
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless token.present?
    raise ApiExceptions::CustomException.new(:not_found,t('common.messages.sinil.good.not_found_user')) unless uid.eql?('lovecosme')
    raise ApiExceptions::CustomException.new(:not_found,t('common.messages.sinil.good.invalid_token_response')) unless token.eql?(Rails.application.credentials.dig(Rails.env.to_sym, :partner_token))

    @current_user = User.find_by(userid: 'lovecosme')
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.invalid_token_response')) unless @current_user

    NewRelic::Agent.add_custom_attributes({ userid: @current_user.userid })
  end

  def confirmed_wholesaler
    raise ApiExceptions::CustomException.new(:forbidden,t('common.messages.unauthorized')) unless @current_user.confirmed_wholesaler?
  end

  def check_permission_from_payment_server
    userid = request.headers['userid']
    oauth_token = request.headers['oauth-token']

    raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_permission_failed')) unless userid.eql?('schoice_dome')
    raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.invalid_token_response')) unless oauth_token.eql?('659A1A464BB3AADD26FBF4C0C05446B7214C044978034A80813E180C7F2E0B32')
  end


  def check_dceo_permission
    unless @current_user.jobClass.eql?('DCEO') || @current_user.ssm_staff_registrations&.last&.status.eql?('Confirm')
      raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_permission_failed'))
    end
  end

  def check_uuid
    return unless @current_user.uuid
    ssm_device = SsmDevice.find_by(UUID: @current_user.uuid, permission: ['Confirmed','Admin'])
    raise ApiExceptions::CustomException.new(:unauthorized, t('common.messages.api_not_allow_device')) unless ssm_device
  end

  def user_not_authorized(exception)
    render json: {
      meta: meta_status(
        result: 'error',
        code: -1,
        alertType: 1,
        resultMsg: t("#{exception.policy.class.to_s.underscore}.#{exception.query}", scope: "pundit", default: :default)
      )
    }, status: :forbidden
  end

  def check_api_authorized!
    authenticate_user_from_access_token!
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

  # 사용안함
  # def authenticate_header(token, uid)
  #   response.headers['access-token'] = token
  #   response.headers['uid'] = uid
  #   response.headers['token-type'] = 'Bearer'
  # end

  def valid_json?(json)
    return false unless json.present?
    !!JSON.parse(json)
  rescue JSON::ParserError => _e
    false
  end

  def not_found
    render json: {
      meta: {
        result: 'error', code: -1, alertType: 1, resultMsg: t('common.messages.not_found')
      }
    }, status: :not_found
  end

  def not_acceptable
    render json: {
      meta: {
        result: 'error', code: -1, alertType: 1, resultMsg: t('common.messages.not_acceptable')
      }
    }, status: :not_acceptable
  end

  def authentication_error
    render json: {
      meta: {
        result: 'error', code: -1, alertType: 1, resultMsg: t('common.messages.unauthorized')
      }
    }, status: :unauthorized
  end

  def unprocessable_entity
    render json: {
      meta: {
        result: 'error', code: -1, alertType: 1, resultMsg: t('common.messages.unprocessable_entity')
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
      alertType: 1,
      resultMsg: message
    }
    response = response.merge(data) if data
    render json: {meta: response}, status: status
  end

  def render_base_exception_response(error)
    render json: {
      meta: meta_status(result: error.result, code: error.code, alertType: error.alertType, resultMsg: error.resultMsg)
    }, status: :forbidden
  end

  def render_custom_exception_response(error)
    render json: {
      meta: meta_status(result: error.result, code: error.code, alertType: error.alertType, resultMsg: error.resultMsg)
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

  def meta_status(result: 'ok', code: 0, alertType: 0, resultMsg: '')
    {
      result: result,
      code: code,
      alertType: alertType,
      resultMsg: resultMsg
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

  # 매장 미승인 시 api 사용제한
  def valid_store_permission
    if @current_user.memberPart.eql?('R')
      dday = @current_user.joinDate
      remain_days = ((dday - 7.days.ago) / 1.day).round

      exception_api_array = []
      exception_api_array.push('/api/v1/certs/store')
      exception_api_array.push('/api/v1/keywords/top10_keywords')
      exception_api_array.push('/api/v1/goods/category')
      exception_api_array.push('/api/v1/wholesales/location_list')
      exception_api_array.push('/api/v1/retails')

      exception_api_array.push('/api/v1/session')
      exception_api_array.push('/api/v1/competitors')
      exception_api_array.push('/api/v1/partners/category')

      current_url = request.fullpath.split("?")[0]

      if @current_user.platform.eql?('WEB')
        raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_permission_failed')) if !@current_user.store_confirmed_with_part && !exception_api_array.include?(current_url)
      else
        raise ApiExceptions::CustomException.new(:forbidden, t('common.messages.api_permission_failed')) if remain_days < 0 && !@current_user.store_confirmed_with_part && !exception_api_array.include?(current_url)
      end
    end
  end
end
