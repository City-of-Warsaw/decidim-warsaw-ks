# frozen_string_literal: true

Decidim::Menu.class_eval do
  # overwritten method
  # add custom_item_options
  def add_item(identifier, label, url, options = {})
    if @name == :home_content_block_menu
      label, options = custom_item_options(identifier, label, options) if @name == :home_content_block_menu
    else
      options = { position: (1 + @items.length) }.merge(options)
    end
    @items << Decidim::MenuItem.new(label, url, identifier, options)
  end

  private

  def custom_item_options(identifier, label, options = {})
    custom_menu_item = Decidim::AdminExtended::MainMenuItem.find_item(identifier)
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
