
class SessionDto
  attr_accessor :email,
                :nickname,
                :username,
                :access_token,
                :refresh_token,
                :admin,
                :avatar

  def initialize(current_user)
    @email = current_user.email
    @nickname = current_user.nickname
    @username = current_user.username
    @access_token = current_user.access_token
    @refresh_token = current_user.refresh_token
    @admin = current_user.admin
    @avatar = current_user.avatar
  end
end
