class UpdateMailTemplateSystemNameProcessUpdatedBy < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL.squish
      UPDATE decidim_admin_extended_mail_templates
      SET system_name = 'process_updated_by_admin'
      WHERE system_name = 'process_updated_by_coordinator';
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE decidim_admin_extended_mail_templates
      SET system_name = 'process_updated_by_coordinator'
      WHERE system_name = 'process_updated_by_admin';
    SQL
  end
end
