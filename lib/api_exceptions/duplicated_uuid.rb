module ApiExceptions
  class DuplicatedUuid < ApiExceptions::BaseException
    # attr_reader :userid

    def initialize(userid)
      super()
      @resultMsg = @resultMsg.gsub('%{userid}', userid)
    end
  end
end
