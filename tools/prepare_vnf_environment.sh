#!/bin/bash

# this script will accept parameters:
# $1: provider segment for sriov vlan
# $2: physical network for sriov
# $3: path for the testing image to use
# $4: user to login into the testing image
# $5: starting ip in the floating ip range
# $6: final ip in the floating ip range
# $7: floating ip for the vnfm
# $8: floating ip for the first vnf
# $9: floating ip for the second vnf
SEGMENTATION_ID=$1
PHYSICAL_NETWORK=$2
PATH_TO_TEST_IMAGE=$3
LOGIN_USER=$4
ALLOCATION_POOL_START=$5
ALLOCATION_POOL_END=$6
VNFM_IP=$7
VNF1_IP=$8
VNF2_IP=$9

source /home/stack/overcloudrc

# create zone if not exists
openstack aggregate show sriov
ZONE_RESULT=$?

if [[ $ZONE_RESULT -ne 0 ]]; then
    openstack aggregate create --zone=sriov sriov

    openstack aggregate add host sriov overcloud-novacompute-0.localdomain
    openstack aggregate add host sriov overcloud-novacompute-1.localdomain
fi

# create special flavor if not exists
openstack flavor show m1.small_sriov
FLAVOR_RESULT=$?
if [[ $FLAVOR_RESULT -ne 0 ]]; then
    openstack flavor create --ram 2048 --disk 20 --vcpus 1 m1.small_sriov
    openstack flavor set --property hw:cpu_policy=dedicated --property  hw:mem_page_size=large m1.small_sriov
fi

# create internal network if not exists
openstack network show default
DEFAULT_NETWORK_RESULT=$?
if [[ $DEFAULT_NETWORK_RESULT -ne 0 ]]; then
    openstack network create default
    openstack subnet create default --network default --gateway 172.20.1.1 --subnet-range 172.20.0.0/16
fi

# create external network if not exists
openstack network show external
EXTERNAL_NETWORK_RESULT=$?
if [[ $EXTERNAL_NETWORK_RESULT -ne 0 ]]; then
    openstack network create --external --provider-network-type flat --provider-physical-network datacentre external
    openstack subnet create external --network external --dhcp --allocation-pool start=${ALLOCATION_POOL_START},end=${ALLOCATION_POOL_END} --gateway 10.9.88.254 --subnet-range 10.9.88.0/24
    openstack router create external
    openstack router add subnet external default
    neutron router-gateway-set external external
fi

# create sriov network and ports if not exist
openstack network show sriov
SRIOV_NETWORK_RESULT=$?

if [[ $SRIOV_NETWORK_RESULT -ne 0 ]]; then
    openstack network create sriov --provider-network-type vlan --provider-physical-network $PHYSICAL_NETWORK --provider-segment $SEGMENTATION_ID
    neutron subnet-create --name subnet_sriov --disable-dhcp --gateway 10.0.10.1 --allocation-pool start=10.0.10.2,end=10.0.10.4 sriov 10.0.10.1/24
fi

openstack port show sriov_port1_vf
SRIOV_PORT_1_RESULT=$?
if [[ $SRIOV_PORT_1_RESULT -ne 0 ]]; then
    openstack port create --network sriov --vnic-type direct sriov_port1_vf
fi

openstack port show sriov_port2_vf
SRIOV_PORT_2_RESULT=$?
if [[ $SRIOV_PORT_2_RESULT -ne 0 ]]; then
    openstack port create --network sriov --vnic-type direct sriov_port2_vf
fi

openstack port show sriov_port3_vf
SRIOV_PORT_3_RESULT=$?
if [[ $SRIOV_PORT_3_RESULT -ne 0 ]]; then
    openstack port create --network sriov --vnic-type direct sriov_port3_vf
fi

# create image, file needs to previously exist
openstack image show test_image
TEST_IMAGE_RESULT=$?
if [[ $TEST_IMAGE_RESULT -ne 0 ]];then
    openstack image create test_image --file $PATH_TO_TEST_IMAGE --disk-format qcow2 --container-format bare
fi

# create keypair if not exists
openstack keypair show undercloud-stack
KEYPAIR_RESULT=$?
if [ $KEYPAIR_RESULT -ne 0 ]; then
    openstack keypair create --public-key /home/stack/.ssh/id_rsa.pub undercloud-stack
