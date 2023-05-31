require 'test_helper'

module Decidim::Repository
  class FileTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end

    def xxx
      require 'digest/md5'
      Digest::MD5.hexdigest
      Digest::MD5.hexdigest(File.read('data')) #=> string with 32 znaki
      checksum = '123'

      # # md5 = Digest::MD5.file(params[:file].tempfile.path).base64digest
      # checksum = Digest::MD5.file(form.file_input.tempfile.path).base64digest

      ActiveStorage::Blob.where(checksum: checksum).exists?

      md5 = Digest::MD5.file(params[:file].tempfile.path).base64digest

      ActiveStorage::Attachment
    end

    def permissions
      current_organization = u.organization
      Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController
      Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController.enforce_permission_to :update, :process, process: current_participatory_process
      # Decidim::NeedsPermission
      # allowed_to?(action, subject, extra_context)
      # initialize(user, permission_action, context = {})
      permission_action = Decidim::PermissionAction.new(scope: :admin, action: :update, subject: :participatory_process)
      permission_action = Decidim::PermissionAction.new(scope: :admin, action: :create, subject: :process)


      Decidim::ParticipatoryProcesses::Permissions.new(current_user, permission_action, process: current_participatory_process).permissions.allow?
    end

    def notify
      event = 'comment_created'
      event_class = "Decidim::Comments::#{event.to_s.camelcase}Event".constantize
      users = { followers: [3], affected_users: [] }
      comment = Decidim::Comments::Comment.last

      data = {
        event: "decidim.events.comments.#{event}",
        event_class: event_class,
        resource: comment.root_commentable,
        extra: {
          comment_id: comment.id
        }
      }.deep_merge(users)

    end

  end
end
