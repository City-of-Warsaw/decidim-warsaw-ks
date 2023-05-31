# frozen_string_literal: true

Decidim::Admin::SelectiveNewsletterForm.class_eval do
  private

  def at_least_one_participatory_space_selected
    return if send_to_all_users && current_user.ad_admin?

    errors.add(:base, "Select atleast one participatory space") if spaces_selected.blank?
  end
end