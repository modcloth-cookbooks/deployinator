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

service_provider = value_for_platform(
  'smartos' => {
    'default' => Chef::Provider::Service::Solaris
  },
  'ubuntu' => {
    'default' => Chef::Provider::Service::Upstart
  }
)

service node['deployinator']['service_name'] do
  provider service_provider
  supports enable: true, start: true, restart: true, stop: true
  action :nothing
end

smf node['deployinator']['service_name'] do
  user node['deployinator']['user']
  group node['deployinator']['group']
  start_command "bundle exec rackup " <<
                  "-p #{node['deployinator']['http_port']} " <<
                  "-E #{node['deployinator']['rack_env']} " <<
                  node['deployinator']['rackup_options']
  stop_command ':kill'
  restart_command ':kill HUP'
  working_directory "#{node['deployinator']['home']}/current"
  environment deployinator_user_env
  notifies :enable, "service[#{node['deployinator']['service_name']}]"
  notifies :start, "service[#{node['deployinator']['service_name']}]"
  only_if { platform?('smartos') }
end

template '/etc/init/deployinator.conf' do
  source node['deployinator']['upstart_template_file']
  cookbook node['deployinator']['upstart_template_cookbook']
  variables(
    node['deployinator'].to_hash.merge(
      cwd: "#{node['deployinator']['home']}/current",
      env: deployinator_user_env
    )
  )
  notifies :enable, "service[#{node['deployinator']['service_name']}]"
  notifies :start, "service[#{node['deployinator']['service_name']}]"
  only_if { platform?('ubuntu') }
end

deploy_revision node['deployinator']['home'] do
  user node['deployinator']['user']
  group node['deployinator']['group']
  repo node['deployinator']['repository']
  revision node['deployinator']['revision']
  migrate false

  symlink_before_migrate.clear
  create_dirs_before_symlink.clear

  purge_before_symlink << 'vendor/bundle'
  symlinks['vendor/bundle'] = 'vendor/bundle'

  before_migrate do
    current_release = release_path

    bash "bundle for deployinator #{node['deployinator']['revision']}" do
      cwd current_release
      code 'bundle install --deployment'
      environment deployinator_user_env
    end
  end

  notifies :restart, "service[#{node['deployinator']['service_name']}]"

  action node['deployinator']['deploy_action'].to_sym
  only_if do
    node['deployinator']['repository'] && node['deployinator']['revision']
  end
end
