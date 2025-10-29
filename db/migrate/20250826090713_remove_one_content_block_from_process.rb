class RemoveOneContentBlockFromProcess < ActiveRecord::Migration[7.0]
  def change
    Decidim::ParticipatoryProcess.all.each do |process|
      cbl =  Decidim::ContentBlock.find_by(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "area_map"
      )
      cbl.update(published_at: nil) unless cbl.nil?
    end
  end
end
