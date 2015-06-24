# slypAPI
## Requirements
ruby 2.2.2
  
## Install
`git clone https://github.com/xandergroeneveld/slypAPI.git`  
`cd slypAPI/`  
`bundle install`  
`rake db:create`  
`rake db:migrate`  
  
*add api-dev.slyp.io to your /etc/hosts for localhost  
*add this to your nginx.conf
 `server{
      listen 80;
      server_name api-dev.slyp.io;
      location / {
        proxy_pass http://127.0.0.1:9292;
      }
    }`
  
## Get Started
`rackup`
