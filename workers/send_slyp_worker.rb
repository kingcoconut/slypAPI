class SendSlypWorker
	include Sidekiq::Worker
  def perform(sender_email, email, access_token, domain)
    @sender = sender_email
    @name = email.split('@')[0]
    @link = [API_DOMAIN, '/v1/users/auth?email=', CGI.escape(email), '&access_token=', access_token].join('')
    subject = "Pending Slyp"
    template = ERB.new(File.read('views/mailers/guest_user_slyped.html.erb')).result(binding)
    mail = Mail.deliver do
      from "Slyp <no-reply@slyp.io>"
      to email
      subject subject
      html_part do
        content_type 'text/html; charset=UTF-8'
        body template
      end
    end
  end
end
