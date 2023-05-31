class CreateDecidimConsultationRequestsConsultationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_consultation_requests do |t|
      t.string :title
      t.text :body

      t.datetime :date_of_request
      t.integer :comments_count, null: false, default: 0, index: true
      t.boolean :comments_allowed, default: false

      t.references :decidim_organization, foreign_key: true
      t.timestamps
    end
  end
end
