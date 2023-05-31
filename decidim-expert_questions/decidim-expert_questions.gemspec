# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/expert_questions/version"

Gem::Specification.new do |s|
  s.version = Decidim::ExpertQuestions.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-expert_questions"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-expert_questions"
  s.summary = "A decidim expert_questions component"
  s.description = "Component for posting questions for experts in given participatory space."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.24.3'
  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "decidim-participatory_processes", '0.24.3'
end
