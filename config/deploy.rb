require "bundler/capistrano"
require "whenever/capistrano"

set :application, "ladder"
set :repository,  "git@github.com:proglottis/ladder.git"

set :scm, :git
set :branch, "master"

set :deploy_to, "/srv/ladder"

server "ladder.nothing.co.nz", :app, :web, :db, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
