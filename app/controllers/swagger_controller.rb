# frozen_string_literal: true

class SwaggerController < ActionController::Base
  # before_action :basic_auth!
  http_basic_authenticate_with name: Rails.application.credentials.dig(:swagger, :id), password: Rails.application.credentials.dig(:swagger, :password)

  def index
    render file: Rails.root.join("public", "404"), layout: false, status: "404" and return if Rails.env.production?

    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    render layout: false
  end

  # def api_docs
  #   # @@data = File.read("app/views/swagger/api-docs.json")
  #   @@data = File.read("public/api-docs.json")
  #   render :json => @@data
  # end

  # def api_spec
  #   version = params[:version]
  #   name = params[:api_name]
  #   @@data = File.read("app/views/swagger/api/#{version}/#{name}.json")
  #   render :json => @@data
  # end

  private

  def basic_auth!
    if request.headers['Authorization'].blank?
      headers['WWW-Authenticate'] = "Basic realm=\"Swagger API Docs\""
      render :layout => false, :status => :unauthorized and return
    end
    userAndPassword = decode64_url(request.headers['Authorization'].split(' ')[1])

    if userAndPassword != Rails.application.credentials.dig(:swagger, :id) + ":" + Rails.application.credentials.dig(:swagger, :password)
      headers['WWW-Authenticate'] = "Basic realm=\"Swagger API Docs\""
      render :layout => false, :status => :unauthorized and return
    end
  end

  def decode64_url(str)
    return '' if str.blank?
    # add '=' padding
    str = case str.length % 4
    when 2 then str + '=='
    when 3 then str + '='
    else
      str
    end

    Base64.decode64(str.tr('-_', '+/'))
  end
end
