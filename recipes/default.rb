#
# Cookbook Name:: keepalived
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

package "keepalived" do
  action :install
end

directory "/etc/keepalived/conf.d" do
  action :create
  owner "root"
  group "root"
  mode "0775"
end

if node['keepalived']['shared_address']
  include_recipe 'sysctl'
  sysctl "net.ipv4.ip_forward" do  value 1  end
end

template "keepalived.conf" do
  path "/etc/keepalived/keepalived.conf"
  source "keepalived.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

node["keepalived"]["vs"].each_pair do |name, val|
  keepalived_virtual_server name do
    vs_listen_ip val['vs_listen_ip']
    vs_listen_port val['vs_listen_port']
    delay_loop val['delay_loop']
    lb_algo val['lb_algo']
    lb_kind val['lb_kind']
    vs_protocol val['vs_protocol']
    real_servers val['real_servers']
    action :create
  end
end

node["keepalived"]["vrrp"].each_pair do |name, val|
  keepalived_vrrp name do
    interface val['interface']
    virtual_router_id val['virtual_router_id']
    state val['state']
    noprempt val['noprempt']
    priority val['priority']
    virtual_ipaddress val['virtual_ipaddress']
    auth_type val['auth_type']
    auth_pass val['auth_pass']
    action :create
  end
end

node['keepalived']['check_scripts'].each_pair do |name, script|
  keepalived_chkscript name do
    script script['script']
    interval script['interval']
    weight script['weight']
    action :create
  end
end

node['keepalived']['instances'].each_pair do |name, instance|
  keepalived_vrrp name do
    interface instance['interface']
    virtual_router_id node['keepalived']['instance_defaults']['virtual_router_id']
    noprempt false
    priority node['keepalived']['instance_defaults']['priority']
    virtual_ipaddress Array(instance['ip_addresses'])
    if instance['track_script']
      track_script instance['track_script']
    end
    if instance['auth_type']
      auth_type instance['auth_type']
      auth_pass instance['auth_pass']
    end
    action :create
  end
end

service "keepalived" do
  supports :restart => true, :status => true
  action [:enable, :start]
  subscribes :restart, "template[keepalived.conf]"
end
