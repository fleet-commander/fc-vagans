#!/bin/bash
PKGS="ansible libvirt vagrant vagrant-libvirt vagrant-hostmanager libselinux-python nss-tools"

for i in $PKGS; do
  if o=`rpm -q $i` ; then
    sudo dnf install -y $PKGS
    break
  fi
done

systemctl is-active --quiet libvirtd
if [ $? -ne 0 ]; then
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd
fi

set -e
vagrant up --no-provision
vagrant provision

echo
echo "The Domain admin password is 'DMSecret456'"
echo "The FreeIPA web UI is: https://master.ipa.example/"
echo
echo "The Cockpit/Fleet Commander admin password is 'Secret123'"
echo "The cockpit URL is: https://master.ipa.example:9090/"
echo
echo "In case you need to ssh to the machines, simply do:"
echo "`vagrant ssh ipaclient`, to connect to the client machine"
echo "`vagrant ssh ipamaster`, to connect to the master machine"
