# frozen_string_literal: true

module ApiExceptions
  class BaseException < StandardError
    include ActiveModel::Serialization
    attr_reader :code, :result, :alertType, :resultMsg

    ERROR_DESCRIPTION = Proc.new {|alertType, code, message| {result: 'fail', alertType: alertType, code: code, resultMsg: message}}

    ERROR_CODE_MAP = {
      "LoginFailed" =>
      ERROR_DESCRIPTION.call(1, 1001, I18n.t('common.messages.sessions.login_failed')),
      "NotAllowDevice" =>
      ERROR_DESCRIPTION.call(1, 1002, I18n.t('common.messages.sessions.not_allow_device')),
      "NotExistLoginPermission" =>
      ERROR_DESCRIPTION.call(1, 1003, I18n.t('common.messages.sessions.not_exist_login_permission')),
      "NotStaffMember" =>
      ERROR_DESCRIPTION.call(1, 1004, I18n.t('common.messages.sessions.not_staff_member')),
      "StaffRequested" =>
      ERROR_DESCRIPTION.call(1, 1005, I18n.t('common.messages.sessions.staff_requested')),
      "StaffDenied" =>
      ERROR_DESCRIPTION.call(1, 1006, I18n.t('common.messages.sessions.staff_denied')),
      "StaffStopped" =>
      ERROR_DESCRIPTION.call(1, 1007, I18n.t('common.messages.sessions.staff_stopped')),
      "NotPermittedBusinessLicense" =>
      ERROR_DESCRIPTION.call(1, 1008, I18n.t('common.messages.sessions.not_permitted_business_license')),
      "NotExistBusinessLicense" =>
      ERROR_DESCRIPTION.call(1, 1009, I18n.t('common.messages.sessions.not_exist_business_license')),
      "DuplicatedUuid" =>
      ERROR_DESCRIPTION.call(1, 1010, I18n.t('common.messages.sessions.duplicated_uuid')),
      "DuplicatedUserAgent" =>
      ERROR_DESCRIPTION.call(1, 1011, I18n.t('common.messages.sessions.duplicated_user_agent')),
      "StoreCertificationDenied" =>
      ERROR_DESCRIPTION.call(1, 1012, I18n.t('common.messages.sessions.store_certification_denied')),
      "NotSubmitBusinessLicense" =>
      ERROR_DESCRIPTION.call(1, 1013, I18n.t('common.messages.sessions.not_submit_business_license')),
      "AbusingMember" =>
      ERROR_DESCRIPTION.call(1, 1014, I18n.t('common.messages.sessions.abusing_member')),
      "NotPermittedBusinessLicenseAfterPeriod" =>
      ERROR_DESCRIPTION.call(1, 1015, I18n.t('common.messages.sessions.not_permitted_business_license')),
      "StoreCertificationDeniedAfterPeriod" =>
      ERROR_DESCRIPTION.call(1, 1016, I18n.t('common.messages.sessions.store_certification_denied_after_period')),
    }

    def initialize
      error_type = self.class.name.scan(/ApiExceptions::(.*)/).flatten.first
      ApiExceptions::BaseException::ERROR_CODE_MAP
          .fetch(error_type, {}).each do |attr, value|
        instance_variable_set("@#{attr}".to_sym, value)
      end
    end
  end
end

