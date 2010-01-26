require 'palmtree/recipes/mongrel_cluster'
set :use_sudo, false
set :application, 'example_api' 
set :scm, 'git'
set :repository, 'ssh://git@git.sc.realtravel.com/git/example_api.git'
ssh_options[:port] = 65522
ssh_options[:username] = "capi"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
#set :deploy_via, :remote_cache
set :branch, "master"
set :scm_password, "none"
set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" }

puts "*** Deploying to the \033[6;41m  PRODUCTION  \033[0m servers!"
set  :deploy_to,   "/home/web/#{application}"
role :app,         "67.207.136.186"
role :web,         "67.207.136.186"
role :db,          "67.207.136.186", :primary => true


