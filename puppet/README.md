## Prepare Development Environments 
```
Ansible version(> 2.2)
git
Virtual Box
vagrant box: centos 6.6
```

## Download Code
```
> git clone https://github.com/pjhu/ansible-puppet.git
```

## Create Virtual Machine
```
> vagrant up
```

## Install Puppet Server
```
> cd ansible_puppet
> ansible-playbook -i playbooks/profiles/local/hosts playbooks/puppet-server.yml -vvvv
```

## Install Puppet Agent
```
> cd ansible_puppet
> ansible-playbook -i playbooks/profiles/local/hosts playbooks/puppet-agent.yml -vvvv
```

## Agent Auto Sign
```
sudo puppet cert list -a
```

## Create Module
```
> cd /etc/puppet/modules
> puppet module generate ws-helloworld
> vi ws-helloworld/manifests/init.pp

  class ws-helloworld {
    exec {'hello world':
      path => $::path,
      command => 'echo HelloWorld',
      logoutput => true,
    }
  }

> puppet module list
> vi /etc/puppet/manifests/site.pp

  node 'puppetagent.corporate.thoughtworks.com' {
    include ws-helloworld
  }
```

## Add Facter
```
> login agent machine
> mkdir /var/lib/puppet/facts
> vi hello_world.rb

  module Facter::Util::HelloWorld
    class << self
    def get_hello_world
      "hello world"
    end
    end
  end

  Facter.add(:hello_world) do
    setcode { Facter::Util::HelloWorld.get_hello_world }
  end

> faster -p
```
## Puppet Agent Sync
```
puppet-agent -t -v
```
