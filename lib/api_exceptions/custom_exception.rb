# frozen_string_literal: true

module ApiExceptions
  class CustomException < StandardError
    # include ActiveModel::Serialization
    attr_reader :status, :code, :result, :alertType, :resultMsg

    def initialize(status, msg)
      @status = status
      @code = -1
      @result = 'fail'
      @alertType = 1
      @resultMsg = msg
    end
  end
end
