# frozen_string_literal: true

Decidim::Comments::CreateComment.class_eval do
  include Decidim::CoreExtended::AuthorParamsBuilder
  include Decidim::CoreExtended::GenerateTokenHelper
  
  FOLLOWER_MAILS = {
    Decidim::Meetings::Meeting => [:meeting, "new_comment_to_meeting"],
    Decidim::Remarks::Remark => [:remark, "new_comment_to_remark"],
    Decidim::ConsultationMap::Remark => [:map_remark, "new_comment_to_map_remark"],
    Decidim::ExpertQuestions::UserQuestion => [:user_question, "new_comment_to_user_question"],
    Decidim::News::Information => [:information, "new_comment_to_information"],
    Decidim::CustomProposals::CustomProposal => [:custom_proposal, "new_comment_to_custom_proposal"]
  }.freeze

  # overwritten method
  # add author
  def initialize(form)
    @form = form
    @author = current_user || unregistered_author
  end

  # overwritten method
  # remove redundant with events block
  # add our email notification outside events block
  def call
    return broadcast(:invalid) if form.invalid?

    create_comment
    notify_about_commented_resource if comment

    broadcast(:ok, comment)
  end

  private

  # overwritten method
  # params moved into separate method
  # remove mention about users and groups
  # remove send_notifications
  # remove CommentCreation.publish to not generate decidim notification
  # add comment update with author second step params
  def create_comment
    parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

    params = comment_params(parsed)

    @comment = Decidim.traceability.create!(
      Decidim::Comments::Comment,
      current_user,
      params,
      visibility: "public-only"
    )

    comment.update(author_second_step_params)
  end

  # Private method mapping form params into comment attributes
  #
  # Returns Hash
  def comment_params(parsed)
    {
      author: current_user,
      commentable: form.commentable,
      root_commentable: root_commentable(form.commentable),
      body: { I18n.locale => parsed.rewrite },
      alignment: form.alignment,
      decidim_user_group_id: form.user_group_id,
      participatory_space: form.current_component.try(:participatory_space),
      # custom - add attrs
      signature: signature_or_editorial,
      token: generate_token
    }.tap do |attr|
      attr[:files] = form.files if form.files.present?
    end
  end

  def notify_about_commented_resource
    parent = comment.commentable
    root = comment.root_commentable
    return unless root.respond_to?(:published?) && root.published?
    return if reply_to_hidden_or_deleted?(parent)

    if parent.is_a?(Decidim::Comments::Comment)
      nofity_about_new_reply_to_comment(parent)
      return
    end

    notify_followers(root)
    notify_process_admins(root)
  end

  def reply_to_hidden_or_deleted?(parent)
    parent.is_a?(Decidim::Comments::Comment) && (parent.hidden? || parent.deleted?)
  end

  def notify_followers(root)
    mapping = FOLLOWER_MAILS[root.class]
    return unless mapping

    resource_key, template = mapping
    root = first_published_followable_custom_proposal(root) if root.is_a?(Decidim::CustomProposals::CustomProposal)

    Decidim::CoreExtended::TemplatedMailerJob.perform_later(
      template,
      :resource => comment,
      resource_key => root
    )
  end

  def nofity_about_new_reply_to_comment(parent)
    Decidim::CoreExtended::TemplatedMailerJob.perform_later(
      "new_reply_to_comment",
      :resource => comment,
      :parent_of_reply => parent
    )
  end

  # client wants notify for process admins that only comes from components:
  # - meetings
  # - custom_proposals
  # - remarks
  # do not worry about root commentable information
  # information's author becomes follower of that information
  def notify_process_admins(root)
    action_map = {
      Decidim::Meetings::Meeting => "new_comment_to_meeting_for_process_admin",
      Decidim::CustomProposals::CustomProposal => "new_comment_to_custom_proposal_for_process_admin",
      Decidim::Remarks::Remark => "new_comment_or_remark_for_process_admin"
    }

    action_name = action_map[root.class]
    return unless action_name

    process = extract_participatory_process(root)
    return unless process

    args = {
      resource: comment,
      process:
    }
    if action_name == "new_comment_or_remark_for_process_admin"
      args[:remark_or_its_comment_body] = comment.body["pl"]
      args[:remark_or_its_comment_link] = remark_or_its_comment_link
    end

    Decidim::CoreExtended::TemplatedMailerJob.perform_later(action_name, **args)
  end

  def extract_participatory_process(resource)
    return resource.participatory_space if resource.respond_to?(:participatory_space)

    resource.component.participatory_space if resource.respond_to?(:component)
  end

  # Returns the first published custom_proposal in the database.
  # AD User should always published custom proposals component with at least 1 published custom proposal
  # therefore, there will be custom proposal available for users to follow.
  def first_published_followable_custom_proposal(root)
    Decidim::CustomProposals::CustomProposal.published
                                            .where(component: root.component)
                                            .sorted_by_weight
                                            .first
  end

  # Private method
  # second step form - visible only for unregistered author
  def user_age_or_from_form
    if current_user.is_a?(Decidim::User)
      current_user.age_range.presence || ""
    else
      form.age
    end
  end

  # Private method
  # second step form - visible only for unregistered author
  def user_gender_or_from_form
    if current_user.is_a?(Decidim::User)
      current_user.gender
    else
      form.gender
    end
  end

  # Private method
  # second step form - visible only for unregistered author
  def user_district_or_from_form
    if current_user.is_a?(Decidim::User)
      current_user.district.present? ? current_user.district.id : nil
    else
      form.district_id
    end
  end

  def remark_or_its_comment_link
    root = comment.root_commentable
    url_params = { commentId: comment.id, anchor: "comment_#{comment.id}" }
    return root.polymorphic_resource_path(url_params) if root.respond_to?(:polymorphic_resource_path)

    resource_locator(root).url(url_params)
  end
end
