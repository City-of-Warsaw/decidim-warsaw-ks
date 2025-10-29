class ChangeDefaultWeightInApp < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_comments_comment_votes, :weight, 0
    change_column_default :decidim_content_blocks, :weight, 0
    change_column_default :decidim_static_page_topics, :weight, 0
    change_column_default :decidim_static_pages, :weight, 0
    change_column_default :decidim_accountability_results, :weight, 0
    change_column_default :decidim_admin_extended_main_menu_items, :weight, 0
    change_column_default :decidim_assemblies, :weight, 0
  end
end
