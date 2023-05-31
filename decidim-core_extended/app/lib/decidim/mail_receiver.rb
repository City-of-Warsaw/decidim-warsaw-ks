# frozen_string_literal: true

module Decidim
  # Class for packaging different type of receivers:
  # User, UnregisteredAuthor, Follower (User), EmailFollow
  # For UnregisteredAuthor user data can be in resource
  class MailReceiver
    attr_accessor :receiver, :email, :name

    def initialize(receiver, resource)
      self.receiver = receiver
      self.email = if receiver.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
                     resource.email
                   elsif receiver.is_a?(Decidim::CoreExtended::EmailFollow)
                     receiver.email
                   elsif receiver.is_a?(Decidim::User)
                     receiver.email
                   else
                     receiver.email.blank? ? receiver.user.email : receiver.email
                   end

      self.name = if receiver.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
                    resource.signature.presence || @email
                  elsif receiver.is_a?(Decidim::CoreExtended::EmailFollow)
                    receiver.email
                  else
                    receiver.name
                  end
    end
  end
end
