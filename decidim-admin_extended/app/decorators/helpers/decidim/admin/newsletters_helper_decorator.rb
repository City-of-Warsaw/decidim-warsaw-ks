# frozen_string_literal: true

Decidim::Admin::NewslettersHelper.class_eval do
  def ordered_tags_for_select(root = nil)
    @ordered_tags_for_select ||= Decidim::AdminExtended::Tag.order(name: :asc)
                                                            .map { |tag| [tag.name, tag.id] }
  end

  # Renders a tags select field in a form.
  # form - FormBuilder object
  # name - attribute name
  # options       - An optional Hash with options:
  #
  # Returns nothing.
  def tags_select_field(form, name, root: false, options: {}, html_options: {})
    options = options.merge(include_blank: I18n.t("decidim.tags.prompt")) unless options.has_key?(:include_blank)

    form.select(
      name,
      ordered_tags_for_select(root),
      options,
      html_options
    )
  end

  # overwritten method
  # remove condition unless current_user.admin?
  # remove I18n.t
  def spaces_for_select(manifest_name)
    return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)

    spaces_user_can_admin[manifest_name]
  end

  # overwritten method
  # remove i18n.t for sended_to_followers? && newsletter.sended_to_participants?
  # add tags and ngo
  def sent_to_users(newsletter)
    content_tag :p, style: "margin-bottom:0;" do
      concat content_tag(:strong, t("index.has_been_sent_to", scope: "decidim.admin.newsletters"), class: "text-success")
      concat content_tag(:strong, t("index.all_users", scope: "decidim.admin.newsletters")) if newsletter.sended_to_all_users?
      concat content_tag(:strong, t("index.followers", scope: "decidim.admin.newsletters")) if newsletter.sended_to_followers?
      concat ", " if newsletter.sended_to_followers? && newsletter.sended_to_participants?
      concat content_tag(:strong, t("index.participants", scope: "decidim.admin.newsletters")) if newsletter.sended_to_participants?
      concat ", " if newsletter.sended_to_type_ngo? && newsletter.sended_to_followers?
      concat content_tag(:strong, t("index.ngo", scope: "decidim.admin.newsletters")) if newsletter.sended_to_type_ngo?
      concat ", " if newsletter.sended_to_type_ngo? && newsletter.sended_to_tags?

      if newsletter.sended_to_tags?
        tags_list = if newsletter.extended_data["tag_ids"].any?
                      Decidim::AdminExtended::Tag.where(id: newsletter.extended_data["tag_ids"]).pluck(:name).join(", ")
                    else
                      "-"
                    end
        concat content_tag(:strong,
                           t("index.tags",
                             scope: "decidim.admin.newsletters", tags: tags_list))
      end
    end
  end
end
