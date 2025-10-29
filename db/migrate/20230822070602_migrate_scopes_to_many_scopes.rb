class MigrateScopesToManyScopes < ActiveRecord::Migration[5.2]
  def change

    reversible do |direction|
      direction.up do
        Decidim::ParticipatoryProcess.all.each do |process|
          next unless process.scope
          puts "process.scope: #{process.scope.name}"

          process.process_scopes.create(decidim_scope_id: process.scope.id)
        end
      end
    end

  end
end
