# frozen_string_literal: true

module Decidim::CoreExtended
  class EmailFollow < ApplicationRecord

    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true

    validates :email, presence: true, uniqueness: { scope: [:followable] }
  end
end

