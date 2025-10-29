# frozen_string_literal: true

Decidim::ParticipatoryProcessesWithUserRole.class_eval do
  # overwritten method
  # replace decidim's condition admin? with our ad_admin?
  def query
    # Admin users have all role privileges for all organization processes
    return Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(user.organization).query if user.ad_admin?

    Decidim::ParticipatoryProcess.where(id: process_ids)
  end
end
