module Decidim
  module CoreExtended
    class ApplicationMailer < ActionMailer::Base
      default from: Decidim.config.mailer_sender

      layout 'mailer'
    end
  end
end
