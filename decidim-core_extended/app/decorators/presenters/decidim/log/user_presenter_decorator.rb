# frozen_string_literal: true

Decidim::Log::UserPresenter.class_eval do
  private

  # overwritten method
  # swap title user nickname with user_name_with_office,
  # add data with tooltip and hover option
  def present_user
    return h.content_tag(:span, present_user_name, class: 'logs__log__author') if user.blank?
    return I18n.t("decidim.profile.deleted") if user.respond_to?(:deleted?) && user.deleted?

    h.link_to(
      present_user_name,
      user_path,
      class: 'logs__log__author',
      title: user_name_with_office,
      data: {
        tooltip: true,
        "disable-hover": false
      }
    )
  end

  # overwritten method
  # swap extra name with full name
  def present_user_name(prefix = nil)
    ("#{user.first_name} #{user.last_name}".presence || "#{prefix}#{user.name}").html_safe
  end

  def user_name_with_office
    "#{present_user_name('@')} #{user.office_name}".rstrip
  end
end
