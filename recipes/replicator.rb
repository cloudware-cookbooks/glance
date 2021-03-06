#
# Cookbook Name:: glance
# Recipe:: replicator
#
# Copyright 2012, Rackspace US, Inc.
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

if Chef::Config[:solo]
  Chef::Application.fatal! "This recipe uses search. Chef Solo does not support search."
end

api_nodes = search(:node, "chef_environment:#{node.chef_environment} AND roles:glance-api").map { |n| n["hostname"] }.join(",")

cookbook_file "/var/lib/glance/glance-image-sync.py" do
  source "glance-image-sync.py"
  owner "glance"
  group "glance"
  mode "0755"
end

template "/etc/glance/glance-image-sync.conf" do
  source "glance-image-sync.conf.erb"
  owner "glance"
  group "glance"
  mode "0600"
  variables(:api_nodes => api_nodes)
end

cron "glance-image-sync" do
  minute "*/#{node['glance']['replicator']['interval']}"
  command "/var/lib/glance/glance-image-sync.py both"
end

# clean up previous replicator
file "/var/lib/glance/glance-replicator.sh" do
  action :delete
end

cookbook_file "/var/lib/glance/glance-replicator.py" do
  action :delete
end

cron "glance-replicator" do
  action :delete
end
