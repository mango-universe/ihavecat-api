# frozen_string_literal: true

module ApiExceptions
  class BaseException < StandardError
    include ActiveModel::Serialization
    attr_reader :code, :result, :alert_type, :result_msg

    ERROR_DESCRIPTION = Proc.new {|alert_type, code, message| {result: 'fail', alert_type: alert_type, code: code, result_msg: message}}

    ERROR_CODE_MAP = {
      "LoginFailed" =>
      ERROR_DESCRIPTION.call(1, 1001, I18n.t('common.messages.sessions.login_failed')),
      "NotAllowDevice" =>
      ERROR_DESCRIPTION.call(1, 1002, I18n.t('common.messages.sessions.not_allow_device')),
      "NotExistLoginPermission" =>
      ERROR_DESCRIPTION.call(1, 1003, I18n.t('common.messages.sessions.not_exist_login_permission')),
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

