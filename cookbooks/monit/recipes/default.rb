#
# Cookbook Name:: monit
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# create mysql.monit in /ect/monit/ directory
template node[:monit][:mysql_monit_config_path] do
  mode 0644
  source "mysql.monit.erb"
end

template node[:monit][:nginx_monit_config_path] do
  mode 0644
  source "nginx.monit.erb"
end

template node[:monit][:unicorn_monit_config_path] do
  mode 0644
  source "unicorn.monit.erb"
  variables({
    :pid_path => node[:monit][:pid_path]
  })
end

#create unicorn executable in /etc/init.d/ directory
template node[:monit][:unicorn_executable_path] do
  mode 0755
  source "unicorn.executable.erb"
  variables({
    :pid_path => node[:monit][:pid_path],
    :user => node[:monit][:user],
    :env => node[:monit][:env],
    :app_root => node[:monit][:app_root]
  })
end


#delete old monitrc
file "/etc/monit/monitrc" do
  action :delete
end
#and create new monitrc and set chmod for this file is -rw------- (chmod 0600)
template node[:monit][:monitrc_config_path] do
  mode 0700
  source "monitrc.conf.erb"
end