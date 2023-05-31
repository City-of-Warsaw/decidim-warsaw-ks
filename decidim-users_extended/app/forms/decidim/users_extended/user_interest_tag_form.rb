# frozen_string_literal: true

module Decidim::UsersExtended
  # The form object that handles the data behind updating a user's
  # interests CONSIDERING Tags in her profile page.
  class UserInterestTagForm < Decidim::Form
    mimic :tag

    attribute :name, String
    attribute :checked, Boolean

    def map_model(model_hash)
      tag = model_hash[:tag]
      user = model_hash[:user]

      self.id = tag.id
      self.name = tag.name
      self.checked = user.interested_tags_ids.include?(tag.id)
    end
  end
end
