require "bundler/capistrano"

set :application, "ladder"
set :repository,  "git@github.com:proglottis/ladder.git"

set :scm, :git
set :branch, "master"

set :deploy_to, "/srv/ladder"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

server "ladders.pw", :app, :web, :db, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

before "deploy:finalize_update", "customs:config"

namespace(:customs) do
  task :config, :roles => :app do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/application.yml #{release_path}/config/application.yml"
  end
end
