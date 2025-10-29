class CreateTranslations < ActiveRecord::Migration[7.0]
  def change
    create_table :translations do |t|
      t.string :scope
      t.string :locale
      t.string :key
      t.text :value
      t.text :interpolations
      t.boolean :is_proc, default: false

      t.timestamps
    end
    add_index :translations, :key, unique: true
  end
end
