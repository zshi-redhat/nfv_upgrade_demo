#!/bin/bash
image=$1
cmds=(
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
