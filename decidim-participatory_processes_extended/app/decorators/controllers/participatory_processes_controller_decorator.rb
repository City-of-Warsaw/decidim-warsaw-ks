# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ParticipatoryProcessesController
#
# Decorator implements additional functionalities to the Controller
# and changes existing methods.
Decidim::ParticipatoryProcesses::ParticipatoryProcessesController.class_eval do
  helper Decidim::Repository::ApplicationHelper
  helper Decidim::FollowableHelper

  helper_method :map_remarks,
                :map_component,
                :filtered_collection,
                :process_tags,
                :process_first_result,
                :testexxx,
                :paginable_processes_options

  # overwritten method that comes from Decidim::Paginable
  # reduce first element array to 20 - only for processes list
  def per_page
    if paginable_processes_options.include?(params[:per_page])
      params[:per_page].to_i
    elsif params[:per_page]
      sorted = paginable_processes_options.sort
      params[:per_page].to_i.clamp(sorted.first, sorted.last)
    else
      paginable_processes_options.first
    end
  end

  private

  # overwritten method
  # add return [] if params[:filter].present?
  # purpose: hide promoted collection if user use filters for processes
  def promoted_collection
    return [] if params[:filter].present?

    @promoted_collection ||= promoted_participatory_processes.query + promoted_participatory_process_groups.query
  end

  def default_filter_params
    {
      with_date: nil,
      address: nil,
      address_lat: nil,
      address_lng: nil,
      with_any_year: nil,
      with_any_department: nil,
      with_any_recipients: nil,
      with_any_scope: nil,
      with_any_tag: nil,
      with_any_date: nil
    }
  end

  def collection
    @collection ||= begin
                      processes = participatory_processes.order(start_date: :desc)
                      if filter_params[:address_lat].present? && filter_params[:address_lng].present?
                        processes = processes.joins(:scope).in_range_from(filter_params[:address_lat], filter_params[:address_lng], 2000.0)
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

  def process_first_result
    @process_first_result ||= current_participatory_space.results.published.sorted_by_weight.first
  end

  # ONLY FOR PROCESSES list
  # swap 25 with 20 so that the number of tiles is even
  def paginable_processes_options
    [20, 50, 100].freeze
  end
end
