# This migration comes from decidim_participatory_processes_extended (originally 20220711085027)
class AddAdditionalStatusesToProces < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :consultation_status, :string
  end
end
