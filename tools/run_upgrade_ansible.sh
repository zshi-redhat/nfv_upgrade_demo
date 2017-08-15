#!/bin/bash
ansible-playbook ../upgrade-ansible/playbooks/compute-upgrade.yaml -e compute_node='overcloud-compute-0'
ansible-playbook ../upgrade-ansible/playbooks/compute-upgrade.yaml -e compute_node='overcloud-compute-2'
ansible-playbook ../upgrade-ansible/playbooks/controller-upgrade.yaml -e controller_node='overcloud-controller-0'
ansible-playbook ../upgrade-ansible/playbooks/controller-upgrade.yaml -e controller_node='overcloud-controller-1'
