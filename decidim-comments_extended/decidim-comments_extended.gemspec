# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'decidim/comments_extended/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::CommentsExtended.version
  s.license = 'MIT'
  s.homepage = 'https://github.com/decidim/decidim-remarks'
  s.required_ruby_version = '>= 2.7'
  s.authors = [""]
  s.email = []
  s.name = 'decidim-comments_extended'
  s.summary = 'A decidim comments extension module'
  s.description = 'MOdule that extends Decdim Comments functionalities'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'decidim-admin', '0.24.3'
  s.add_dependency 'decidim-core', '0.24.3'
  s.add_dependency 'decidim-participatory_processes', '0.24.3'

  s.add_development_dependency 'sqlite3'
end
