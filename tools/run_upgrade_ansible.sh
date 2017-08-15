#!/bin/bash
ansible-playbook ../upgrade-ansible/playbooks/upgrade.yaml -e compute_node='overcloud-compute-0'
ansible-playbook ../upgrade-ansible/playbooks/upgrade.yaml -e compute_node='overcloud-compute-2'
