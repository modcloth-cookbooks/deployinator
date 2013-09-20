# encoding: utf-8

module Deployinator
  def deployinator_user_env
    @deployinator_user_env ||= {
      'HOME' => node['deployinator']['home'],
      'PATH' => %W(
        #{node['deployinator']['home']}/.rbenv/bin
        #{node['deployinator']['home']}/.rbenv/shims
        #{node['deployinator']['home']}/.rbenv/plugins/ruby-build/bin
        #{node['deployinator']['home']}/bin
        /opt/local/bin
        /opt/local/sbin
        /usr/bin
        /usr/sbin
        /bin
        /sbin
      ).join(':')
    }
  end
end

Chef::Recipe.send(:include, Deployinator)
Chef::Resource.send(:include, Deployinator)
