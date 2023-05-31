class ChangeRepositoryConnections < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :decidim_news_informations, :gallery_id, :bigint
        add_foreign_key :decidim_news_informations, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_ad_users_space_info_articles, :gallery_id, :bigint
        add_foreign_key :decidim_ad_users_space_info_articles, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_static_pages, :gallery_id, :bigint
        add_foreign_key :decidim_static_pages, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_participatory_processes, :gallery_id, :bigint
        add_foreign_key :decidim_participatory_processes, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_meetings_meetings, :gallery_id, :bigint
        add_foreign_key :decidim_meetings_meetings, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_pages_pages, :gallery_id, :bigint
        add_foreign_key :decidim_pages_pages, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_forms_questionnaires, :file_id, :bigint
        add_foreign_key :decidim_forms_questionnaires, :decidim_repository_files,  column: :file_id, on_delete: :nullify

        change_column :decidim_forms_questionnaires, :gallery_id, :bigint
        add_foreign_key :decidim_forms_questionnaires, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_forms_questions, :file_id, :bigint
        add_foreign_key :decidim_forms_questions, :decidim_repository_files,  column: :file_id, on_delete: :nullify

        change_column :decidim_forms_questions, :gallery_id, :bigint
        add_foreign_key :decidim_forms_questions, :decidim_repository_galleries, column: :gallery_id, on_delete: :nullify

        change_column :decidim_repository_files, :folder_id, :bigint
        add_foreign_key :decidim_repository_files, :decidim_repository_folders,  column: :folder_id, on_delete: :nullify
      end
      dir.down do
        change_column :decidim_news_informations, :gallery_id, :integer
        remove_foreign_key :decidim_news_informations, :decidim_repository_galleries

        change_column :decidim_ad_users_space_info_articles, :gallery_id, :integer
        remove_foreign_key :decidim_ad_users_space_info_articles, :decidim_repository_galleries

        change_column :decidim_static_pages, :gallery_id, :integer
        remove_foreign_key :decidim_static_pages, :decidim_repository_galleries

        change_column :decidim_participatory_processes, :gallery_id, :integer
        remove_foreign_key :decidim_participatory_processes, :decidim_repository_galleries

        change_column :decidim_meetings_meetings, :gallery_id, :integer
        remove_foreign_key :decidim_meetings_meetings, :decidim_repository_galleries

        change_column :decidim_pages_pages, :gallery_id, :integer
        remove_foreign_key :decidim_pages_pages, :decidim_repository_galleries

        change_column :decidim_forms_questionnaires, :file_id, :integer
        remove_foreign_key :decidim_forms_questionnaires, :decidim_repository_files

        change_column :decidim_forms_questionnaires, :gallery_id, :integer
        remove_foreign_key :decidim_forms_questionnaires, :decidim_repository_galleries

        change_column :decidim_forms_questions, :file_id, :integer
        remove_foreign_key :decidim_forms_questions, :decidim_repository_files

        change_column :decidim_forms_questions, :gallery_id, :integer
        remove_foreign_key :decidim_forms_questions, :decidim_repository_galleries

        change_column :decidim_repository_files, :folder_id, :integer
        remove_foreign_key :decidim_repository_files, :decidim_repository_folders
      end
    end

  end
end
