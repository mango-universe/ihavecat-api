# frozen_string_literal: true
require 'digest'

class SessionService
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def authorize
    # raise ApiExceptions::NotExistLoginPermission.new if !current_user.actived? or current_user.confirmed_at.nil?
  end

  def set_dto(session_dto)
    session_dto.email = current_user.email
    session_dto.nickname = current_user.nickname
    session_dto.username = current_user.username
    session_dto.access_token = current_user.access_token
    session_dto.refresh_token = current_user.refresh_token
    session_dto.admin = current_user.admin
    session_dto.avatar = current_user.avatar
  end

  private

end
