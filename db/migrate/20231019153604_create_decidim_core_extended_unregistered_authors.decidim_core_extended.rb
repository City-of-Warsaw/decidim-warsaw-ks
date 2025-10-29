# This migration comes from decidim_core_extended (originally 20231019152705)
class CreateDecidimCoreExtendedUnregisteredAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_core_extended_unregistered_authors do |t|
      t.references :organization, index: { name: "decidim_organization_core_extended_unregistered_author_id" }

      t.timestamps
    end

    drop_table :decidim_comments_extended_unregistered_authors

    # switch modules for Unregisterd Authors - create 1 unregistered author as dummy for future ones
    Decidim::CoreExtended::UnregisteredAuthor.create(organization: Decidim::Organization.first)

    # comments
    Decidim::Comments::Comment.where(decidim_author_type: 'Decidim::CommentsExtended::UnregisteredAuthor').update_all(decidim_author_type: 'Decidim::CoreExtended::UnregisteredAuthor')

    # remarks
    Decidim::Remarks::Remark.where(decidim_author_type: 'Decidim::CommentsExtended::UnregisteredAuthor').update_all(decidim_author_type: 'Decidim::CoreExtended::UnregisteredAuthor')

    # remarks on maps
    Decidim::ConsultationMap::Remark.where(decidim_author_type: 'Decidim::CommentsExtended::UnregisteredAuthor').update_all(decidim_author_type: 'Decidim::CoreExtended::UnregisteredAuthor')

    # user questions to experts
    Decidim::ExpertQuestions::UserQuestion.where(decidim_author_type: 'Decidim::CommentsExtended::UnregisteredAuthor').update_all(decidim_author_type: 'Decidim::CoreExtended::UnregisteredAuthor')
  end
end
