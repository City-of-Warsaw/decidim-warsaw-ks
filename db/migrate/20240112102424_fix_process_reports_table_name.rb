class FixProcessReportsTableName < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      ALTER TABLE "public"."decidim_participatory_processes_extended_participatory_process_" RENAME TO
      "decidim_participatory_processes_extended_report_files";
    SQL
  end
end
