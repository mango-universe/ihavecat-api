# frozen_string_literal: true

class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    before_action :set_raven_context
  
    def valid_json?(json)
      return false unless json.present?
      !!JSON.parse(json)
    rescue JSON::ParserError => _e
      false
    end
  
    private
  
    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
  end
  