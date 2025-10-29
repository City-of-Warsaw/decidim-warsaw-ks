class AddResultNotificationSendToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :result_notification_send, :boolean, default: false
    add_column :decidim_participatory_processes, :result_notification_send_date, :date
  end
end
