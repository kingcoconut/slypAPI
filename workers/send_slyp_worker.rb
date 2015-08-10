class SendSlypWorker
	include Sidekiq::Worker
  def perform(sender_email, email, access_token, domain)
    mail = Mail.deliver do
      from "Slyp <no-reply@slyp.io>"
      to email
      subject sender_email
      html_part do
        content_type 'text/html; charset=UTF-8'
        body "#{sender_email} has sent you a slyp. <a href='#{domain}/v1/users/auth?email=#{CGI.escape(email)}&access_token=#{access_token}'>Come on over and check it out!</a>"
      end
    end
  end
end