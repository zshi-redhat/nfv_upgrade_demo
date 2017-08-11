from flask import Blueprint, request
from vnfm_func import *

vnfm = Blueprint('vnf manager', __name__, template_folder='templates')

def get_func(func):
    f = {
        'help': (vnfm_help),
        'state': (get_vnfm_state),
        'create': (create_vnfm),
        'delete': (delete_vnfm),
        'vnf-create': (create_vnf),
    }.get(func)
    return f()

def get_func_with_para(func, data):
    f = {
        'get-vnfs': (get_vnfs),
        'get-pair-vnfs': (get_pair_vnfs),
        'vnf-delete': (delete_vnf),
        'vnf-state': (get_vnf_state),
        'vnf-switch': (switch_vnf_state),
    }.get(func)
    return f(data)

@vnfm.route('/help', methods=['GET'])
def route_help():
    return get_func('help')

@vnfm.route('/vnfm/<func>', methods=['GET', 'POST'])
def route_vnfm_func_req(func):
    if request.method == 'GET':
        return get_func(func)
    elif request.method == 'POST':
        data = request.get_data()
        return get_func_with_para(func,data)

@vnfm.route('/vnfm/cmd/<string:cmd>', methods=['GET'])
def exec_cmd(cmd):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              stdin=subprocess.PIPE,
                              shell = True)
    out,err = p.communicate()
    return out
