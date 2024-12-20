$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/participatory_processes_extended/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "decidim-participatory_processes_extended"
  spec.version     = Decidim::ParticipatoryProcessesExtended.version
	spec.summary     = "Summary of Decidim::ParticipatoryProcessesExtended."
	spec.description = "Description of Decidim::ParticipatoryProcessesExtended."
	spec.license     = "MIT"
  spec.authors = [""]
  spec.email = []
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "decidim-core", '0.24.3'

  spec.add_development_dependency "sqlite3"
end
