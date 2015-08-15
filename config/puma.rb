# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 16
stdout_redirect '/var/log/api/puma.log'