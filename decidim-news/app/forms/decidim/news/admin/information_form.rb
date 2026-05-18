# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A form object to create and update Information
      class InformationForm < Form
        include Decidim::Repository::Admin::GalleryInputAttributes
        include Decidim::Repository::Admin::GalleriesValidations

        attribute :title, String
        attribute :body, String
        attribute :users_action_allowed_for_unregister_users, Decidim::AttributeObject::TypeMap::Boolean
        attribute :weight, Integer, default: 0
        attribute :added_on, Date
        attribute :comments_enabled, Decidim::AttributeObject::TypeMap::Boolean, default: false

        mimic :information

        validates :title,
                  :body,
                  presence: true
        validates :users_action_allowed_for_unregister_users,
                  :comments_enabled,
                  inclusion: [true, false]

        alias organization current_organization

        def map_model(model)
          super
          self.gallery_id = model.gallery_id
        end
      end
    end
  end
end
