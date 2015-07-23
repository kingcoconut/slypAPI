# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 16

app_dir = File.expand_path("../", __FILE__)

# Logging
stdout_redirect "/var/log/puma/stdout.log", "/var/log/puma/stderr.log", true