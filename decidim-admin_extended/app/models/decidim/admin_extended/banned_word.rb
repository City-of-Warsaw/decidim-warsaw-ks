# frozen_string_literal: true

module Decidim::AdminExtended
  # Banned Words are used with the Obscenity gem to create a word blacklist
  # which can be then used to checking data provided by users
  # If that data is offensive and against the Organization policy and that data is in blacklist
  # then it will send warning about it to users
  class BannedWord < ApplicationRecord
    scope :sorted_by_name, -> { order(:name) }

    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::BannedWordPresenter
    end

    def self.update_black_list
      Obscenity::Base.blacklist = pluck(:name)
    end
  end
end
