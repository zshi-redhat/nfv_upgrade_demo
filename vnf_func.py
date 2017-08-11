from flask import jsonify
import os
import subprocess
import socket

STATE_FILE = '/tmp/vnf_state'

def vnf_help():
    help_message = "\nadd help messages here"
    return help_message

def switch_vnf_state():
    try:
        with open(STATE_FILE, 'r') as f:
            s = f.read()
            s = 'active' if s == 'standby' else 'standby'
    except IOError:
        print "[ERROR] Set state error"
    try:
        with open(STATE_FILE, 'w') as f:
            f.write(s)
            f.close()
    except IOError:
        print "[ERROR] Set vnf state error"
    return 'Done!\n'

def get_vnf_state():
    try:
        with open(STATE_FILE, 'r') as f:
            return f.read() + '\n'
    except IOError:
        return "[ERROR] get vnf state error\n"

def delete_vnf():
    if os.access(STATE_FILE, os.F_OK):
        os.unlink(STATE_FILE)
    return 'Done!\n'

def create_vnf():
    try:
        f = open(STATE_FILE, 'r')
    except IOError:
        f = open(STATE_FILE, 'w')
        f.write('standby')
    return 'Done!\n'
