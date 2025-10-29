class RefreshtemplatesEmail < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.load

  end
end
