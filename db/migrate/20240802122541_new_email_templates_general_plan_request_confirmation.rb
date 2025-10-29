class NewEmailTemplatesGeneralPlanRequestConfirmation < ActiveRecord::Migration[5.2]
  def change
    redundant_mail_template = Decidim::AdminExtended::MailTemplate.find_by(
      system_name: "create_general_plan_request_confirmation"
    )
    redundant_mail_template&.destroy

    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(
      :create_general_plan_request_confirmation_to_admin
    )
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(
      :create_general_plan_request_confirmation_to_submitter
    )
  end
end
