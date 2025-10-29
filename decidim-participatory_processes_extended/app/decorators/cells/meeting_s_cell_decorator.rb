# frozen_string_literal: true

require "cell/partial"

Decidim::Meetings::MeetingSCell.class_eval do
  # overwritten method
  # use our view
  def show
    render :show_new
  end

  private

  def description
    text = translated_attribute(model.description)

    decidim_sanitize(truncate(strip_tags(text), length: 210))
  end

  def participatory_space_class_name
    model.component.participatory_space.class.model_name.human
  end

  def participatory_space_title
    decidim_escape_translated model.component.participatory_space.title
  end

  def participatory_space_path
    resource_locator(model.component.participatory_space).path
  end
end
