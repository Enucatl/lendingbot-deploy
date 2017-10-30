set :application, 'lendingbot'
set :repo_url, 'https://github.com/BitBotFactory/poloniexlendingbot.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app

set :deploy_to, "/home/#{ENV['USER']}/poloniexlendingbot"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :config_files, %w{default.cfg lendingbot_init.sh}
set :symlinks, []
set :executable_config_files, %w{lendingbot_init.sh}

# Default value for :linked_files is []
set :linked_files, %w{config/default.cfg}

# Default value for linked_dirs is []
set :linked_dirs, %w{tmp/pids tmp/logs}

#Default value for default_env is {}
set :default_env, {
  path: "/opt/puppetlabs/bin:${PATH}"
}

# Default value for keep_releases is 5
# set :keep_releases, 5
#
before "deploy", "deploy:setup_config"
