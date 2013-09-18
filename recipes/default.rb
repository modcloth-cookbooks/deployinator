# encoding: utf-8
#
# Cookbook Name:: deployinator
# Recipe:: default
#
# Copyright 2013, ModCloth, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe 'deployinator::install'

is_recent_ubuntu = platform?('ubuntu') &&
  node['platform_version'].to_f >= 10.04

smf node['deployinator']['service_name'] do
  user node['deployinator']['user']
  group node['deployinator']['group']
  start_command "unicorn -p #{ensure_http_port(node['deployinator']['http_port'])}"
  stop_command ':kill'
  restart_command ':kill HUP'
  working_directory "#{node['deployinator']['home']}/current"
  notifies :enable, "service[#{node['deployinator']['service_name']}]"
  notifies :start, "service[#{node['deployinator']['service_name']}]"
  only_if { platform?('smartos') }
end

template '/etc/init/deployinator.conf' do
  source node['deployinator']['upstart_template_file']
  cookbook node['deployinator']['upstart_template_cookbook']
  variables(
    port: ensure_http_port(node['deployinator']['http_port']),
    cwd: "#{node['deployinator']['home']}/current"
  )
  notifies :enable, "service[#{node['deployinator']['service_name']}]"
  notifies :start, "service[#{node['deployinator']['service_name']}]"
  only_if { is_recent_ubuntu }
end

service "service[#{node['deployinator']['service_name']}]" do
  provider is_recent_ubuntu ? Chef::Provider::Service::Upstart : nil
  action :nothing
end

deploy_revision 'deployinator' do
  user node['deployinator']['user']
  group node['deployinator']['group']
  repo node['deployinator']['repo']
  revision node['deployinator']['revision']
  action node['deployinator']['deploy_action'].to_sym
  only_if { node['deployinator']['repo'] && node['deployinator']['revision'] }
end
