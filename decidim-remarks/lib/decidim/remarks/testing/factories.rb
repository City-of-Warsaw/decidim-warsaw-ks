# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :remarks_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :remarks).i18n_name }
    manifest_name { :remarks }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :remark, class: "Decidim::Remarks::Remark" do
    body { ::Faker::Lorem.sentence }
    component { create :remarks_component }
    author { create :user, :confirmed, organization: component.organization }

    trait :by_uregistered_author do
      author { component.organization.unregistered_author }
      email { ::Faker::Internet.email }
      signature { ::Faker::Lorem.word }
      district { create(:scope, organization: component.organization) }
      age { 'under_20' }
      gender { 'male' }
    end
  end
end
