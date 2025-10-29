class SyncDbMailTemplatesWithMailTemplatesModule < ActiveRecord::Migration[7.0]
  def change
    # remove redundant DB MailTemplates in
    # Mail Templates Module has prio
    module_keys = Decidim::AdminExtended::MailTemplatesGenerator.new.templates.keys.map(&:to_s)
    db_redundant = Decidim::AdminExtended::MailTemplate.where.not(system_name: module_keys)

    say "Found #{db_redundant.count} database redundant templates."
    db_redundant.destroy_all
  end
end
