class MakePublishedDefaultFalseForReportFile < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_participatory_processes_extended_report_files, :published, false

    Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportFile.where(published: nil).update_all(published: false)
  end
end