fi

# create security group if not exists
openstack security group show all-access
SECURITY_GROUP_RESULT=$?
if [[ $SECURITY_GROUP_RESULT -ne 0 ]]; then
    openstack security group create all-access
    openstack security group rule create --ingress --protocol icmp --src-ip 0.0.0.0/0 all-access
    openstack security group rule create --ingress --protocol tcp --src-ip 0.0.0.0/0 all-access
    openstack security group rule create --ingress --protocol udp --src-ip 0.0.0.0/0 all-access
fi

# create the vms and wait until are booted
openstack server show vnfm
VM_1_RESULT=$?

if [[ $VM_1_RESULT -ne 0 ]]; then
    openstack floating ip create external --floating-ip-address $VNFM_IP
    COMMAND_NOVA_1="openstack server create --availability-zone sriov --security-group all-access --flavor m1.small_sriov --key-name undercloud-stack --image test_image   --nic net-id=$(neutron net-list | grep default | awk '{print $2}' ),v4-fixed-ip=172.20.0.100 --nic port-id=$(neutron port-list | grep sriov_port1_vf | awk '{print $2}') vnfm"
    VM_UUID_1=$($COMMAND_NOVA_1 |  awk '/id/ {print $4}' | head -n 1)
    echo "I run $COMMAND_NOVA_1, id is $VM_UUID_1"

    until [[ "$(nova show ${VM_UUID_1} | awk '/ status/ {print $4}')" == "ACTIVE" ]]; do
        sleep 1
    done
    openstack server add floating ip vnfm $VNFM_IP

    sleep 5
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNFM_IP} 'sudo ip addr add 10.0.10.2/24 dev eth1'
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNFM_IP} 'sudo ip link set eth1 up'
fi

openstack server show vnf1
VM_2_RESULT=$?

if [[ $VM_2_RESULT -ne 0 ]]; then
    openstack floating ip create external --floating-ip-address $VNF1_IP
    COMMAND_NOVA_2="openstack server create --availability-zone sriov --security-group all-access --flavor m1.small_sriov --key-name undercloud-stack --image test_image   --nic net-id=$(neutron net-list | grep default | awk '{print $2}'),v4-fixed-ip=172.20.0.101 --nic port-id=$(neutron port-list | grep sriov_port2_vf | awk '{print $2}') vnf1"
    VM_UUID_2=$($COMMAND_NOVA_2 |  awk '/id/ {print $4}' | head -n 1)
    echo "I run $COMMAND_NOVA_2, id is $VM_UUID_2"

    until [[ "$(nova show ${VM_UUID_2} | awk '/ status/ {print $4}')" == "ACTIVE" ]]; do
        sleep 1
    done
    openstack server add floating ip vnf1 $VNF1_IP

    sleep 5
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNF1_IP} 'sudo ip addr add 10.0.10.3/24 dev eth1'
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNF1_IP} 'sudo ip link set eth1 up'
fi

openstack server show vnf2
VM_3_RESULT=$?

if [[ $VM_3_RESULT -ne 0 ]]; then
    openstack floating ip create external --floating-ip-address $VNF2_IP
    COMMAND_NOVA_3="openstack server create --availability-zone sriov --security-group all-access --flavor m1.small_sriov --key-name undercloud-stack --image test_image   --nic net-id=$(neutron net-list | grep default | awk '{print $2}'),v4-fixed-ip=172.20.0.102 --nic port-id=$(neutron port-list | grep sriov_port3_vf | awk '{print $2}') vnf2"
    VM_UUID_3=$($COMMAND_NOVA_3 |  awk '/id/ {print $4}' | head -n 1)
    echo "I run $COMMAND_NOVA_3, id is $VM_UUID_3"

    until [[ "$(nova show ${VM_UUID_3} | awk '/ status/ {print $4}')" == "ACTIVE" ]]; do
        sleep 1
    done
    openstack server add floating ip vnf2 $VNF2_IP

    sleep 5
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNF2_IP} 'sudo ip addr add 10.0.10.4/24 dev eth1'
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${LOGIN_USER}@${VNF2_IP} 'sudo ip link set eth1 up'
fi

