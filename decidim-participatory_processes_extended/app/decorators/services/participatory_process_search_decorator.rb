# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ParticipatoryProcessSearch
#
# Decorator implements additional functionalities to the service
# and changes existing methods.
Decidim::ParticipatoryProcesses::ParticipatoryProcessSearch.class_eval do

  # Public: method search processes via address, in radius of 2 km
  #
  # returns Query
  def search_address
    return query if address.blank?

    # TODO: szukanie w promieniu
    query
  end

  def search_area_id
    clean_area_ids = area_id.reject(&:blank?)
    return query if clean_area_ids.none?

    query.includes(:area).where(decidim_area_id: clean_area_ids)
  end

  def search_department_id
    clean_department_ids = department_id.reject(&:blank?)
    return query unless clean_department_ids.any?

    query.includes(:department).where(decidim_department_id: clean_department_ids)
  end

  # Public: method search processes via tags value based on given phrase in @tags variable
  #
  # returns Query
  def search_tags
    clean_tag_ids = tags.reject(&:blank?)
    return query unless clean_tag_ids.any?

    query.joins(:process_tags).where("decidim_participatory_processes_extended_process_tags.decidim_admin_extended_tag_id": clean_tag_ids).distinct
  end

  # Public: method search processes via zip code value based on given phrase in @zip_code variable
  #
  # returns Query
  def search_zip_code
    return query if zip_code.blank?

    query.where("decidim_participatory_processes.zip_code LIKE :text", text: "%#{zip_code}%")
  end

  # Public: method search processes via start date value based on given year in @year variable
  #
  # returns Query
  def search_year
    return query if year.none?

    query.where('cast(decidim_participatory_processes.start_date AS varchar) ~ :text', text: year.join('|'))
  end

  def search_recipients
    return query if recipients.none? || recipients.count >= 2

    case recipients[0]
    when 'ngo'
      return query.where(recipients: ['ngo', 'mix'])
    when 'citizens'
      return query.where(recipients: ['citizens', 'mix'])
    else
      return query
    end
  end

  # OVERWRITTEN method
  def search_date
    return query if date.none?

    processed_date = date.reject { |c| c.blank? || c == 'report' || c == 'effects' }
    processed_status = date.reject { |c| c.blank? || c == 'active' || c == 'past' }

    date_query = if processed_date.size == 1
                   case processed_date[0]
                   when "active"
                     query.active
                   when "past"
                     query.past
                   else
                     query
                   end
                 else
                   query
                 end

    status_query = if processed_status.size != 0
                     date_query.where('decidim_participatory_processes.consultation_status': processed_status)
                   else
                     date_query
                   end
    status_query
  end
end