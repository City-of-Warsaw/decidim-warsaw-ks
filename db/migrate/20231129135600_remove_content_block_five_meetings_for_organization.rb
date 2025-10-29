class RemoveContentBlockFiveMeetingsForOrganization < ActiveRecord::Migration[5.2]
  def change
    Decidim::ContentBlock.find_by(manifest_name: 'five_meetings')&.destroy
  end
end
