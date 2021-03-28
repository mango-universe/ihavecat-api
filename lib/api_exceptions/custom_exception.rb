# frozen_string_literal: true

module ApiExceptions
  class CustomException < StandardError
    # include ActiveModel::Serialization
    attr_reader :status, :code, :result, :alert_type, :result_msg

    def initialize(status, msg)
      @status = status
      @code = -1
      @result = 'fail'
      @alert_type = 1
      @result_msg = msg
    end
  end
end
