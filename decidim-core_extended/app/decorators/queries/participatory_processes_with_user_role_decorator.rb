# frozen_string_literal: true

Decidim::ParticipatoryProcessesWithUserRole.class_eval do

  # Overwritten
  # Finds the ParticipatoryProcesses that the given user has role privileges.
  # If the special role ':any' is provided it returns all processes where
  # the user has some kind of role privilege.
  #
  # Returns an ActiveRecord::Relation.
  def query
    # Admin users have all role privileges for all organization processes
    return ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(user.organization).query if user.ad_admin?

    Decidim::ParticipatoryProcess.where(id: process_ids)
  end
end