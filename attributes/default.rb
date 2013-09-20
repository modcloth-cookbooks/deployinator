# encoding: utf-8

default['deployinator']['user'] = 'deployinator'
default['deployinator']['group'] = 'deployinator'
default['deployinator']['gid'] = 1306
default['deployinator']['home'] = '/opt/deployinator'
default['deployinator']['shell'] = '/bin/bash'
default['deployinator']['repository'] = nil
default['deployinator']['revision'] = nil
default['deployinator']['http_port'] = 13060
default['deployinator']['rackup_options'] = ''
default['deployinator']['rack_env'] = 'production'
default['deployinator']['deploy_action'] = 'deploy'
default['deployinator']['service_name'] = 'deployinator'
default['deployinator']['upstart_template_file'] = 'deployinator.conf.erb'
default['deployinator']['upstart_template_cookbook'] = 'deployinator'
default['deployinator']['packages'] = %w(build-essential libxml2-dev libxslt-dev)
default['deployinator']['environment'] = {}

default['deployinator']['puma']['enabled'] = true
default['deployinator']['puma']['options'] = ''

default['deployinator']['rbenv']['repository'] = 'https://github.com/sstephenson/rbenv.git'
default['deployinator']['rbenv']['revision'] = 'master'
default['deployinator']['rbenv']['global_version'] = '1.9.3-p448'
default['deployinator']['ruby_build']['repository'] = 'https://github.com/sstephenson/ruby-build.git'
default['deployinator']['ruby_build']['revision'] = 'master'

default['deployinator']['gems']['bundler'] = '~> 1.3.5'
default['deployinator']['gems']['json'] = '~> 1.7.7'
default['deployinator']['gems']['mustache'] = nil
default['deployinator']['gems']['open4'] = nil
default['deployinator']['gems']['pony'] = nil
default['deployinator']['gems']['puma'] = '~> 2.6.0'
default['deployinator']['gems']['thin'] = '~> 1.5.1'
default['deployinator']['gems']['rack'] = '~> 1.5.2'
default['deployinator']['gems']['rake'] = nil
default['deployinator']['gems']['sinatra'] = nil
default['deployinator']['gems']['tlsmail'] = nil
