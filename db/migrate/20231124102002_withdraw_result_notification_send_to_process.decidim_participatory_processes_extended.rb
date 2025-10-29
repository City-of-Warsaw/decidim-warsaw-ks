# This migration comes from decidim_participatory_processes_extended (originally 20231124101710)
class WithdrawResultNotificationSendToProcess < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_participatory_processes, :result_notification_send, :boolean
    remove_column :decidim_participatory_processes, :result_notification_send_date, :date
  end
end
