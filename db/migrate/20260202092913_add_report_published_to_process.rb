class AddReportPublishedToProcess < ActiveRecord::Migration[7.0]
  def up
    add_column :decidim_participatory_processes,
               :report_published,
               :boolean,
               default: false,
               null: false

    execute <<~SQL.squish
      UPDATE decidim_participatory_processes
      SET report_published = TRUE
      WHERE report_description IS NOT NULL
        AND report_description <> '';
    SQL
  end

  def down
    remove_column :decidim_participatory_processes, :report_published
  end
end
