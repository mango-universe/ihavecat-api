# frozen_string_literal: true

Swagger::Docs::Config.base_api_controller = ActionController::API
Swagger::Docs::Config.register_apis({
    "1.0" => {
        # :api_file_path => "public",
        :api_file_path => "public/swagger",
        :base_path => ENV["SWAGGER_URL"],
        :clean_directory => true,
        :formatting => :pretty,
        :camelize_model_properties => false,
        :attributes => {
            :info => {
                "title" => "Ihavecat API",
                "description" => "Ihavecat API",
                "version" => "1.0.0",
                "contact" => "hyogol@hotmail.com",
                "license" => "Apache 2.0",
                "licenseUrl" => "http://api.apache.org/licenses/LICENSE-2.0.html"
            }
        }
    }
  })
