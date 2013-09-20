# encoding: utf-8

$ubuntu_inline_script = <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq git build-essential
EOF

Vagrant.configure('2') do |config|
  config.vm.hostname = 'deployinator-berkshelf'
  config.vm.box = 'canonical-ubuntu-12.04'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network :private_network, ip: '33.33.33.10'
  config.vm.network :forwarded_port, guest: 13060, host: 23060

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provision :shell, inline: $ubuntu_inline_script
  config.vm.provision :chef_solo do |chef|
    chef.log_level = ENV['DEBUG'] ? :debug : :info
    chef.json = {
      'deployinator' => {
        'repository' => 'https://github.com/etsy/deployinator.git',
        'revision' => 'master',
        'environment' => {
          'HTTP_X_USERNAME' => 'derp',
          'HTTP_X_GROUPS' => 'derp'
        }
      }
    }
    chef.run_list = [
      'recipe[deployinator::default]'
    ]
  end
end
