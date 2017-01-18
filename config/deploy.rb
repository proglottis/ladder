set :application, 'ladders'
set :repo_url, 'git@github.com:proglottis/ladder.git'
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :pty is false
# set :pty, true

append :linked_files, 'config/database.yml', 'config/secrets.yml'
set :keep_releases, 5

namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'sidekiq' | xargs kill -USR1") 
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :initctl, :restart, :worker
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'
