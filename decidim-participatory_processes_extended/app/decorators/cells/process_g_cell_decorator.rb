# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ProcessGCell.class_eval do
  def show
    render :show_new
  end

  def metadata_cell
    "decidim/participatory_processes/process_metadata_g_new"
  end

  private

  def ending_date
    return '' if model.end_date.blank?

    l(model.end_date.to_date, format: :decidim_short_cut_zero)
  end

  def area_class
    model.area ? "area-color-#{model.area.id}" : ''
  end

  def areas_data
    areas(model)
  end
end
