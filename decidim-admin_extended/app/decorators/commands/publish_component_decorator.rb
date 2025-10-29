# frozen_string_literal: true

Decidim::Admin::PublishComponent.class_eval do
  # overwritten method
  # add create proxy hidden remark if component remarks
  # add create proxy hidden map remark if component consultation_map
  def call
    publish_component
    publish_event
    create_system_followable_remark if component.manifest_name == "remarks"
    create_system_followable_map_remark if component.manifest_name == "consultation_map"

    broadcast(:ok)
  end

  private

  # overwritten method
  # use our notification system instead of decidim
  def publish_event
    Decidim::CoreExtended::TemplatedMailerJob.perform_later("component_published", { resource: component })
  end

  # Private method
  # This method ensures that at least one remark exists for the component,
  # allowing users to follow remarks even when no user-created remarks exist.
  # It creates a hidden system remark that serves as a followable entity.
  def create_system_followable_remark
    return if Decidim::Remarks::Remark.exists?(body: "system_generated_hidden_remark", component:)

    Decidim::Remarks::Remark.create!(
      author: Decidim::User.first,
      body: "system_generated_hidden_remark",
      component:
    )
  end

  # Private method
  # This method ensures that at least one remark on map exists for the component,
  # allowing users to follow remarks on map even when no user-created remarks on map exist.
  # It creates a hidden system remark on map that serves as a followable entity.
  def create_system_followable_map_remark
    return if Decidim::ConsultationMap::Remark.exists?(body: "system_generated_hidden_map_remark", component:)

    Decidim::ConsultationMap::Remark.create!(
      author: Decidim::User.first,
      body: "system_generated_hidden_map_remark",
      component:
    )
  end
end
