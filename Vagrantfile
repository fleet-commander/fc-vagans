# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"

DOMAIN="ipa.example"

HERE = File.dirname(__FILE__)
ENV['ANSIBLE_CONFIG'] = "#{HERE}/ansible/ansible.cfg"

# Workaround for ssh problem with ED25519 curve
# SSH not up: #<Vagrant::Errors::NetSSHException: An error occurred in the underlying SSH library that Vagrant uses.
# curve name mismatched
if ENV.has_key?('SSH_AUTH_SOCK')
    ENV.delete('SSH_AUTH_SOCK')
end

Vagrant.configure(2) do |config|
    config.vm.box = "fleet-commander/f27"
    # no rsync, Ansible playbook syncs files manually
    config.vm.synced_folder ".", "/vagrant", disabled: true

    if Vagrant.has_plugin?("vagrant-hostmanager")
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.manage_guest = false
    end

    config.vm.provider :libvirt do |domain|
        domain.memory = 1536
        domain.cpus = 2
        domain.graphics_type = 'spice'
        domain.video_type = 'qxl'
        domain.cpu_mode = 'host-passthrough'
    end

    config.vm.define "ipaclient" do |host|
        host.vm.hostname = "client.#{DOMAIN}"
    end

    # Vagrant's parallized Ansible is just too fragile. Use one instance
    # of Ansible with limit=all and let Ansible take care of parallel
    # execution. It makes the output more readable, too.
    config.vm.define "ipamaster" do |host|
        host.vm.provider :libvirt do |domain|
            domain.memory = 2048
        end
        host.vm.hostname = "master.#{DOMAIN}"
        host.vm.provision "ansible" do |ansible|
            ansible.limit = "all"
            ansible.playbook = "ansible/fleet-commander-playbook.yml"
            ansible.groups = {
                "ipaserver_master" => ["ipamaster"],
                "ipa_client" => ["ipaclient"],
            }

            ansible.verbose = 'vv'
            # network: Don't use network (no DNS forwarder, no package installations)
            # ipa-install: skip installation (ipa-server-install, ipa-client-install)
            ansible.skip_tags = [
                #'network',
                #'ipa-install',
                'dummy',
            ]
            # ansible.tags = ['bootstrap', 'common']
            ansible.extra_vars = {
                "ipa_data_dir" => HERE + '/inventory',
                "ipa_script_dir" => HERE + '/bin',
                "ipa_rpm_dir" => HERE + '/rpms',
                "package_install" => false,
                "package_upgrade" => false,
                "custom_rpms" => false,
                "coprs_enabled" => [],
            }
        end
    end
end
