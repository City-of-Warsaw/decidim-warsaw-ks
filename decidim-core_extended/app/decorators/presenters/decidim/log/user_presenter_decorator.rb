# frozen_string_literal: true

Decidim::Log::UserPresenter.class_eval do
  private

  # overwritten method
  # remove condition output if user blank
  # swap link to profile with fake-link
  def present_user
    return I18n.t("decidim.profile.deleted") if user.respond_to?(:deleted?) && user.deleted?

    h.content_tag(:span, present_user_name, class: "fake-link")
  end

  # overwritten method
  # swap extra name with full name
  def present_user_name(prefix = nil)
    ("#{user.first_name} #{user.last_name}".presence || "#{prefix}#{user.name}").html_safe
  end
end
