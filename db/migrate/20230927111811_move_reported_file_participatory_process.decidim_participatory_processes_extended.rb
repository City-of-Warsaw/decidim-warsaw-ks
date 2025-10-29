# This migration comes from decidim_participatory_processes_extended (originally 20230927110229)
class MoveReportedFileParticipatoryProcess < ActiveRecord::Migration[5.2]
  def change
    Decidim::ParticipatoryProcess.all.each do |participatory_process|
      if participatory_process.report_files.any?
        participatory_process.report_files.each do |report_file|
          Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportFile.create(
            decidim_participatory_process_id: participatory_process.id,
            name: report_file.name,
            published: true,
            file: report_file.blob
          )
          # report_file.destroy
        end
      end
    end
  end
end
