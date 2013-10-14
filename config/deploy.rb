require 'bundler/capistrano'

set :use_sudo, false
set :application, 'we-frontend'
#set :repo_url, 'git@example.com:me/my_repo.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :scm, :git
set :scm_username, "git"
set :repository, "waste-exemplar-frontend.github.com:EnvironmentAgency/waste-exemplar-frontend.git"
set :user, "poc-rails"
set :deploy_to, "/caci/deploys/we-frontend"

#role :app, "ea-dev"
#role :web, "ea-dev"
#role :db, "ea-dev", :primary => true

# set :format, :prettyset :branch, "master"
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

desc "Deploy to development server"
task :dev do
  set :rails_env, 'development'
  server "ea-dev", :web, :app, :db, :primary => true
end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
