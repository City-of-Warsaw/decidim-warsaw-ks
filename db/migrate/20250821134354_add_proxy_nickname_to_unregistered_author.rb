class AddProxyNicknameToUnregisteredAuthor < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_core_extended_unregistered_authors, :nickname, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE decidim_core_extended_unregistered_authors
          SET nickname = 'Użytkownik niezarejestrowany'
        SQL
      end
    end
  end
end
