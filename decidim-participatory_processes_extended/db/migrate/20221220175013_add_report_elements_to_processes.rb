class AddReportElementsToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :report_description, :text
    add_column :decidim_participatory_processes, :report_publication_date, :date
    add_column :decidim_participatory_processes, :report_notification_send, :boolean, default: false
    add_column :decidim_participatory_processes, :report_notification_send_date, :date
  end
end
