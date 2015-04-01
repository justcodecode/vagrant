# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network :forwarded_port, guest: 11211, host: 11211

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.2.2"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  #config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder "~/depot", "/opt/depot", type: "nfs"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider :virtualbox do |box|
    if RUBY_PLATFORM =~ /linux/
      cpus = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    elsif RUBY_PLATFORM =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    else
      cpus = 2
      mem = 4096
    end

    box.customize ["modifyvm", :id, "--cpus", cpus]
    box.customize ["modifyvm", :id, "--memory", mem]
    box.customize ["modifyvm", :id, "--ioapic", "on"]
    # This setting makes it so that network access from inside the vagrant guest is able to resolve DNS using the hosts VPN connection.
    box.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

$script = <<SCRIPT
dpkg -s ansible || (sudo apt-add-repository -y ppa:ansible/ansible && sudo apt-get -y -q update && sudo apt-get -y install ansible)
ansible-playbook --sudo /vagrant/ansible/playbook.yml
SCRIPT

  config.vm.provision "shell", inline: $script
end
