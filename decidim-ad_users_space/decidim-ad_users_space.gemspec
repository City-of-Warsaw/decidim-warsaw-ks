# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/ad_users_space/version"

Gem::Specification.new do |s|
  s.version = Decidim::AdUsersSpace.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-ad_users_space"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-ad_users_space"
  s.summary = "A decidim ad_users_space module"
  s.description = "Space dedicated fot users with AD permissions."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", '0.24.3'
end
