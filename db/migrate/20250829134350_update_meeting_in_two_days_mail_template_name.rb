class UpdateMeetingInTwoDaysMailTemplateName < ActiveRecord::Migration[7.0]
  def change
    execute <<~SQL.squish
      UPDATE decidim_admin_extended_mail_templates
      SET name = 'Powiadomienie na dwa dni przed spotkaniem w obserwowanym procesie'
      WHERE system_name = 'meeting_in_two_days';
    SQL
  end
end
