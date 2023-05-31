class AddNewMailTemplate < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.load
      end
    end
  end
end
