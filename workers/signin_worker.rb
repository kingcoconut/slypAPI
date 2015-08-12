class SigninWorker
  include Sidekiq::Worker
  def perform(email, access_token)
    mail = Mail.deliver do
      from "Slyp <no-reply@slyp.io>"
      to email
      subject "Slyp Signin"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body "Click this <a href='#{API_DOMAIN}/v1/users/auth?email=#{CGI.escape(email)}&access_token=#{access_token}'>link</a> to sign in."
      end
    end
  end
end