# frozen_string_literal: true

class AddSystemGeneratedHiddenObjectForThreeComponentsToBeFollowed < ActiveRecord::Migration[7.0]
  def change
    published_components = Decidim::Component.published

    published_components.where(manifest_name: "remarks").each do |component|
      Decidim::Remarks::Remark.where(body: "system_generated_hidden_remark", component:).delete_all
      create_system_followable_remark(component)
    end

    published_components.where(manifest_name: "consultation_map").each do |component|
      Decidim::ConsultationMap::Remark.where(body: "system_generated_hidden_map_remark", component:).delete_all
      create_system_followable_map_remark(component)
    end

    published_components.where(manifest_name: "expert_questions").each do |component|
      expert = Decidim::ExpertQuestions::Expert.published.where(component:).first
      next unless expert

      Decidim::ExpertQuestions::UserQuestion.where(body: "system_generated_hidden_user_question", expert:).delete_all
      create_system_followable_user_question(expert)
    end
  end

  private

  def create_system_followable_remark(component)
    Decidim::Remarks::Remark.create!(
      author: Decidim::User.first,
      body: "system_generated_hidden_remark",
      component:
    )
  end

  def create_system_followable_map_remark(component)
    Decidim::ConsultationMap::Remark.create!(
      author: Decidim::User.first,
      body: "system_generated_hidden_map_remark",
      component:
    )
  end

  def create_system_followable_user_question(expert)
    Decidim::ExpertQuestions::UserQuestion.create!(
      author: Decidim::User.first,
      body: "system_generated_hidden_user_question",
      expert:
    )
  end
end
