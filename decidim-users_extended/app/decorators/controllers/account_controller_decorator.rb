# frozen_string_literal: true

Decidim::AccountController.class_eval do
  helper Decidim::UsersExtended::ApplicationHelper

  helper_method :my_followed_processes, :my_followed_informations, :my_followed_components, :my_comments_list, :my_remarks_list

  def my_follow; end

  def my_comments; end

  # overwritten method
  # swap:
  # t("account.update.success", scope: "decidim")
  # with:
  # t("decidim.account.update.success", scope: "decidim.admin_extended.additional_translation")
  def update
    enforce_permission_to(:update, :user, current_user:)
    @account = form(Decidim::AccountForm).from_params(account_params)
    Decidim::UpdateAccount.call(@account) do
      on(:ok) do |email_is_unconfirmed|
        flash[:notice] = if email_is_unconfirmed
                           t("account.update.success_with_email_confirmation", scope: "decidim")
                         else
                           t("decidim.account.update.success", scope: "decidim.admin_extended.additional_translation")
                         end

        bypass_sign_in(current_user)
        redirect_to account_path(locale: current_user.reload.locale)
      end

      on(:invalid) do |password|
        fetch_entered_password(password)
        flash[:alert] = t("account.update.error", scope: "decidim")
        render action: :show
      end
    end
  end

  private

  def my_followed_processes
    my_followed("Decidim::ParticipatoryProcess")
  end

  def my_followed_informations
    my_followed("Decidim::News::Information")
  end

  def my_followed_components
    my_followed(folowable_clases)
  end

  def my_comments_list
    Decidim::Comments::Comment.where(author: current_user).not_deleted.not_hidden.order(created_at: :desc)
  end
  def my_remarks_list
    Decidim::Remarks::Remark.where(author: current_user).where.not(body: "system_generated_hidden_remark").order(created_at: :desc) +
      Decidim::ConsultationMap::Remark.where(author: current_user).where.not(body: "system_generated_hidden_remark").not_hidden.order(created_at: :desc) +
      Decidim::ExpertQuestions::UserQuestion.where(author: current_user).where.not(body: "system_generated_hidden_remark").not_hidden.order(created_at: :desc)
  end

  def my_followed(class_name)
    Decidim::Follow.where(decidim_followable_type: class_name, decidim_user_id: current_user.id)
                   .map(&:followable).compact_blank
  end

  def folowable_clases
    ["Decidim::Meetings::Meeting",
     "Decidim::ConsultationMap::Remark",
     "Decidim::Remarks::Remark",
     "Decidim::ExpertQuestions::UserQuestion",
     "Decidim::CustomProposals::CustomProposal"]
  end

end
