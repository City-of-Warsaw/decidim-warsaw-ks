# frozen_string_literal: true

Decidim::MenuPresenter.class_eval do
  protected

  # Overwritten
  def render_menu(&block)
    # ADDED ROLE ATTR TO COMPLY WITH ACCESSIBILITY RULES
    content_tag :ul, @options.fetch(:container_options, {}).merge(role: 'list') do
      elements = block_given? ? [block.call(@view)] : []
      safe_join(elements + menu_items)
    end
  end
end