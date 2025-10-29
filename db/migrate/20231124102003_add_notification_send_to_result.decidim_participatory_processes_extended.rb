# This migration comes from decidim_participatory_processes_extended (originally 20231124101734)
class AddNotificationSendToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes_extended_results, :notification_send, :boolean, default: false
    add_column :decidim_participatory_processes_extended_results, :notification_send_date, :date
  end
end
