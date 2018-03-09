# -*- mode: ruby -*-
# vi: set ft=ruby :

# 192.168.88.11-13, set root password to 1
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "ubuntu/xenial64"
      # hack to make ansible set 192.168.88 addresses as a default instead of NAT 10.0.2.15
      node.vm.provision :shell, inline: "route add -net 8.8.8.8 netmask 255.255.255.255 enp0s8"
      node.vm.network "private_network", ip: "192.168.88.1#{i}"
      node.vm.hostname = "node-#{i}"
      node.vm.provision :shell, inline: "echo 'root:1' | chpasswd; sed 's/PermitRootLogin.*/PermitRootLogin yes/' -i /etc/ssh/sshd_config; systemctl restart ssh"
      node.vm.provision :shell, inline: "sed 's/.*node-.*/192\.168\.88\.1#{i} node-#{i}/' -i /etc/hosts"
      node.vm.provision :shell, inline: "echo 'nameserver 8.8.4.4' > /etc/resolv.conf"
      node.vm.provision :shell, inline: "apt-get update && apt-get install python -y"
    end
  end
end
