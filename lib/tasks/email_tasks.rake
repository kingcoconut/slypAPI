desc 'send digest email'
task send_digest_email: :enviroment do
  EmailDigestWorker.perform_async
end