# frozen_string_literal: true

Decidim::ApplicationHelper.module_eval do

  def area_and_scope(model)
    area = model.area
    scope = model.scope

    as = content_tag :strong do
      (area ? content_tag(:span, "#{translated_attribute(area.name)}", class: "text-color-area-color-#{area.id}") : '').html_safe +
      ((area && scope) ? " / " : '') +
      (scope ? content_tag(:span, "#{translated_attribute(scope.name)}") : '').html_safe
    end

    r = if model.recipients.present?
          content_tag :strong,
                      t(model.recipients, scope: 'activemodel.attributes.participatory_process.recipients_type'),
                      class: 'recipients-small'
        else
          return as
        end

    (as + r)
  end
end
