#!/bin/bash
image=$1
cmds=(
'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config '
'sudo chmod 600 /etc/ssh/sshd_config '
'sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux '
'sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config '
'sudo yum install -y python-virtualenv git vim'
'sudo virtualenv ~/flask'
'source ~/flask/bin/activate; pip install flask requests request pyyaml'
'rm -rf ~/nfv_upgrade_demo; git clone https://github.com/zshi-redhat/nfv_upgrade_demo.git ~/nfv_upgrade_demo'
'sudo cp -rf ~/nfv_upgrade_demo/service/* /etc/systemd/system/'
)

sudo yum install -y libguestfs-tools
sudo systemctl start libvirtd
for c in "${cmds[@]}"
do
    echo "virt-customize -a $image --run-command ${c}"
    virt-customize -a $image --run-command "${c}"
done

echo "virt-customize -a $image --root-password password:redhat"
virt-customize -a $image --root-password password:redhat
