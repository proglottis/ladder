set :application, 'ladders'
set :repo_url, 'git@github.com:proglottis/ladder.git'
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :pty is false
# set :pty, true

append :linked_files, 'config/database.yml', 'config/secrets.yml'
set :keep_releases, 5
