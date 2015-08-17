ENV["RACK_ENV"] ||= "development"
# Change to match your CPU core count
if ENV["RACK_ENV"] == "development"
	workers 1
else
	workers 2
end
# Min and Max threads per worker
threads 1, 16
if ENV["RACK_ENV"] != "development"
	stdout_redirect '/var/log/api/puma.log'
end