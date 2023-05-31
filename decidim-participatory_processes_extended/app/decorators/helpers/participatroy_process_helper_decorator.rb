# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.module_eval do
  def filter_date_values
    mapped = %w(active past report effects).map do |el|
      [t(el, scope: 'decidim.participatory_processes.participatory_processes.filters.wcag_names'), el]
    end
    mapped
  end

  def filter_scopes_values
    Decidim::Scope.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  def filter_areas_values
    Decidim::Area.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  def filter_departments_values
    Decidim::AdminExtended::Department.all.map do |el|
      [el.name, el.id]
    end
  end

  def filter_recipients_values
    tr_scope = 'decidim.participatory_processes.participatory_processes.filters'
    [
      [t('recipient_ngo', scope: tr_scope), 'ngo'],
      [t('recipient_citizen', scope: tr_scope), 'citizens']
    ]
  end

  def filter_years_values
    Decidim::ParticipatoryProcess.years.map { |y| [y, y] }
  end

  def filter_tags_values
    Decidim::AdminExtended::Tag.all.map do |el|
      [el.name, el.id]
    end
  end

  def step_classes(step, all_steps_count, active_step_pos)
    classes = ''
    pos = step.position
    if pos < active_step_pos
      classes += 'past'
    elsif pos == active_step_pos
      classes += 'active'
    else
      classes += 'future'
    end

    if pos == 0 || pos == all_steps_count || pos == active_step_pos || pos == (active_step_pos + 1)
      # first, active, next after active and last always visible
      classes += ' visible'
      if pos == 0 && active_step_pos != 1 && all_steps_count > 4
        # class that shows dotts: first element if next is not active
        classes += ' sep-js sep'
      elsif pos == (active_step_pos + 1) && pos != (all_steps_count - 1) && pos != all_steps_count
        # class that shows dotts: next after active if it is not last or one before last
        classes += ' sep-js sep'
      end
    else
      classes += ' hideable hide'
    end

    classes
  end
end
