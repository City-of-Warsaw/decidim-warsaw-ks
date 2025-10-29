# frozen_string_literal: true

Decidim::Comments::CreateComment.class_eval do
  # poniższy skrypt zostawiony - w sytuacji gdy byłyby potrzebne 2 osobne formularzy - 1 step utwórz komentarz i 2 step podaj dane stat.
  # include Decidim::CoreExtended::RegisteredUserHelper

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
  def create_comment
    parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

    params = comment_params(parsed)

    @comment = Decidim.traceability.create!(
      Decidim::Comments::Comment,
      current_user,
      params,
      visibility: "public-only"
    )

    # poniższy skrypt zostawiony - w sytuacji gdy byłyby potrzebne 2 osobne formularzy - 1 step utwórz komentarz i 2 step podaj dane stat.
    # comment.update(second_step_params) unless @author == unregistered_author
  end

  # Private method mapping form params into comment attributes
  #
  # Returns Hash
  def comment_params(parsed)
    {
      # overwritten author - user or unregistered author
      author: current_user,
      commentable: form.commentable,
      root_commentable: root_commentable(form.commentable),
      body: { I18n.locale => parsed.rewrite },
      alignment: form.alignment,
      decidim_user_group_id: form.user_group_id,
      participatory_space: form.current_component.try(:participatory_space),
      # custom
      signature: signature_or_editorial,
      token: user_entity_or_unregistered_author == unregistered_author ? SecureRandom.uuid : nil,
      email: current_user.is_a?(Decidim::User) ? current_user.email : "",
      age: user_age_or_from_form,
      gender: user_gender_or_from_form,
      district_id: user_district_or_from_form
    }.tap do |attr|
      attr[:files] = form.files if form.files.present?
    end
  end

  # Private method
  # returns special object that serves as Author for comments created by unregistered users
  def unregistered_author
    @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
  end

  def signature_or_editorial
    if current_user.respond_to?(:has_ad_role?) && form.current_user.has_ad_role?
      # scenario for AD user
      # editorial is only for AD user
      current_user.editorial.presence || I18n.t("decidim.author.ad_user")
    elsif current_user.is_a?(Decidim::User)
      # scenario for registered external user - no AD user
      current_user.name
    else
      # scenario for unregistered author
      form.signature
    end
  end

  def notify_about_commented_resource
    root = comment.root_commentable
    parent = comment.commentable
    return unless root.respond_to?(:published?) && root.published?

    if parent.is_a?(Decidim::Comments::Comment)
      return if parent.hidden? || parent.deleted?

      resource_key = :parent_of_reply
      mail_template = "new_reply_to_comment"

      Decidim::CoreExtended::TemplatedMailerJob.perform_later(
        mail_template,
        :resource => comment,
        resource_key => parent
      )
    elsif root.is_a?(Decidim::CustomProposals::CustomProposal)
      followable_root_commentable = Decidim::CustomProposals::CustomProposal.published
                                                                            .where(component: root.component)
                                                                            .sorted_by_weight
                                                                            .first
      resource_key = :custom_proposal
      mail_template = "new_comment_to_custom_proposal"

      Decidim::CoreExtended::TemplatedMailerJob.perform_later(
        mail_template,
        :resource => comment,
        resource_key => followable_root_commentable
      )
    else
      resource_mapping = {
        Decidim::Meetings::Meeting => [:meeting, "new_comment_to_meeting"],
        Decidim::Remarks::Remark => [:remark, "new_comment_to_remark"],
        Decidim::ConsultationMap::Remark => [:map_remark, "new_comment_to_map_remark"],
        Decidim::ExpertQuestions::UserQuestion => [:user_question, "new_comment_to_user_question"],
        Decidim::News::Information => [:information, "new_comment_to_information"]
      }

      pair = resource_mapping[root.class]
      return unless pair

      resource_key, mail_template = pair

      Decidim::CoreExtended::TemplatedMailerJob.perform_later(
        mail_template,
        :resource => comment,
        resource_key => root
      )
    end
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
end
