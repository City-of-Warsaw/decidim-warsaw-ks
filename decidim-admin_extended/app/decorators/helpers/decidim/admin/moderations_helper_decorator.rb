# frozen_string_literal: true

Decidim::Admin::ModerationsHelper.class_eval do
  # overwritten method
  # NOW - Returns a String or defined feedback message if the space is not found.
  def participatory_space_title_for(reportable, options = {})
    space = reportable.try(:participatory_space)
    if space
      I18n.with_locale(options.fetch(:locale, I18n.locale)) do
        title = translated_attribute(space.try(:title) || space.try(:name))
        type = space.class.model_name.human
        [type, title].compact.join(': ').truncate(options.fetch(:limit, 100))
      end
    else
      'Treść znajduje się w niedostępnej już przestrzeni'
    end
  end
end
