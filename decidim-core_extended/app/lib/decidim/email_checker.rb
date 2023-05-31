# frozen_string_literal: true

module Decidim
  module EmailChecker
    # Private: checking if given is valid email format
    #
    # returns Boolean
    def valid_email?(str)
      !!(str =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
    end
  end
end