from flask import Blueprint
from vnf_func import *

vnf = Blueprint('vnf', __name__, template_folder='templates')

def get_func(func):
    f = {
        'help': (vnf_help),
        'state': (get_vnf_state),
        'switch': (switch_vnf_state),
        'delete': (delete_vnf),
        'create': (create_vnf),
    }.get(func)
    return f()

@vnf.route('/help', methods=['GET'])
def route_help():
    return get_func('help')

@vnf.route('/vnf/<func>', methods=['GET'])
def route_vnf_func_req(func):
    return get_func(func)

@vnf.route('/vnf/cmd/<string:cmd>', methods=['GET'])
def exec_cmd(cmd):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              stdin=subprocess.PIPE,
                              shell = True)
    out,err = p.communicate()
    return out
