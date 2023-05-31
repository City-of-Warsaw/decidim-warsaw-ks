# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ParticipatoryProcessesController
#
# Decorator implements additional functionalities to the Controller
# and changes existing methods.
Decidim::ParticipatoryProcesses::ParticipatoryProcessesController.class_eval do
  include Decidim::Paginable
  helper Decidim::Repository::ApplicationHelper

  helper_method :map_remarks, :map_component, :filtered_collection, :process_tags

  def show
    enforce_permission_to :read, :process, process: current_participatory_space

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "pdf"   # File name excluding ".pdf" extension.
      end
    end
  end

  private

  def per_page
    21
  end

  def default_filter_params
    {
      date: nil,
      scope_id: nil,
      area_id: nil,
      department_id: nil,
      address: nil,
      address_lat: nil,
      address_lng: nil,
      year: nil,
      recipients: nil,
      tags: nil
    }
  end

  def collection
    @collection ||= begin
                      processes = participatory_processes.order(start_date: :desc)
                      if filter.address_lat.present? && filter.address_lng.present?
                        processes = processes.joins(:scope).in_range_from(filter.address_lat, filter.address_lng, 2000.0)
                      end
                      processes
                    end
  end

  def filtered_collection
    paginate(collection)
  end

  def map_remarks
    return [] unless current_participatory_space
    return [] unless map_component
    return [] unless map_component.settings["show_on_space_page"]

    @map_remarks ||= Decidim::ConsultationMap::Remark
                       .where(component: map_component)
                       .order(created_at: :desc)
                       .limit(5)
  end

  def map_component
    @map_component ||= Decidim::Component
                         .where(manifest_name: "consultation_map")
                         .where(participatory_space: current_participatory_space)
                         .published
                         .first
  end

  def process_tags
    Decidim::AdminExtended::Tag.order(name: :asc)
  end
end
