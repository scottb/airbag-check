# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "ubuntu/xenial64"

  setup_script = <<-SHELL
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install -qqy git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs ruby-dev ruby-bundler google-chrome-stable
  SHELL

  virtualbox_script = setup_script + <<-SHELL
    cd /vagrant
    bundle install --quiet
  SHELL

  # /var/lib/gems/2.3.0/gems/puma-3.10.0
  aws_script = setup_script + <<-SHELL
    cd /vagrant
    bundle --quiet
    PUMA_TOOLS=$(bundle show puma)/tools/jungle/init.d
    sudo cp $PUMA_TOOLS/puma /etc/init.d/
    sudo chmod +x /etc/init.d/puma
    sudo update-rc.d -f puma defaults
    sudo cp $PUMA_TOOLS/run-puma /usr/local/bin
    sudo chmod +x /usr/local/bin/run-puma
    sudo touch /etc/puma.conf
    sudo /etc/init.d/puma add /vagrant ubuntu /vagrant/config/puma-production.rb /vagrant/log/puma.log
    sudo service puma start
  SHELL

  config.vm.provider :virtualbox do |vb, override|
    vb.name = "Airbag API"
    override.vm.network "forwarded_port", guest: 3000, host: 3000
    override.vm.network "private_network", ip: "192.168.33.10"
    override.vm.provision "shell", inline: virtualbox_script
  end

  # If the AWS provider fails, running the above script manually
  # should work, after first performing a manual rsync, as follows:
  #   sudo mkdir /vagrant
  #   sudo chown ubuntu /vagrant
  #   rsync -aqz --exclude=.git --exclude=.vagrant ./ airbag:/vagrant/
  config.vm.provider :aws do |aws, override|
    aws.keypair_name = "scottb-key-pair-useast"
    aws.security_groups = ["airbag-api"]
    aws.ami = "ami-cd0f5cb6"
    aws.instance_type = "t2.micro"
    override.vm.box = "aws-dummy"
    override.ssh.username = "ubuntu"
    override.ssh.proxy_command = "ssh -q -J us-east"
    override.ssh.private_key_path = "/Users/scottb/.ssh/scottb-key-pair-useast.pem"
    override.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: %w[.git]
    override.vm.provision "shell", inline: aws_script
  end
end
