#!/bin/bash
image=$1
cmds=(
'cat > /etc/resolv.conf <<EOF
search dsal.lab.eng.rdu2.redhat.com
nameserver 10.11.5.19
nameserver 10.10.160.2
nameserver 10.5.30.160
EOF'
'sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" sshd_config '
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
