# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Allows to non-logged-in user follow a followable resource.
    class EmailFollow < ApplicationRecord
      belongs_to :followable,
                 foreign_key: "decidim_followable_id",
                 foreign_type: "decidim_followable_type",
                 polymorphic: true

      validates :email, presence: true, uniqueness: { scope: [:followable] }

      after_create :increase_followers_counter

      private

      def increase_followers_counter
        followable.increment!(:follows_count)
      end
    end
  end
end
