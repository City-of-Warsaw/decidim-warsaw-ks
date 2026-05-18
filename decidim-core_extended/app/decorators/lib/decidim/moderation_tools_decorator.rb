# frozen_string_literal: true

Decidim::ModerationTools.class_eval do
  # overwritten method
  # add context
  def initialize(reportable, current_user, context: {})
    @reportable = reportable
    @current_user = current_user
    @context = context
  end

  # overwritten method
  # do not produce decidim event if Unregistered Author
  # swap decidim mailer with our email notification
  def send_notification_to_author
    return if @reportable.author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)

    Decidim::CoreExtended::ModerationToolsMailerJob.perform_later(
      "hidden_resource_notification_to_author",
      @reportable,
      @reportable.author,
      context[:details]
    )
  end

  # overwritten method
  # hide child resources only if it is Commentable but NOT a Remark
  def hide!
    Decidim.traceability.perform_action!(
      "hide",
      moderation,
      @current_user,
      extra: {
        reportable_type: @reportable.class.name
      }
    ) do
      @reportable.moderation.update!(hidden_at: Time.current)
      @reportable.try(:touch)
    end

    if @reportable.is_a?(Decidim::Comments::Commentable) && !@reportable.is_a?(Decidim::Remarks::Remark)
      @reportable.comment_threads.each do |comment|
        Decidim::HideChildResourcesJob.perform_later(comment, @current_user.id)
      end
    end

    send_notification_to_author
  end

  attr_reader :context
end
