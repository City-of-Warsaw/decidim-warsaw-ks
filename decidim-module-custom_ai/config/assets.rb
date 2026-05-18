# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_custom_ai: "#{base_path}/app/packs/entrypoints/decidim_custom_ai.js",
  ai_questionnaire: "#{base_path}/app/packs/entrypoints/ai_questionnaire.js",
  ai_answer_actions: "#{base_path}/app/packs/entrypoints/ai_answer_actions.js",
  ai_summary: "#{base_path}/app/packs/entrypoints/ai_summary.js",
  admin_answers: "#{base_path}/app/packs/entrypoints/decidim_custom_ai_admin_answers.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/custom_ai/custom_ai")
