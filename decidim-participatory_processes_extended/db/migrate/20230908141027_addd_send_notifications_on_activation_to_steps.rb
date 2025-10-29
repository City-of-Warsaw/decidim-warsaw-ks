class AdddSendNotificationsOnActivationToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :send_notifications_on_activation, :boolean, default: false
  end
end
