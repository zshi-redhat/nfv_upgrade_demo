from flask import jsonify, request
import os
import requests
import socket
import yaml

OPENSTACK_AUTH = '/tmp/overcloudrc'
STATE_FILE = '/tmp/vnfm_state'
VNF_INFO = '/tmp/vnf_info'
VNF_MAPPING_INFO = '/tmp/vnf_mapping'

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

def create_vnf():
    try:
        with open(VNF_INFO, 'r') as f:
            d = yaml.load(f.read())
            for k in d:
                url = 'http://' + d[k] + ':' + '5001' + \
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
        with open(VNF_MAPPING_INFO, 'r') as f:
            d = yaml.load(f.read())
            for k in d:
                if d[k] == node:
                    ret[k] = d[k]
        with open(VNF_INFO, 'r') as f:
            d = yaml.load(f.read())
            for k in ret:
                ret[k] = d[k]
        return jsonify(ret)
    except IOError:
        return "[ERROR] get vnf-compute mapping error\n"

def get_pair_vnfs(p):
    ret = {}
    try:
        with open(VNF_INFO, 'r') as f:
            d = yaml.load(f.read())
            for k in d:
                if d[k] != p:
                    ret[k] = d[k]
        return jsonify(ret)
    except IOError:
        return "[ERROR] get pair vnf error"
