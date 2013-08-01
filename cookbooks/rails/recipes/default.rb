include_recipe "nginx"
include_recipe "unicorn"

package "libsqlite3-dev"
gem_package "bundler"

# name        : this is your application name
# app_root    : where is your store app path
# path_root   : root
# user        : username of server
# server_names: your domain name of your app
# environment : environment of your app (ex: staging , production , test, development ...).

# common = {:name => "visviet", :app_root => "/home/rubyviet/www/visviet", :environment => "staging", :path_root => "/home/rubyviet", :user => "rubyviet", :server_names => "vis.vn www.vis.vn www.vis.com"}

# directory node[:rails][:app_root] do
#   owner node[:rails][:user]
#   recursive true
# end
# 
# directory "#{common[:path_root]}/www" do
#   owner common[:user]
# end
# 
# directory common[:app_root]+"/shared" do
#   owner common[:user]
# end
# 
%w(config log tmp sockets pids).each do |dir|
  directory "#{node[:rails][:app_root]}/shared/#{dir}" do
    owner node[:rails][:user]
    recursive true
    mode 0755
  end
end

template node[:rails][:data_config_path] do
  mode 0755
  source "database.conf.erb"
  # variables common
  variables({
    :env => node[:rails][:environment],
    :db_name => node[:rails][:db_name]
  })
end

# template "#{node[:unicorn][:config_path]}/#{common[:name]}.conf.rb" do
#   mode 0644
#   source "unicorn.conf.erb"
#   variables common
# end

# nginx_config_path = "/etc/nginx/sites-available/#{common[:name]}.conf"

template node[:rails][:nginx_config_path] do
  mode 0644
  source "nginx.conf.erb"
  variables({
    :app_name => node[:rails][:app_name],
    :server_name => node[:rails][:server_name],
    :app_root => node[:rails][:app_root]
  })
  # variables common.merge(:server_names => node[:rails][:server_name])
  notifies :reload, "service[nginx]"
end

nginx_site node[:rails][:app_name] do
  config_path node[:rails][:nginx_config_path]
  action :enable
end