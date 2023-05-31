class CreateDecidimRemarksRemarks < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_remarks_remarks do |t|
      t.text :body, null: false
      t.string :decidim_author_type
      t.references :decidim_author, null: false, index: { name: "decidim_remarks_remark_author" }
      t.references :decidim_component, index: true, foreign_key: true
      t.integer :comments_count, null: false, default: 0, index: true

      t.string :signature
      t.string :email
      t.string :district
      t.string :age
      t.string :gender

      t.timestamps
    end
  end
end
