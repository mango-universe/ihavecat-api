module ApiExceptions
  class DuplicatedUuid < ApiExceptions::BaseException
    # attr_reader :userid

    def initialize(userid)
      super()
      @result_msg = @result_msg.gsub('%{userid}', userid)
    end
  end
end
