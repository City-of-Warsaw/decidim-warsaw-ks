class RemoveActivationSuccessTemplate < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'activation_success')
        template.destroy if template
      end
    end
  end
end
