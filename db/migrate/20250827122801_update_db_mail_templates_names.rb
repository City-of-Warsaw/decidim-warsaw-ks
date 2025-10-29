class UpdateDbMailTemplatesNames < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.templates.each do |system_name, attributes|
      next unless (template = Decidim::AdminExtended::MailTemplate.find_by(system_name: system_name.to_s))
      template.update!(name: attributes[:name])
    end
  end
end
