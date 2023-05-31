class AddAdditionalStatusesToProces < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :consultation_status, :string
  end
end
