set :application, "user_center"
set :repository,  "git://github.com/hlxwell/user_center.git"

set :keep_releases, 5
set :use_sudo, false
set :user, "app"
set :scm, :git
set :branch, "master"
set :rails_env, "production"
set :deploy_to, "/home/app/app"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "46.51.233.241"                          # Your HTTP server, Apache/etc
role :app, "46.51.233.241"                          # This may be the same as your `Web` server
role :db,  "46.51.233.241", :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :init_project do
    run "cd #{release_path}; ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
    # run "cd #{release_path}; bundle install"
    # run "cd #{release_path}; bundle exec rake db:migrate RAILS_ENV=production"
    # run "cd #{release_path}; bundle exec rake assets:precompile RAILS_ENV=production"
  end
end
after "deploy:symlink", "deploy:init_project"