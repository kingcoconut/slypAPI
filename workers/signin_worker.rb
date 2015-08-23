class SigninWorker
  include Sidekiq::Worker
  def perform(email, access_token, new_user)
    @name = email.split('@')[0]
    @link = [API_DOMAIN, '/v1/users/auth?email=', CGI.escape(email), '&access_token=', access_token].join('')
    if new_user
      subject = "Welcome to Slyp"
      template = ERB.new(File.read('views/mailers/signup.html.erb')).result(binding)
    else
      subject = "Welcome back"
      template = ERB.new(File.read('views/mailers/login.html.erb')).result(binding)
    end
    if ENV['RACK_ENV'] == "development"
        puts @link
    end
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