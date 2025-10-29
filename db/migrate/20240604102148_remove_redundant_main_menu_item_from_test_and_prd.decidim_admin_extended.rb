# This migration comes from decidim_admin_extended (originally 20240604102048)
class RemoveRedundantMainMenuItemFromTestAndPrd < ActiveRecord::Migration[5.2]
  def change
    redundant_news_main_menu_item = Decidim::AdminExtended::MainMenuItem.find_by(sys_name: "Informacje", weight: 7)
    redundant_news_main_menu_item&.destroy
  end
end
