require "pathname"
require "bundler/capistrano"
require "capistrano/ext/multistage"

set :stages       , %w(production)
set :default_stage, "production"

set :application, "bugwatch_dashboard"

set :scm                  , :git
set :repository           , "git@github.com:JacobNinja/#{application}.git"
set :deploy_via           , :remote_cache
set :git_enable_submodules, 1

set :deploy_to, "/var/groupon/fixcache"

set :bundle_flags, "--system" # disable the --deployment flag
set :bundle_dir  , nil         # use the system set of gems
set :bundle_cmd, "LANG='en_US.UTF-8' bundle"

set :user    , "fixcache_deploy"
set :use_sudo, false

set :keep_releases, 5

default_run_options[:pty] = true
ssh_options[:paranoid]    = false

set :shared_config, %w{config/database.yml config/mailer.yml}

namespace :shared_config do
  desc "Uploads local configuration files"
  task :upload do
    fetch(:shared_config).each do |file|
      file = Pathname.new(file)

      filename = file.basename
      directory = file.dirname

      run "mkdir -p '#{shared_path}/#{directory}'"
      put File.read("#{file}"), "#{shared_path}/#{directory}/#{filename}", :mode => 0644
    end
  end

  desc "Symlink local configuration files"
  task :symlink do
    fetch(:shared_config).each do |file|
      file = Pathname.new(file)

      filename = file.basename
      directory = file.dirname

      run "mkdir -p '#{latest_release}/#{directory}'"
      run "ls #{latest_release}/#{file} 2> /dev/null || ln -nfs #{shared_path}/#{directory}/#{filename} #{latest_release}/#{file}"
    end
  end
end

namespace :repos do
  task :symlink do
    run "ln -nfs #{shared_path}/repos #{latest_release}/"
  end
end

set :god_config,   "#{current_path}/config/god/resque.god"
set :god_log,      "#{deploy_to}/shared/log/god.log"
set :god_pid_file, "#{deploy_to}/shared/log/god.pid"

namespace :god do
  desc "start god"
  task :start, :roles => :app do
    run "god -c #{god_config} -l #{god_log} --pid #{god_pid_file}"
  end
  
  desc "stop god"
  task :stop, :roles => :app do
    run "if sudo god status > /dev/null 2>&1; then sudo god quit; else true; fi"
  end
  
  namespace :resque do
    desc "restart resque workers"
    task :restart, :roles => :app do
      run "god restart resque"
    end
    
    desc "stop resque workers"
    task :stop, :roles => :app do
      run "god stop resque; true"
    end
    
    desc "start resque workers"
    task :start, :roles => :app do
      run "god start resque"
    end
    
    desc "show status of resque workers"
    task :status, :roles => :app do
      run "god status resque; true"
    end
  end
end

namespace :deploy do
  task :start do; end
  task :stop  do; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp/restart.txt')}"
  end
  #task :symlink_shared do
  #  run "ln -s #{shared_path}/database.yml #{release_path}/config/"
  #end
end

namespace :assets do
  task :precompile do
    run "bundle exec rake assets:precompile"
  end
end

#before "deploy:restart", "deploy:symlink_shared"

before "deploy:update_code" do
end

after "deploy:update_code" do
   shared_config.symlink
   repos.symlink
   assets.precompile
end
before 'deploy', 'god:stop'
after "deploy:rollback", "god:start"
after "deploy:symlink", "god:start"
after "deploy"            , "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:cleanup", "god:resque:status"
