# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ProcessMCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::ParticipatoryProcesses::ProcessMCell.class_eval do
  include Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper

  def show
    render :show_new
  end

  def footer_new
    render :footer_new
  end

  def area_class
    model.area ? "area-color-#{model.area.id}" : ''
  end

  # Public orverwritten method.
  # Added stripping tags
  #
  # Returns: string
  def description
    attribute = model.try(:short_description) || model.try(:body) || model.description
    text = translated_attribute(attribute)

    decidim_sanitize(html_truncate(text, length: 100), strip_tags: true)
  end

  private

  def ending_date
    return '' if model.end_date.blank?

    l(model.end_date.to_date, format: :decidim_short)
  end

  def process_new_data
    area_and_scope(model)
  end
end
