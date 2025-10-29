# frozen_string_literal: true

Decidim::NotificationsSettingsForm.class_eval do
  mimic :user

  attribute :email_on_notification, Decidim::AttributeObject::TypeMap::Boolean
  attribute :send_to_tags, Decidim::AttributeObject::TypeMap::Boolean
  attribute :send_to_type_ngo, Decidim::AttributeObject::TypeMap::Boolean
  attribute :tag_ids
  attribute :recipients_ids

  def user_is_moderator?(user)
    participatory_space_types.each do |participatory_space_type|
      participatory_space_type.constantize.all.each do |participatory_space|
        return true if participatory_space.moderators.include?(user)
      end
    end
    false
  end

  private

  def participatory_space_types
    participatory_space_types = []
    Decidim.participatory_space_manifests.each do |manifest|
      participatory_space_types << manifest.model_class_name.to_s
    end
    participatory_space_types
  end
end
