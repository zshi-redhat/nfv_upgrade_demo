#!/bin/bash

source overcloudrc

vnfc1_ip=$(openstack server list -c Name -c Networks -f table | grep vnfc-1 | cut -d, -f2 | cut -d\; -f1)
vnfc2_ip=$(openstack server list -c Name -c Networks -f table | grep vnfc-2 | cut -d, -f2 | cut -d\; -f1)
vnfm_ip=$(openstack server list -c Name -c Networks -f table | grep vnfm | cut -d, -f2 | cut -d\; -f1)

vnfc1_id=$(openstack server list -c Name -c ID -f table | grep vnfc-1 | cut -d\| -f2)
vnfc2_id=$(openstack server list -c Name -c ID -f table | grep vnfc-2 | cut -d\| -f2)
vnfm_id=$(openstack server list -c Name -c ID -f table | grep vnfm | cut -d\| -f2)

if nova hypervisor-servers overcloud-novacompute-0 | grep $vnfc1_id > /dev/null; then
	vnfc1_host='overcloud-novacompute-0'
else
	vnfc1_host='overcloud-novacompute-1'
fi

if nova hypervisor-servers overcloud-novacompute-0 | grep $vnfc2_id > /dev/null; then
	vnfc2_host='overcloud-novacompute-0'
else
	vnfc2_host='overcloud-novacompute-1'
fi

if nova hypervisor-servers overcloud-novacompute-0 | grep $vnfm_id > /dev/null; then
	vnfm_host='overcloud-novacompute-0'
else
	vnfm_host='overcloud-novacompute-1'
fi

echo "vnfc1 ip: $vnfc1_ip, id: $vnfc1_id, host: $vnfc1_host"
echo "vnfc2 ip: $vnfc2_ip, id: $vnfc2_id, host: $vnfc2_host"
echo "vnfm ip: $vnfm_ip, id: $vnfm_id, host: $vnfm_host"

echo "{'vnfm_name': 'vnfm', 'vnfm_floating_ip': $vnfm_ip, 'vnfc_host': {'vnfc-1': $vnfc1_host, 'vnfc-2': $vnfc2_host}, 'vnf_name': 'vnf', 'vnfcs': {'vnfc-1': $vnfc1_id, 'vnfc-2': $vnfc2_id}, 'vnfc_mgmt_ip': {'vnfc-1': $vnfc1_ip, 'vnfc-2': $vnfc2_ip} }" > /tmp/data_file
