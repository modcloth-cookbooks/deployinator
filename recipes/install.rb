# encoding: utf-8
#
# Cookbook Name:: deployinator
# Recipe:: install
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

deployinator_home = deployinator_user_env['HOME']
rbenv_version = node['deployinator']['rbenv']['global_version']
rbenv_version_prefix = "#{deployinator_home}/.rbenv/versions/#{rbenv_version}"
user_group = "#{node['deployinator']['user']}:#{node['deployinator']['group']}"

group node['deployinator']['group'] do
  gid node['deployinator']['gid']
end

user node['deployinator']['user'] do
  gid node['deployinator']['group']
  supports manage_home: true
  home node['deployinator']['home']
  shell node['deployinator']['shell']
end

template "#{node['deployinator']['home']}/.bashrc" do
  source 'dotbashrc.sh.erb'
  owner node['deployinator']['user']
  group node['deployinator']['group']
  variables(env: deployinator_user_env)
  mode 0640
end

template "#{node['deployinator']['home']}/.bash_profile" do
  source 'dotbash_profile.sh.erb'
  owner node['deployinator']['user']
  group node['deployinator']['group']
  mode 0640
end

template "#{node['deployinator']['home']}/.gemrc" do
  source 'dotgemrc.yml.erb'
  owner node['deployinator']['user']
  group node['deployinator']['group']
  mode 0640
end

git "#{node['deployinator']['home']}/.rbenv" do
  user node['deployinator']['user']
  group node['deployinator']['group']
  repository node['deployinator']['rbenv']['repository']
  revision node['deployinator']['rbenv']['revision']
  action :sync
end

directory "#{node['deployinator']['home']}/.rbenv/plugins" do
  owner node['deployinator']['user']
  group node['deployinator']['group']
  mode 0750
end

git "#{node['deployinator']['home']}/.rbenv/plugins/ruby-build" do
  user node['deployinator']['user']
  group node['deployinator']['group']
  repository node['deployinator']['ruby_build']['repository']
  revision node['deployinator']['ruby_build']['revision']
  action :sync
end

execute 'rbenv rehash' do
  user node['deployinator']['user']
  group node['deployinator']['group']
  environment deployinator_user_env
  action :nothing
end

node['deployinator']['packages'].each { |n| package n }

bash 'get ruby build dependencies' do
  code 'apt-get update -y -qq && apt-get build-dep -y ruby1.9.3'
  only_if { platform?('ubuntu') }
end

bash "build #{node['deployinator']['rbenv']['global_version']}" do
  code "ruby-build '#{rbenv_version}' #{rbenv_version_prefix}"
  notifies :run, 'execute[rbenv rehash]'
  environment deployinator_user_env
  user node['deployinator']['user']
  group node['deployinator']['group']
  not_if "#{rbenv_version_prefix}/bin/ruby -ryaml -e 'puts YAML.load(\"---\")'"
end

file "#{node['deployinator']['home']}/.rbenv/version" do
  content "#{node['deployinator']['rbenv']['global_version']}\n"
  owner node['deployinator']['user']
  group node['deployinator']['group']
  mode 0640
end

node['deployinator']['gems'].each do |gem_name, gem_version|
  gem_package gem_name do
    version gem_version
    gem_binary "#{rbenv_version_prefix}/bin/gem"
    options('--no-ri --no-rdoc')
    notifies :run, 'execute[rbenv rehash]'
  end
end

bash "ensure #{node['deployinator']['user']} owns #{rbenv_version_prefix}" do
  code "chown -R #{user_group} #{rbenv_version_prefix}"
end
