class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :user 
      signin_path
    else
      new_ssm_admin_session_path
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  # def i18n_message
  #   "<html><body><script type='text/javascript'>alert('가입되지 않은 메일 주소이거나, 잘못된 비밀번호입니다.');history.back(-1);</script></body></html>"
  # end
end
