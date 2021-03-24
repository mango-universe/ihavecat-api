# frozen_string_literal: true

# api version management
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(request)
    @default || request.headers.fetch(:accept).include?("application/vnd.api+json; version=#{@version}")
  end
end
