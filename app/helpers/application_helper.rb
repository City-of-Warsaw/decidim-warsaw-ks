# frozen_string_literal: true

module ApplicationHelper
  # do not display
  # Section headings: Galleria i Materials dla Efektu Konsultacji
  def result_class?(model)
    model.is_a?(Decidim::ParticipatoryProcessesExtended::Result)
  end

  # do not display
  # Section headings: Galleria i Materials dla Konsultacji
  def processs_class?(model)
    model.is_a?(Decidim::ParticipatoryProcess)
  end

  # Public: It sanitizes a user-inputted string with the
  # `Decidim::QuillScrubber` scrubber, so that video embeds and with video tag work
  # as expected. Uses Rails' `sanitize` internally.
  #
  # html - A string representing user-inputted HTML.
  #
  # Returns an HTML-safe String.
  def quill_sanitize(html, options = {})
    if options[:strip_tags]
      strip_tags sanitize(html, scrubber: Decidim::QuillScrubber.new)
    else
      sanitize(html, scrubber: Decidim::QuillScrubber.new)
    end
  end

  def step_classes(step, all_steps_count, active_step_pos)
    pos = step.position
    classes = if pos < active_step_pos
                'past'
              elsif pos == active_step_pos
                'active'
              else
                'future'
              end

    if pos == 0 || pos == all_steps_count - 1 || pos == active_step_pos || all_steps_count <= 3
      # first, active, next after active and last always visible
      classes += ' visible'
      if pos == 0 && active_step_pos != 1 && all_steps_count > 3
        # class that shows dotts: first element if next is not active
        classes += ' sep-js sep'
      elsif pos == active_step_pos && pos < (all_steps_count - 2) && all_steps_count > 3
        # class that shows dotts: next after active if it is not last or one before last
        classes += ' sep-js sep'
      end
    else
      classes += ' hideable hide'
    end

    classes
  end
end
