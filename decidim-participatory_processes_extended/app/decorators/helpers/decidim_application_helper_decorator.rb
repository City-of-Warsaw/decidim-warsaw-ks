# frozen_string_literal: true

Decidim::ApplicationHelper.module_eval do
  def area_and_scope(model)
    area = model.area
    scope = model.scope

    as = content_tag :strong do
      (area ? content_tag(:span, translated_attribute(area.name).to_s, class: "text-color-area-color-#{area.id}") : '').html_safe +
        (area && scope ? ' / ' : '') +
        (scope ? content_tag(:span, translated_attribute(scope.name).to_s) : '').html_safe
    end

    return as unless model.not_for_citizens?

    r = content_tag :strong,
                      t(model.recipients, scope: 'activemodel.attributes.participatory_process.recipients_type'),
                      class: 'recipients-small'

    (as + r)
  end

  def area_and_scopes(model)
    # it is blank string if model.selected_scopes are empty
    scopes = model.selected_scopes.map { |s| content_tag(:span, translated_attribute(s.name)) }.join(', ').html_safe

    area = model.area
    as = content_tag :strong do
      (area ? content_tag(:span, translated_attribute(area.name), class: "text-color-area-color-#{area.id}") : '').html_safe +
        (area && scopes.present? ? ' / ' : '') + scopes
    end

    return as unless model.not_for_citizens?

    r = content_tag :span,
                    t(model.recipients, scope: 'activemodel.attributes.participatory_process.recipients_type'),
                    class: 'recipients-small'

    (as + r)
  end

  def areas(model)
    # it is blank string if model.selected_scopes are empty
    scopes = model.selected_scopes.map { |s| content_tag(:span, translated_attribute(s.name)) }.join(', ').html_safe

    area = model.area
    as = content_tag :strong do
      (area ? content_tag(:span, translated_attribute(area.name), class: "text-color-area-color-#{area.id}") : '').html_safe +
        (area && scopes.present? ? ' / ' : '') + scopes
    end

    as
  end

end
