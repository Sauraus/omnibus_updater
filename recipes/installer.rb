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
remote_path = node['omnibus_updater']['full_url'].to_s

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
  only_if { node['omnibus_updater']['kill_chef_on_upgrade'] }
end

case ::File.extname(remote_path)
  when '.sh'
    bash ::File.join(node['omnibus_updater']['cache_dir'], ::File.basename(remote_path)) do
      action :run
      subscribes :run, "remote_file[omnibus_remote [#{File.basename(remote_path)}]]", :immediately
      notifies :restart, 'service[chef-client]', :immediately if node['omnibus_updater']['restart_chef_service']
      notifies :create, 'ruby_block[omnibus chef killer]', :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
  when '.dmg'
    dmg_package 'Chef Client' do
      volumes_dir 'Chef Client'
      app ::File.basename(remote_path, '.dmg')
      file ::File.join(node['omnibus_updater']['cache_dir'], ::File.basename(remote_path))
      type 'pkg'
      action :install
      subscribes :install, "remote_file[omnibus_remote [#{File.basename(remote_path)}]]", :immediately
      notifies :restart, 'service[chef-client]', :immediately if node['omnibus_updater']['restart_chef_service']
      notifies :create, 'ruby_block[omnibus chef killer]', :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
  else
    package 'chef' do
      allow_downgrade true if node['platfrom'].eql?('centos')
      installer_type :msi if node['platfrom'].eql?('windows')
      version node['omnibus_updater']['version'] unless node['platfrom'].eql?('windows')
      source ::File.join(node['omnibus_updater']['cache_dir'], ::File.basename(remote_path))
      provider value_for_platform_family(debian: Chef::Provider::Package::Dpkg)
      action node['platfrom'].eql?('windows') ? :install : :upgrade
      subscribes :upgrade, "remote_file[omnibus_remote [#{File.basename(remote_path)}]]", :immediately
      notifies :restart, 'service[chef-client]', :immediately if node['omnibus_updater']['restart_chef_service']
      notifies :create, 'ruby_block[omnibus chef killer]', :immediately
      only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
    end
end

include_recipe 'omnibus_updater::old_package_cleaner'
