# frozen_string_literal: true

Decidim::Admin::SelectiveNewsletterForm.class_eval do
  clear_validators!

  attribute :send_to_tags, Decidim::AttributeObject::TypeMap::Boolean
  attribute :send_to_type_ngo, Decidim::AttributeObject::TypeMap::Boolean
  attribute :tag_ids, Array

  validate :at_least_one_participatory_space_selected
  validate :at_least_one_type_selected

  private

  def at_least_one_type_selected
    return if send_to_tags || send_to_type_ngo || send_to_followers || send_to_all_users || send_to_participants

    errors.add(:base, "Musisz wybrać przynajmniej jeden typ odbiorców")
  end

  # overwritten method-validation
  # add send_to_followers.present?
  def at_least_one_participatory_space_selected
    return if send_to_all_users && current_user.ad_admin?

    errors.add(:base, :at_least_one_space) if spaces_selected.blank? && send_to_followers.present?
  end
end
