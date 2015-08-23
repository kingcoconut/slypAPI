desc 'send digest email'
task send_digest_email: :environment do
  EmailDigestWorker.perform_async()
end