class RemoveUserFromExperts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_expert_questions_experts, :full_name, :string

    reversible do |dir|
      dir.up do
        Decidim::ExpertQuestions::Expert.reset_column_information

        Decidim::ExpertQuestions::Expert.find_each do |record|
          user = Decidim::User.find(record.decidim_user_id)
          full_name = record.position.present? ? record.position : user&.name
          record.update_column :full_name, full_name
        end
      end
    end

    remove_column :decidim_expert_questions_experts, :position, :string
    remove_column :decidim_expert_questions_experts, :decidim_user_id, :integer
  end
end
