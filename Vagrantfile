# encoding: utf-8

$ubuntu_inline_script = <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -qq
apt-get install -y -qq git build-essential

if [ ! -d /tmp/example-app/.git ] ; then
  pushd /tmp
  git clone https://github.com/etsy/deployinator.git example-app
fi

chown -R deployinator:deployinator /tmp/example-app || true
EOF

Vagrant.configure('2') do |config|
  config.vm.hostname = 'deployinator-berkshelf'
  config.vm.box = 'canonical-ubuntu-12.04'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network :private_network, ip: '33.33.33.10'

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provision :shell, inline: $ubuntu_inline_script
  config.vm.provision :chef_solo do |chef|
    chef.log_level = ENV['DEBUG'] ? :debug : :info
    chef.json = {
      'deployinator' => {
        'instances' => {
          'example-app' => {
            'git_repository' => '/tmp/example-app',
            'git_revision' => 'master'
          }
        }
      }
    }
    chef.run_list = [
      'recipe[deployinator::default]'
    ]
  end
end
