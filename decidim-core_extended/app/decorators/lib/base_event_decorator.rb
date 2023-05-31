# frozen_string_literal: true

# OVERWRITTEN EVENT
Decidim::Events::BaseEvent.class_eval do

  # overwritten method
  # need an exception for custom component - Decidim::Remarks::Remark, because:
  # it is Participable -> can't get participatory_space_url for notification concerning Decidim::Remarks::Remark
  def participatory_space
    if resource.is_a?(Decidim::Remarks::Remark)
      resource.try(:participatory_space)
    elsif resource.is_a?(Decidim::Participable)
      resource
    else
      resource.try(:participatory_space)
    end
  end
end
