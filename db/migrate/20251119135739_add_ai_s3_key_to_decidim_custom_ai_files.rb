class AddAiS3KeyToDecidimCustomAiFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_custom_ai_files, :ai_s3_key, :string
  end
end
