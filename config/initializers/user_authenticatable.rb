# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class UserAuthenticatable < Authenticatable
      def valid?
        params.dig(:user, :email).present? && params.dig(:user, :password).present?
      end

      def authenticate!
        user = User.find_by(email: email)

        if user && user.valid_password?(password)
          success!(user)
        else
          fail!("<html><body><script type='text/javascript'>alert('가입되지 않은 유저 아이디이거나, 잘못된 비밀번호입니다.');history.back(-1);</script></body></html>")
        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

    end
  end
end

Warden::Strategies.add(:user_authenticatable, Devise::Strategies::UserAuthenticatable)
