require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)

set :application_name, 'decidim'
set :domain, ''
set :deploy_to, '/var/www/decidim'
set :repository, ''
set :branch, 'develop'
# set :repository, ''
set :rvm_use_path, '/usr/local/rvm/scripts/rvm'

# Optional settings:
set :user, 'deploy'          # Username in the server to SSH to.
# set :port, '30000'           # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')
set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('.env', 'config/master.key')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-2.7.3@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.5.3 --skip-existing}
  # command %{rvm install ruby-2.5.3}
  # command %{gem install bundler}
  command %[mkdir "#{fetch(:shared_path)}/config"]
  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[touch "#{fetch(:shared_path)}/config/secrets.yml"]
  command %[touch "#{fetch(:shared_path)}/config/master.key"]
  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/database.yml' and 'master.key' and 'secrets'."]
end


set :default_stage, 'staging'
desc "Deploys STAGING"
task :staging do
  puts "START STAGING"
  # For system-wide RVM install.
  set :current_stage, 'staging'
  set :deploy_to, '/var/www/decidim'
  set :branch, 'develop'
  set :rails_env, 'staging'
end

desc "Deploys PROD1"
task :prod1 do
  puts "START PROD1"
  set :domain, ''
  # For system-wide RVM install.
  set :current_stage, 'prod1'
  set :deploy_to, '/var/www/decidim'
  set :branch, 'master'
  set :rails_env, 'production'
end

desc "Deploys PROD2"
task :prod2 do
  puts "START PROD2"
  set :domain, ''
  # For system-wide RVM install.
  set :current_stage, 'prod2'
  set :deploy_to, '/var/www/decidim'
  set :branch, 'master'
  set :rails_env, 'production'
end




desc "Deploys the current version to the server."
task :deploy do
  invoke fetch(:current_stage, 'staging')
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %[ln -s /var/www/decidim/storage/public/uploads "#{fetch(:current_path)}/public/uploads"]
        command %[ln -s /var/www/decidim/storage/storage "#{fetch(:current_path)}/storage"]
        command %{touch tmp/restart.txt}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
