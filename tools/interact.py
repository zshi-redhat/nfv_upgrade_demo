import os, sys, argparse
import subprocess
import yaml

HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'
BOLD = "\033[1m"

def help_msg():
    print "\nUsage: $(basename $0) [ -a <vnfm_ip_address> ]"
    print "\t -a     \t\t vnfm ip address"
    print "\t -p     \t\t port num that api service is bundled to"
    print "\n"

def vnfm_help_msg():
    print "\nUsage: "
    print "\t h     \t\t help message"
    print "\t vnf   \t\t list vnfs in this vnfm"
    print "\t ip    \t\t list vnfs ip address"
    print "\t state \t\t list vnfs state"
    print "\t host  \t\t list vnfs host info"
    print "\t e     \t\t exit"
    print "\n"

def exec_cmd(cmd):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              stdin=subprocess.PIPE,
                              shell = True)
    out,err = p.communicate()
    return out

def show_vnf():
    cmd = "curl http://" + mIP + ":" + mPORT + "/vnfm/get-data"
    print '\n' + '\t' + OKGREEN + str(yaml.load(exec_cmd(cmd))['vnfcs']) + ENDC + '\n\n'

def show_ip():
    cmd = "curl http://" + mIP + ":" + mPORT + "/vnfm/get-data"
    print '\n' + '\t' + OKGREEN + str(yaml.load(exec_cmd(cmd))['vnfc_mgmt_ip']) + ENDC + '\n\n'

def show_state():
    ret = {}
    cmd = "curl http://" + mIP + ":" + mPORT + "/vnfm/get-data"
    d = yaml.load(exec_cmd(cmd))['vnfc_mgmt_ip']
    for k in d:
        cmd = "curl http://" + d[k] + ":" + "5001" + "/vnf/state"
        ret[k] = exec_cmd(cmd)
    print '\n' + '\t' + OKGREEN + str(ret) + ENDC + '\n\n'

def show_host():
    cmd = "curl http://" + mIP + ":" + mPORT + "/vnfm/get-data"
    print '\n' + '\t' + OKGREEN + str(yaml.load(exec_cmd(cmd))['vnfc_host']) + ENDC + '\n\n'

def parse_opts(argv):
    parser = argparse.ArgumentParser(
        description='Interactive tool')
    parser.add_argument('-a', '--ip', metavar='IP_ADDRESS',
                        help="""vnfm ip address.""",
                        default='127.0.0.1')
    parser.add_argument('-p', '--port', metavar='PORT',
                        help="""port num that api service is bundled to.""",
                        default='5000')
    opts = parser.parse_args(argv[1:])
    return opts

def main(argv=sys.argv):
    global mIP
    global mPORT
    opts = parse_opts(argv)
    if opts.ip:
        mIP = opts.ip
    if opts.port:
        mPORT = opts.port
    while True:
        cmd = raw_input("(h for help)Enter cmd :")
        if cmd == 'h':
            vnfm_help_msg()
        elif cmd == 'vnf':
            show_vnf()
        elif cmd == 'ip':
            show_ip()
        elif cmd == 'state':
            show_state()
        elif cmd =='host':
            show_host()
        elif cmd == 'e':
            exit()
        else:
            vnfm_help_msg()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
