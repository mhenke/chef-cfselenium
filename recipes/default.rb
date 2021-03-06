#
# Cookbook Name:: CFSelenium
# Recipe:: default
#
# Copyright 2013, Mike Henke
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install the unzip package
package "unzip" do
  action :install
end

file_name = node['CFSelenium']['download']['url'].split('/').last

node.set['CFSelenium']['owner'] = node['cf10']['installer']['runtimeuser'] if node['CFSelenium']['owner'] == nil

# Download CFSelenium
remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
  source "#{node['CFSelenium']['download']['url']}"
  action :create_if_missing
  mode "0744"
  owner "root"
  group "root"
  not_if { File.directory?( "#{node['CFSelenium']['install_path']}/#{file_name}" ) }
end

# Create the target install directory if it doesn't exist
directory "#{node['CFSelenium']['install_path']}" do
  owner node['CFSelenium']['owner']
  group node['CFSelenium']['group']
  mode "0755"
  recursive true
  action :create
  not_if { File.directory?("#{node['CFSelenium']['install_path']}") }
end

# Extract archive
script "install_CFSelenium" do
  interpreter "bash"
  user "root"
  cwd "#{Chef::Config['file_cache_path']}"
  code <<-EOH
unzip #{file_name}
mv CFSelenium-master #{node['CFSelenium']['install_path']}/CFSelenium
chown -R #{node['CFSelenium']['owner']}:#{node['CFSelenium']['group']} #{node['CFSelenium']['install_path']}/CFSelenium
EOH
  not_if { File.directory?("#{node['CFSelenium']['install_path']}/CFSelenium") }
end

coldfusion10_config "extensions" do
  action :set
  property "mapping"
  args ({ "mapName" => "/CFSelenium",
          "mapPath" => "#{node['CFSelenium']['install_path']}/CFSelenium"})
end

# Create a global apache alias if desired
template "#{node['apache']['dir']}/conf.d/global-CFSelenium-alias" do
  source "global-CFSelenium-alias.erb"
  owner node['apache']['user']
  group node['apache']['group']
  mode "0755"
  variables(
    :url_path => '/CFSelenium',
    :file_path => "#{node['CFSelenium']['install_path']}/CFSelenium"
  )
  only_if { node['CFSelenium']['create_apache_alias'] }
  notifies :restart, "service[apache2]"
end

# Clean Up
file "#{Chef::Config['file_cache_path']}/#{file_name}" do
  action :delete
end

directory "#{node['CFSelenium']['install_path']}/CFSelenium-master" do
  recursive true
  action :delete
end