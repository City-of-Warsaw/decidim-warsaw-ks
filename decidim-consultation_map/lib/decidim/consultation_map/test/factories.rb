# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :consultation_map_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :consultation_map).i18n_name }
    manifest_name :consultation_map
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :map_remark, class: "Decidim::ConsultationMap::Remark" do
    body { ::Faker::Lorem.sentence }
    component { create :consultation_map_component }
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
