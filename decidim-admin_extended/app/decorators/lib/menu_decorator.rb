# frozen_string_literal: true

Decidim::Menu.class_eval do

  def item(label, url, options = {})
    label, options = custom_item_options(label, options) if @name == :menu
    @items << Decidim::MenuItem.new(label, url, options)
  end

  private

  def custom_item_options(label, options = {})
    custom_menu_item = Decidim::AdminExtended::MainMenuItem.find_item(label)
    if custom_menu_item
      options[:position] = custom_menu_item.weight.to_f
      options[:original_label] = label
      options[:visible] = custom_menu_item.visible
      return custom_menu_item.name, options
    else
      options[:original_label] = label
      options[:visible] = label != 'Zespoły'
      return label, options
    end
  end
end
