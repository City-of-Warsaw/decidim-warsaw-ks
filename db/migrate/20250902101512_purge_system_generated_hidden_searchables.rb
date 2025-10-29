class PurgeSystemGeneratedHiddenSearchables < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL.squish
      DELETE FROM decidim_searchable_resources
      WHERE content_a LIKE 'system_generated_hidden_%'
    SQL
  end
end
