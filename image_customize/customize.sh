#!/bin/bash
image=$1
cmds=(
'yum install -y python-virtualenv git vim' 
'virtualenv ~/flask' 
'source ~/flask/bin/activate; pip install flask requests request pyyaml' 
'rm -rf ~/nfv_upgrade_demo; git clone https://github.com/zshi-redhat/nfv_upgrade_demo.git ~/nfv_upgrade_demo' 
'cp ~/nfv_upgrade_demo/service/* /etc/systemd/system/' 
)

systemctl start libvirtd
for c in "${cmds[@]}"
do
    echo "virt-customize -a $image --run-command ${c}"
    virt-customize -a $image --run-command "${c}"
done
