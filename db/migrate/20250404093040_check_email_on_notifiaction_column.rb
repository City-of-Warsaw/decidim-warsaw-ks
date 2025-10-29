class CheckEmailOnNotifiactionColumn < ActiveRecord::Migration[6.1]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:decidim_users, :email_on_notification)
      add_column :decidim_users, :email_on_notification, :boolean, default: true
    end
  end
end
