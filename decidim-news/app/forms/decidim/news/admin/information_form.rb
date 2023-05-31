# frozen_string_literal: true

module Decidim
  module News
    module Admin
      class InformationForm < Form
        attribute :title, String
        attribute :body, String
        attribute :gallery_id, Integer
        attribute :users_action_allowed_for_unregister_users, Virtus::Attribute::Boolean

        mimic :information

        validates :title, presence: true
        validates :body, presence: true
        validates :users_action_allowed_for_unregister_users, presence: true 
        validate :gallery_exists

        def gallery_exists
          return if gallery_id.blank?

          errors.add(:gallery_id, :gallery_not_found) unless Decidim::Repository::Gallery.find_by(id: gallery_id)
        end

        alias organization current_organization
      end
    end
  end
end
