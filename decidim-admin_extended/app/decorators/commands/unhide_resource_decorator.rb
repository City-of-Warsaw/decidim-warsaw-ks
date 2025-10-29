# frozen_string_literal: true

Decidim::Admin::UnhideResource.class_eval do
  # overwritten method
  # return also resource to search
  def call
    return broadcast(:parent_invalid) if @reportable.respond_to?(:commentable) && @reportable.commentable.try(:hidden?)
    return broadcast(:invalid) unless unhideable?

    unhide!
    return_searchable_resource
    broadcast(:ok, @reportable)
  end

  # hidden resource is still searchable - unhide returns it to search
  def return_searchable_resource
    Decidim::SearchableResource.create(
      content_a: @reportable&.body,
      locale: "pl",
      datetime: Time.zone.now,
      decidim_participatory_space_type: @reportable&.participatory_space.class,
      decidim_participatory_space_id: @reportable&.participatory_space.id,
      organization: @current_user.organization,
      resource: @reportable
    )
  end
end
