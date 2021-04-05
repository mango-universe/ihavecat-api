# frozen_string_literal: true

module ActiveJobRetryControlable
  extend ActiveSupport::Concern

  DEFAULT_RETRY_LIMIT = 5

  attr_reader :attempt_number

  module ClassMethods
    def retry_limit(retry_limit)
      @retry_limit = retry_limit
    end

    def load_retry_limit
      @retry_limit || DEFAULT_RETRY_LIMIT
    end
  end

  def serialize
    super.merge("attempt_number" => (@attempt_number || 0) + 1)
  end

  def deserialize(job_data)
    super
    @attempt_number = job_data["attempt_number"]
  end

  private

  def retry_limit
    self.class.load_retry_limit
  end

  def retry_limit_exceeded?
    @attempt_number > retry_limit
  end
end
