require 'palmtree/recipes/mongrel_cluster'
set :use_sudo, false
set :application, 'example_api' 
set :scm, 'git'
set :repository, 'ssh://git@git.sc.realtravel.com/git/example_api.git'
ssh_options[:port] = 65522
ssh_options[:username] = "capi"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :branch, "master"
set :scm_password, "none"
set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" }

puts "*** Deploying to the \033[6;41m  PRODUCTION  \033[0m servers!"
set  :deploy_to,   "/home/web/#{application}"
role :app,         "67.207.136.186"
role :web,         "67.207.136.186"
role :db,          "67.207.136.186", :primary => true

namespace :deploy do

  desc "Move configurations around"
  task :perform_configuration, :roles => [:app, :web] do

    desc "Symlink the database.yml"
    run "if [ ! -f #{deploy_to}/shared/database.yml ]; then cp -pf #{release_path}/config/database.yml.example #{deploy_to}/shared/database.yml; fi;"
    run "if [ ! -f #{release_path}/config/database.yml ]; then ln -sf #{deploy_to}/shared/database.yml #{release_path}/config/database.yml; fi;"

    desc "Symlink the hotels api settings"
    run "if [ ! -f #{deploy_to}/shared/hotel_api.yml ]; then cp -pf #{release_path}/config/hotel_api.yml.example #{deploy_to}/shared/hotel_api.yml; fi;"
    run "if [ ! -f #{release_path}/config/hotel_api.yml ]; then ln -sf #{deploy_to}/shared/hotel_api.yml #{release_path}/config/hotel_api.yml; fi;"

    desc "Symlink the mongrel cluster"
    run "if [ ! -f #{deploy_to}/shared/mongrel_cluster.yml ]; then cp -pf #{release_path}/config/mongrel_cluster.yml.example #{deploy_to}/shared/mongrel_cluster.yml; fi;"
    run "if [ ! -f #{release_path}/config/mongrel_cluster.yml ]; then ln -sf #{deploy_to}/shared/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml; fi;"
  
  end

end

after "deploy:update_code", "deploy:perform_configuration"
