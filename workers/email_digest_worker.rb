class EmailDigestWorker
  include Sidekiq::Worker
  def perform(email, access_token, slyp_list, top_slyp)
    binding.pry
    # @slyps = slyp_list
    # @main_slyp = top_slyp
    @link = [API_DOMAIN, '/v1/users/auth?email=', CGI.escape(email), '&access_token=', access_token].join('')

    subject = "Slyp Daily Digest"
    template = ERB.new(File.read('views/mailers/email_digest.html.erb')).result(binding)

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