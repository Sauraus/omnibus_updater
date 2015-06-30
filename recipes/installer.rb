#
# Cookbook Name:: omnibus_updater
# Recipe:: installer
#
# Copyright 2014, Heavy Water Ops, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'omnibus_updater'
remote_path = node[:omnibus_updater][:full_url].to_s

file '/tmp/nocheck' do
  content 'conflict=nocheck\naction=nocheck'
  only_if { node['os'] =~ /^solaris/ }
end

service 'chef-client' do
  action :nothing
end

ruby_block 'omnibus chef killer' do
  block do
    raise 'New omnibus chef version installed. Killing Chef run!'
  end
  action :nothing
  only_if { node[:omnibus_updater][:kill_chef_on_upgrade] }
end

case File.extname(remote_path)
  when '.sh'
    bash File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path)) do
      subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
      notifies :restart, resources(:service => 'chef-client'), :immediately if node[:omnibus_updater][:restart_chef_service]
      notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
  when '.dmg'
    dmg_package 'Chef Client' do
      volumes_dir 'Chef Client'
      app File.basename(remote_path, '.dmg')
      file File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
      type 'pkg'
      action :install
      subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
      notifies :restart, resources(:service => 'chef-client'), :immediately if node[:omnibus_updater][:restart_chef_service]
      notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
  else
    package 'chef' do
      action :upgrade
      version node['omnibus_updater']['version']
      source File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
      subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
      notifies :restart, resources(:service => 'chef-client'), :immediately if node[:omnibus_updater][:restart_chef_service]
      notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
end

include_recipe 'omnibus_updater::old_package_cleaner'
