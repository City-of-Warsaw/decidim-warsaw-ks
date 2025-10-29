# frozen_string_literal: true

module Decidim
  module AdminExtended
  # Contact Info Position is used with pages
    class ContactInfoPosition < ApplicationRecord
      include Decidim::Searchable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      belongs_to :contact_info_group,
                 optional: true

      scope :published, -> { where(published: true) }
      scope :sorted_by_weight, -> { order(:weight) }
    end
  end
end
