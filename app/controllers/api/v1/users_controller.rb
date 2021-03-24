class Api::V1::UsersController < BaseApiController
  swagger_controller :users, 'User Management'

  swagger_api :create do |api|
    summary '(도매, 소매 사장,직원) 가입'
    BaseApiController.add_common_params(api)
    param :form, "userid", :string, :required
    param :form, "passwd", :string, :required
    param :form, "name", :string, :required
    param :form, "phone", :string, :required
    param :form, "uuid", :string, :optional
    # param :form, "vendorUUID", :string, :optional
    param :form, "modelName", :string, :optional
    param :form, "osVersion", :string, :optional
    param :form, "appVersion", :string, :optional
    # param :form, "carrierName", :string, :optional
    param :form, "countryCode", :integer, :optional
    # param :form, "networkCode", :integer, :optional
    param :form, "screenWidth", :integer, :optional
    param :form, "screenHeight", :integer, :optional
    param :form, "idnumber", :integer, :required
    param :form, "selectedStoreNumIdx", :integer, :optional, '도매 사장 가입 시 필수'
    param :form, "joinStoreName", :string, :optional, '사장 가입 시 필수'
    param :form, "regiNum", :string, :optional, '사장 가입 시 필수'
    param :form, "tel", :string, :optional, '사장 가입 시 필수'
    param :form, "platform", :string, :required
    param :form, "memberPart", :string, :required, 'W: 도매, R: 소매'
    param :form, "sid", :integer, :optional, '직원 가입 시 필수'
    param :form, "jobClass", :string, :optional, '직원 가입 시 필수'
    param :form, "isOnline", :boolean, :optional
    param :form, "address", :string, :optional
    param :form, "siteName", :string, :optional
    param :form, "siteUrl", :string, :optional
    param :form, "instaUserid", :string, :optional
    param :form, "palId", :integer, :optional, '웹 nice 인증값'
    param :form, "bpalId", :integer, :optional, '웹 사업자 등록 인증값'
    param :form, "os_type", :string, :optional, 'I, A, WEB (IOS, Android, web)'

    BaseApiController.add_common_response(api)
  end

  before_action :check_api_authorized!, except: [:create, :validate_email, :validate_nickname]
  before_action :set_meta

  def create
    @user = User.new(user_params)

    if @user.save!
      render 'show'
    else
      render_error :unprocessable_entity, I18n.t('common.messages.exception.common_error')
    end
  rescue InvalidParameterError => err
    render_error :unprocessable_entity, I18n.t('common.messages.exception.invalid_parameter_error') + " [#{err.message}]"
  rescue Exception => exception
    render_error :unprocessable_entity, exception.try(:resultMsg) || exception.message
  end

  def validate_email
    if User.find_by(email: params[:email]).present?
      render_error :unprocessable_entity, I18n.t('common.messages.exception.duplicate_email')
    else
      render_response
    end
  end

  def validate_nickname
    if User.find_by(nickname: params[:nickname]).present?
      render_error :unprocessable_entity, I18n.t('common.messages.exception.duplicate_nickname')
    else
      render_response
    end
  end

  private

  def user_params
    params.require(:user).permit(:email,
                                 :password,
                                 :username,
                                 :nickname,
                                 :avatar,
                                 :description,
                                 :birth)
  end

end
