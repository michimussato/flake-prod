# Download with Python (based on [paulwinex/houdini_install_script](https://github.com/paulwinex/houdini_install_script/blob/master/houdini_install.py):
#
# nix-shell -p python313 python313Packages.tqdm python313Packages.requests
# python3 get_houdini.py --username "" --password "" --id-number "" --destination-dir ""
#
# Todo:
#  - [x] currently downloads to where the script lives. add dest dir.
#
import sys, os, argparse
import getpass
from tqdm import tqdm
import requests
from email.message import Message
import pathlib


# VARIABLES ################################
parser = argparse.ArgumentParser()
parser.add_argument("-u", "--username", type=str, help="SideFx account username")
parser.add_argument("-p", "--password", type=str, help="SideFx account password")
parser.add_argument("-id", "--id-number", type=int, help="SideFx Houdini Version ID")
parser.add_argument("-d", "--destination-dir", type=pathlib.Path, help="Destination Directory")

_args, other_args = parser.parse_known_args()
username = _args.username
password = _args.password
id_number = _args.id_number
destination_dir = _args.destination_dir
if not all([username, password, id_number, destination_dir]):
    print('Please set username and password and id and destination-dir')
    print('Example: -u username -p password -id id -d destination_dir')
    sys.exit()

############################################################# START #############


# define OS
if os.name != 'posix':
    raise Exception('This OS not supported')

# create client
client = requests.session()
# Retrieve the CSRF token first
URL = 'https://www.sidefx.com/login/'
print('Login on %s ...' % URL)
client.get(URL)  # sets cookie
csrftoken = client.cookies['csrftoken']
# create login data
login_data = dict(username=username, password=password, csrfmiddlewaretoken=csrftoken, next='/')
# login
r = client.post(URL, data=login_data, headers=dict(Referer=URL))
h_file = client.get(f"https://www.sidefx.com/download/download-houdini/{str(id_number)}/get/", data=login_data, headers=dict(Referer=URL), stream=True)
total = int(h_file.headers.get('content-length', 0))

h_filename_header = str(h_file.headers.get("Content-Disposition", 'attachment; filename="houdini.tar.gz"'))
print(h_filename_header)

msg = Message()
msg['content-type'] = h_filename_header  # Trick Message parser to parse as Content-Type

# Try to get filename* (encoded filename) first
h_filename = msg.get_param('filename*', failobj=None, header='content-type')
# get_param for filename* will decode automatically if it's UTF-8''...
if not h_filename:
    # Fallback to filename (plain ASCII)
    h_filename = msg.get_param('filename', failobj=None, header='content-type')

p = destination_dir.joinpath(h_filename).expanduser().resolve()
p.parent.mkdir(parents=True, exist_ok=True)

with open(p, 'wb') as file, tqdm(
        desc=h_filename,
        total=total,
        unit='iB',
        unit_scale=True,
        unit_divisor=1024,
    ) as bar:
    for data in h_file.iter_content(chunk_size=1024):
        size = file.write(data)
        bar.update(size)

print(f"File written to {p.as_posix()}")
