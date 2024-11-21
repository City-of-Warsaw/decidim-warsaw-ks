$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/users_extended/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "decidim-users_extended"
  spec.version     = Decidim::UsersExtended.version
  spec.summary     = "Summary of Decidim::UsersExtended."
  spec.description = "Description of Decidim::UsersExtended."
  spec.license     = "MIT"

  spec.authors = [""]
  spec.email = []

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "decidim-core", '0.24.3'
  spec.add_dependency "decidim-assemblies", '0.24.3'

  spec.add_development_dependency "sqlite3"
  # spec.add_development_dependency "decidim-dev", '0.24.3' # TODO: save in a constant
  # spec.add_development_dependency "bootsnap", '~> 1.3'
  # spec.add_development_dependency "faker"
end
