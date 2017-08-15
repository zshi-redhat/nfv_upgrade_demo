#!/bin/bash
ansible-playbook ../upgrade-ansible/upgrade.yaml -e compute_node='overcloud-compute-0'
ansible-playbook ../upgrade-ansible/upgrade.yaml -e compute_node='overcloud-compute-2'
