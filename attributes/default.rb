# encoding: utf-8

default['deployinator']['user'] = 'deployinator'
default['deployinator']['group'] = 'deployinator'
default['deployinator']['gid'] = 1306
default['deployinator']['home'] = '/opt/deployinator'
default['deployinator']['shell'] = '/bin/bash'
default['deployinator']['repository'] = nil
default['deployinator']['revision'] = nil
default['deployinator']['http_port'] = 13060
default['deployinator']['deploy_action'] = 'deploy'
default['deployinator']['service_name'] = nil
default['deployinator']['upstart_template_file'] = 'deployinator.conf.erb'
default['deployinator']['upstart_template_cookbook'] = 'deployinator'
