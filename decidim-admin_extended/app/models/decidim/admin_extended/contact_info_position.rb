# frozen_string_literal: true
#
module Decidim::AdminExtended
  # Contact Info Position is used with pages
  class ContactInfoPosition < ApplicationRecord
    belongs_to :contact_info_group,
               optional: true

    scope :published, -> { where(published: true)}
    scope :sorted_by_weight, -> { order(:weight)}
  end
end
