# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :expert_questions_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :expert_questions).i18n_name }
    manifest_name { :expert_questions }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :expert, class: "Decidim::ExpertQuestions::Expert" do
    position { ::Faker::Lorem.word }
    affiliation { ::Faker::Lorem.word }
    description { ::Faker::Lorem.sentence }
    weight { 1 }
    avatar { '' }
    component { create(:expert_questions_component) }
    user { create(:expert_user, :confirmed, organization: component.organization) }

    trait :confirmed do
      published_at { Time.current }
    end
  end

  factory :expert_user, parent: :user do
    ad_role { 'decidim_ks_bem_ekspert' }

    trait :confirmed do
      confirmed_at { Time.current }
      admin_terms_accepted_at { Time.current }
    end
  end

  factory :user_question, class: "Decidim::ExpertQuestions::UserQuestion" do
    body { ::Faker::Lorem.sentence }
    expert
    author { create :user, :confirmed, organization: expert.organization }

    trait :by_uregistered_author do
      author { expert.organization.unregistered_author }
      email { ::Faker::Internet.email }
      signature { ::Faker::Lorem.word }
      district { create(:scope, organization: expert.organization).name }
      age { 'under_20' }
      gender { 'male' }
    end

    trait :answered do
      status { 'answered' }
      after(:create) do |user_question, evaluator|
        create(:expert_answer, expert: user_question.expert, user_question: user_question)
      end
    end

    trait :answered_and_published do
      status { 'answered' }
      after(:create) do |user_question, evaluator|
        create(:expert_answer, :published, expert: user_question.expert, user_question: user_question)
      end
    end
  end

  factory :expert_answer, class: "Decidim::ExpertQuestions::ExpertAnswer" do
    body { ::Faker::Lorem.sentence }
    expert
    user_question { create :user_question, expert: expert }

    trait :published do
      published_at { Time.current }
    end
  end
end
