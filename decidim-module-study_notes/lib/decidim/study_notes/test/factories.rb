# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :study_notes_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :study_notes).i18n_name }
    manifest_name :study_notes
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
