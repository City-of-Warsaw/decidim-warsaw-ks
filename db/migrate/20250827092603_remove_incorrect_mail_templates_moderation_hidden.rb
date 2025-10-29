class RemoveIncorrectMailTemplatesModerationHidden < ActiveRecord::Migration[7.0]
  def change
    # Purpose, naming, content of these templates are incorrect.
    old_incorrect_naming_templates = %w(comment_hidden remark_hidden user_question_hidden)
    old_incorrect_naming_templates.each do |system_name|
      if (template = Decidim::AdminExtended::MailTemplate.find_by(system_name:))
        template.destroy!
      end
    end
  end
end
