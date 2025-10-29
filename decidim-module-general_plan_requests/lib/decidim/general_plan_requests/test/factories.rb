# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :general_plan_requests_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :general_plan_requests).i18n_name }
    manifest_name :general_plan_requests
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
