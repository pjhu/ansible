# coding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
  sudo sed -i '/LANG=/c LANG="en_US.UTF-8"' /etc/sysconfig/i18n
  source /etc/sysconfig/i18n
  sudo sed -i '/=enforcing/c SELINUX=disabled' /etc/selinux/config
  sudo reboot
SCRIPT

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end


  cluster = {
    "puppetmaster" => {
        :cpus => 1,
        :mem => 1024,
        :ip => "192.168.57.10",
        :box => "centos6.6",
        :hostname => "puppetmaster",
        :shell => $script
    },
    "puppetagent" => {
        :cpus => 1,
        :mem => 1024,
        :ip => "192.168.57.11",
        :box => "centos6.6",
        :hostname => "puppetagent",
        :shell => $script
    }

  }

  cluster.each_with_index do | (hostname, info), index |
    config.vm.define hostname do | host |
      host.vm.box = info[:box]
      host.vm.hostname = info[:hostname]
      host.vm.provider "virtualbox" do |v|
        v.name   = "WS.#{hostname.downcase}"
        v.cpus   = info[:cpus]
        v.memory = info[:mem]
      end
      host.vm.network "private_network", ip: info[:private_ip] if info[:private_ip]
      host.vm.network "private_network", ip: info[:ip] if info[:ip]
      host.vm.provision "shell", inline: info[:shell] if info[:shell]
    end
  end
end
