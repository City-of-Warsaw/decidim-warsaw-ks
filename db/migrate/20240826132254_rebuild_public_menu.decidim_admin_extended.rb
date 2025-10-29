# frozen_string_literal: true

# This migration comes from decidim_admin_extended (originally 20240826080219)
class RebuildPublicMenu < ActiveRecord::Migration[5.2]
  def change
    decidim_main_menu_items = {
      'Strona główna' => {
        name: 'Strona główna',
        weight: 1,
        visible: true
      },
      'Pomoc' => {
        name: 'Baza wiedzy',
        weight: 2,
        visible: true
      },
      'Procesy' => {
        name: 'Lista Konsultacji',
        weight: 3,
        visible: true
      }
    }

    custom_main_menu_items = {
      'Aktualności' => {
        name: 'Informacje',
        weight: 4,
        visible: false
      },
      'Wnioski o konsultacje' => {
        name: 'Wnioski',
        weight: 5,
        visible: false
      },
      'Strefa koordynatora konsultacji' => {
        name: 'Strefa koordynatora konsultacji',
        weight: 6,
        visible: false
      },
      'Pytania i odpowiedzi' => {
        name: 'FAQ',
        weight: 7,
        visible: false
      }
    }

    current_main_menu_items = decidim_main_menu_items.merge(custom_main_menu_items)

    # Create missing menu items
    current_main_menu_items.each do |sys_name, attributes|
      menu_item = Decidim::AdminExtended::MainMenuItem.find_by(sys_name: sys_name)
      Decidim::AdminExtended::MainMenuItem.create(sys_name: sys_name, **attributes) unless menu_item
    end

    # Remove all menu items that are not in the current_main_menu_items list
    Decidim::AdminExtended::MainMenuItem.where.not(sys_name: current_main_menu_items.keys).destroy_all
  end
end
