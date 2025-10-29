# frozen_string_literal: true

module Decidim
  module AdminExtended
  # Contact Info Group groups contact info positions
    class ContactInfoGroup < ApplicationRecord
      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      has_many :contact_info_positions

      scope :published, -> { where(published: true)}
      scope :sorted_by_weight, -> { order(:weight)}
    end
  end
end
