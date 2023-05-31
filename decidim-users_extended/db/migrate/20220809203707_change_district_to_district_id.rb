class ChangeDistrictToDistrictId < ActiveRecord::Migration[5.2]
  def up
    add_reference :decidim_expert_questions_user_questions, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    remove_column :decidim_expert_questions_user_questions, :district

    add_reference :decidim_comments_comments, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    remove_column :decidim_comments_comments, :district
  end

  def down
    remove_reference :decidim_expert_questions_user_questions, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    add_column :decidim_expert_questions_user_questions, :district, :string

    remove_reference :decidim_comments_comments, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    add_column :decidim_comments_comments, :district, :string
  end
end
