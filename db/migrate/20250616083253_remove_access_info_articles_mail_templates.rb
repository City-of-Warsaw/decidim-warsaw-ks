# frozen_string_literal: true

class RemoveAccessInfoArticlesMailTemplates < ActiveRecord::Migration[7.0]
  def change
    grant = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'grant_access_to_info_articles')
    remove = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'remove_access_to_info_articles')
    grant.destroy if grant.present?
    remove.destroy if remove.present?
  end
end
