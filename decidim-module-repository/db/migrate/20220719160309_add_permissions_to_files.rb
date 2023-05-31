class AddPermissionsToFiles < ActiveRecord::Migration[5.2]
  def change
    # 0 prywatny,
    # 1 do wykorzystania dla każdego,
    # 2 do modyfikacji przez każdego
    add_column :decidim_repository_files, :permission, :integer, default: 2
  end
end
