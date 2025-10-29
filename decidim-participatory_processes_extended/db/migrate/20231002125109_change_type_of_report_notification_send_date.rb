class ChangeTypeOfReportNotificationSendDate < ActiveRecord::Migration[5.2]
  def change
    change_column(:decidim_participatory_processes, :report_notification_send_date, :datetime)
  end
end
