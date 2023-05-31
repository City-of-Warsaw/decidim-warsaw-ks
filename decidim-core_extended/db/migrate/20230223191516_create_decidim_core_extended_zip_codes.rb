class CreateDecidimCoreExtendedZipCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_core_extended_zip_codes do |t|
      t.string :code, null: false, limit: 6
      t.decimal :lat, precision: 12, scale: 9
      t.decimal :lng, precision: 12, scale: 9
    end
  end
end
