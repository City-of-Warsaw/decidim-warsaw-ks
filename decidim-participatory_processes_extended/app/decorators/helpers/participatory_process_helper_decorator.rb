# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.module_eval do
  # overwritten method
  # swap variable components with nav_items
  # add to array Raport Konsultacji and/or Efekty Konsultacji
  def process_nav_items(participatory_space)
    components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

    nav_items = components.map do |component|
      {
        name: decidim_escape_translated(component.name),
        url: main_component_path(component),
        active: is_active_link?(main_component_path(component), :inclusive)
      }
    end

    # prepend in reverse order
    if %w(report effects).include?(participatory_space.consultation_status) && participatory_space.report_published?
      nav_items.unshift(process_report_nav_item(participatory_space))
    end

    if %w(effects).include?(participatory_space.consultation_status) && participatory_space.published_first_result?
      nav_items.unshift(process_effects_nav_item(participatory_space))
    end

    nav_items
  end

  def process_report_nav_item(participatory_space)
    reports_path = "#{decidim_participatory_processes.participatory_process_path(participatory_space)}/participatory_process_reports"
    {
      name: I18n.t("title", scope: "decidim.participatory_processes_extended.participatory_process_reports.index"),
      url: reports_path,
      active: is_active_link?(reports_path, :exclusive)
    }
  end

  def process_effects_nav_item(participatory_space)
    results_path = "#{decidim_participatory_processes.participatory_process_path(participatory_space)}/results"
    {
      name: I18n.t("effects", scope: "activemodel.attributes.participatory_process.consultation_statuses"),
      url: results_path,
      active: is_active_link?(results_path, :exclusive)
    }
  end

  def filter_date_values
    %w(active past report effects).map do |el|
      [t(el, scope: "decidim.participatory_processes.participatory_processes.filters.wcag_names"), el]
    end
  end

  # overwritten method
  # rebuild method
  # remove :with_date
  # remove :with_any_area
  # remove :with_any_type
  # add :with_any_date
  # add :with_any_tag
  # add :with_any_recipients
  # add :with_any_department
  # add :with_any_year
  def filter_sections
    [
      { method: :with_any_date, collection: filter_any_date_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "date", },
      { method: :with_any_scope, collection: filter_global_scopes_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "scope" },
      { method: :with_any_tag, collection: filter_tags_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "tags", type: "check_boxes" },
      { method: :with_any_recipients, collection: filter_recipients_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "recipients" },
      { method: :with_any_department, collection: filter_departments_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "department", type: "check_boxes" },
      { method: :with_any_year, collection: filter_years_values, label_scope: "decidim.participatory_processes.participatory_processes.filters", id: "year", type: "check_boxes" }
    ].reject { |item| item[:collection].blank? }
  end

  def filter_scopes_values
    Decidim::Scope.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  def filter_any_date_values
    [
      ["active", "Trwające"],
      ["past", "Zakończone"],
      ["report", "Opublikowany raport"],
      ["effects", "Efekty konsultacji"]
    ]
  end

  def filter_departments_values
    Decidim::AdminExtended::Department.all.map { |el| [el.id, el.name] }
  end

  def filter_recipients_values
    tr_scope = "decidim.participatory_processes.participatory_processes.filters"
    [
      ["ngo", t("recipient_ngo", scope: tr_scope)],
      ["citizens", t("recipient_citizen", scope: tr_scope)]
    ]
  end

  def filter_years_values
    Decidim::ParticipatoryProcess.years.map { |y| [y, y] }
  end

  def filter_tags_values
    Decidim::AdminExtended::Tag.all.map do |el|
      [el.id, el.name]
    end
  end

  def step_classes(step, all_steps_count, active_step_pos)
    pos = step.position
    classes = if pos < active_step_pos
                "past"
              elsif pos == active_step_pos
                "active"
              else
                "future"
              end

    if pos == 0 || pos == all_steps_count - 1 || pos == active_step_pos || all_steps_count <= 3
      # first, active, next after active and last always visible
      classes += " visible"
      if pos == 0 && active_step_pos != 1 && all_steps_count > 3
        # class that shows dotts: first element if next is not active
        classes += " sep-js sep"
      elsif pos == active_step_pos && pos < (all_steps_count - 2) && all_steps_count > 3
        # class that shows dotts: next after active if it is not last or one before last
        classes += " sep-js sep"
      end
    else
      classes += " hideable hide"
    end

    classes
  end
end
