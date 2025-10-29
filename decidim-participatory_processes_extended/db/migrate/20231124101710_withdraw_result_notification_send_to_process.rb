class WithdrawResultNotificationSendToProcess < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_participatory_processes, :result_notification_send, :boolean
    remove_column :decidim_participatory_processes, :result_notification_send_date, :date
  end
end
