from flask import jsonify, request
import os
import requests
import socket
import yaml

OPENSTACK_AUTH = '/home/centos/upgrade_poc/overcloudrc'
STATE_FILE = '/tmp/vnfm_state'
DATA_FILE = '/home/centos/upgrade_poc/data_file'

def vnfm_help():
    help_message = "add help messages here"
    return help_message

def switch_vnf_state(p):
    url = 'http://' + p + ':' + '5001' + \
          '/vnf/switch'
    return requests.get(url).text

def get_vnf_state(p):
    url = 'http://' + p + ':' + '5001' + \
          '/vnf/state'
    return requests.get(url).text

def delete_vnf(p):
    url = 'http://' + p + ':' + '5001' + \
          '/vnf/delete'
    return requests.get(url).text

def get_data():
    try:
        with open(DATA_FILE, 'r') as f:
            return jsonify(yaml.load(f.read()))
    except IOError:
        return "[ERROR] error reading data file"

def create_vnf():
    try:
        with open(DATA_FILE, 'r') as f:
            d = yaml.load(f.read())
            for k in d['vnfc_mgmt_ip']:
                url = 'http://' + d['vnfc_mgmt_ip'][k] + ':' + '5001' + \
                      '/vnf/create'
                requests.get(url)
        return 'Done\n'
    except IOError:
        return "[ERROR] create vnf state error\n"

def get_vnfm_state():
    try:
        with open(STATE_FILE, 'r') as f:
            return f.read() + '\n'
    except IOError:
        return "[ERROR] get vnfm state error\n"

def create_vnfm():
    try:
        f = open(STATE_FILE, 'r')
    except IOError:
        f = open(STATE_FILE, 'w')
        f.write('active')
    return 'Done!\n'

def delete_vnfm():
    if os.access(STATE_FILE, os.F_OK):
        os.unlink(STATE_FILE)
    return 'Done!\n'

def get_vnfs(node):
    ret = {}
    try:
        with open(DATA_FILE, 'r') as f:
            d = yaml.load(f.read())
            for k in d['vnfc_host']:
                if d['vnfc_host'][k] == node:
                    ret[k] = d['vnfc_host'][k]
            for k in ret:
                ret[k] = d['vnfc_mgmt_ip'][k]
        return jsonify(ret)
    except IOError:
        return "[ERROR] get vnf-compute mapping error\n"

def get_pair_vnfs(p):
    ret = {}
    try:
        with open(DATA_FILE, 'r') as f:
            d = yaml.load(f.read())
            for k in d['vnfc_mgmt_ip']:
                if d['vnfc_mgmt_ip'][k] != p:
                    ret[k] = d['vnfc_mgmt_ip'][k]
        return jsonify(ret)
    except IOError:
        return "[ERROR] get pair vnf error"
