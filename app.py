import sys, argparse
from flask import Flask
from vnfm_route import vnfm
from vnf_route import vnf
from utils import *

def parse_opts(argv):
    parser = argparse.ArgumentParser(
        description='Configure API agent')
    parser.add_argument('-c', '--config', metavar='CONFIG',
                        help="""name for blueprint registration.""",
                        default='vnfm')
    parser.add_argument('-a', '--ip-address', metavar='IP_ADDRESS',
                        help="""ip address that api service is bundled to.""",
                        default=None)
    parser.add_argument('-p', '--port', metavar='PORT',
                        help="""port num that api service is bundled to.""",
                        default=5000)
    opts = parser.parse_args(argv[1:])
    return opts

def main(argv=sys.argv):
    opts = parse_opts(argv)

    app = Flask(__name__)
    if opts.config:
        if opts.config == 'vnfm':
            app.register_blueprint(vnfm)
        if opts.config == 'vnf':
            app.register_blueprint(vnf)
    if opts.ip_address is None:
        ip = get_ip()
    app.run(
            host=ip,
            port=opts.port,
            debug=True
    )
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
