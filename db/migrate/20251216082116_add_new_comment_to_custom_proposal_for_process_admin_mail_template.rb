class AddNewCommentToCustomProposalForProcessAdminMailTemplate < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:new_comment_to_custom_proposal_for_process_admin)
  end
end
