# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  def valid_json?(json)
    return false unless json.present?
    !!JSON.parse(json)
  rescue JSON::ParserError => _e
    false
  end

  private

end
