class EmailDigestWorker
  include Sidekiq::Worker
  def perform
    User.all.each do |user|
      @slyps = generate_daily_digest(user)
      # main slyp is the first larger image slyp on the email
      @main_slyp = @slyps.shift
      @link = [API_DOMAIN, '/v1/users/auth?email=', CGI.escape(user.email), '&access_token=', user.access_token].join('')

      subject = "Slyp Daily Digest"
      template = ERB.new(File.read('views/mailers/email_digest.html.erb')).result(binding)

      mail = Mail.deliver do
        from "Slyp <no-reply@slyp.io>"
        to user.email
        subject subject
        html_part do
          content_type 'text/html; charset=UTF-8'
          body template
        end
      end
    end
  end

  def generate_daily_digest(user)
    slyp_list = []
    user.slyps.each do | slyp |
      if slyped_today(slyp) && !slyp.top_image.empty?
        slyp_list << slyp
      end
    end
    return slyp_list.first(5)
  end

  def slyped_today(slyp)
    return true if slyp.created_at > Time.now.beginning_of_day && slyp.created_at < Time.now.end_of_day
    false
  end
end