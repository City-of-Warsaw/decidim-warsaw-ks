# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to update MainMenuItems.
    class MainMenuItemForm < Form
      attribute :name, String
      attribute :weight, Integer
      attribute :visible, GraphQL::Types::Boolean

      mimic :main_menu_item

      validates :name, presence: true
      validates :weight, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    end
  end
end
