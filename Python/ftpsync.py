#!/usr/bin/python3
from ftplib import FTP
from getpass import getpass
import sys
import os
import re
from pathlib import PurePath
import socket
import argparse
from collections import defaultdict
import configparser


# 0.1 Parse command args
parser = argparse.ArgumentParser(prog="ftpsync")
parser.add_argument('remote_src',)
parser.add_argument('cntr', nargs='?', default='1')
parser.add_argument('local_src', nargs='?', default='-')
args = parser.parse_args(sys.argv[1:])
args.remote_src = args.remote_src.replace(os.environ['HOME'],'')
args.remote_src = os.path.join('/',args.remote_src)
if (args.local_src == '-'):
    args.local_src = args.remote_src

# 0.2 Get parameters to connect to FTP
config = configparser.ConfigParser()
required_settings = ('RemoteServer','RemoteLogin')
try:
    config_file = os.path.join(os.path.dirname(__file__),'ftpsync.ini')
    config.read_file(open(config_file))
    if ('Config' not in config):
        print ("Couldn't find section 'Config' in configuration file")
        sys.exit(1)
    for setting in required_settings:
        if (setting not in config['Config']):
            print (f"Couldn't find required setting '{setting}' in configuration file")
            sys.exit(1)
    remote_server = config.get('Config','RemoteServer')
    remote_login = config.get('Config','RemoteLogin')
    remote_port = config.getint('Config','RemotePort',fallback=21)
    control_root = config.get('Config','ControlDirectory',fallback='sort')
except Exception as ex:
    print (f"Couldn't get configuration: {ex}")
    sys.exit(1)



password = getpass()
iplist = list(i[4][0] for i in 
        socket.getaddrinfo(remote_server,0)
        if i[0] is socket.AddressFamily.AF_INET  # ipv4
        and i[1] is socket.SocketKind.SOCK_RAW  
    )
if (len(iplist)==0):
    print (f"Couldn't resolve {remote_server}")
    sys.exit()

ip = iplist[0]


# 1. Sub to make necessary dirs
def ftp_makedirs(conn, safe_root, dest_dir):
    # print (f"{safe_root} {dest_dir}")
    if (dest_dir == safe_root):
        print (f"new dest_dir same as safe_root, nothing to do")
        return

    pure_dest_dir = PurePath(dest_dir)
    pure_safe_dir = PurePath(safe_root)
    pure_rel_dir = pure_dest_dir.relative_to(safe_root)
    # print (f"rel_dir: {pure_rel_dir}, {len(pure_rel_dir.parts)}")
    for part in pure_rel_dir.parts:
        print (f"Checking {pure_safe_dir / part}... ", end='')
        remote_names = conn.nlst(str(pure_safe_dir))
        new_dir = pure_safe_dir / part
        
        if (str(new_dir) not in remote_names):
            print ("creating")
            conn.mkd(str(new_dir))
        else:
            print ("already exists")
        pure_safe_dir = new_dir


# 2. Diagnostics
def print_file_set(file_set):
    if (len(file_set) == 0):
        print (" <not found>")
        return

    print ('')
    display_data = defaultdict(list)
    for file in file_set:
        (adir, afile) = os.path.split(file)
        display_data[adir].append(afile)
    for adir in sorted(display_data.keys()):
        print (f"in {adir}:")
        display_data[adir] = sorted(display_data[adir])
        while ((len(display_data[adir]) % 4) > 0):
            display_data[adir].append('')
        fptr = 0
        while (fptr < len(display_data[adir])):
            print (f"{display_data[adir][fptr]:20s} {display_data[adir][fptr+1]:20s} " + 
                f"{display_data[adir][fptr+2]:20s} {display_data[adir][fptr+3]:20s}")
            fptr += 4


def process_control_dir(relative_control):
    # 3.2. Orient in the dirs 
    control_dir = f"{control_root}/{relative_control}"
    local_control_dir = os.path.join(os.environ['HOME'],control_dir)
    remote_control_dir = os.path.join("/",control_dir)

    print()
    ftp_makedirs(ftp,os.path.join("/",control_root),remote_control_dir)

    # 3.3. Walk local control dir and do things remotely
    for walk_data in os.walk(local_control_dir):
        # 1. Check files in current dir
        # 1.1. Get files from remote source dir. Check which are still there and which are not.
        rel_dir = os.path.relpath(walk_data[0],local_control_dir)
        remote_source_dir = os.path.join(args.remote_src,rel_dir)
        remote_source_names = set()
        remote_source_exists = ''
        try: 
            remote_source_names = set(ftp.nlst(remote_source_dir))
        except Exception as ex:
            if (str(ex).startswith("550 Can't")):
                remote_source_names = set()
                remote_source_exists = ' (Not found)'
            else:
                raise ex

        print (f"In source directory{remote_source_exists}:")
        print_file_set(remote_source_names)
        move_targets = {os.path.join(remote_source_dir,filename) for filename in walk_data[2]}
        exist_targets = remote_source_names & move_targets
        print (f"\nDirectory: {rel_dir}. Ready to process:", end='')
        print_file_set(exist_targets)
        missing_targets = move_targets - remote_source_names
        # print (f"Missing targets:", end='')
        # print_file_set(missing_targets)

        # a) still there - move
        # b) not there - look in the remote dest dir. If they are there, report as already moved
        # remote_dest_dir = remote contr + delta
        remote_dest_dir = os.path.join(remote_control_dir,rel_dir)
        exist_results = set(ftp.nlst(remote_dest_dir))
        check_missing = {filename.replace(remote_source_dir,remote_dest_dir) for filename in missing_targets}
        found_missing = check_missing & exist_results
        print (f"Already moved: ", end='')
        print_file_set(found_missing)
        notfound_missing = check_missing - exist_results
        print (f"Files not in either dir:", end=''    )
        print_file_set(notfound_missing)

        # c) all others - not found.
        # 1.2. Do move 
        if (len(exist_targets) > 0):
            ftp.cwd(remote_source_dir)
            for file in exist_targets:
                if (file == '.fehlist'):
                    continue
                print(f"Moving {file}")
                try:
                    (move_src_dir, move_file) = os.path.split(file)
                    ftp.rename(move_file,os.path.join(remote_dest_dir,move_file))
                    print ("Moved ok")
                except Exception as ex:
                    print(ex)     
                       
        # 2. Check if child dirs exist and create when needed
        for adir in walk_data[1]:
            ftp_makedirs(ftp, remote_dest_dir, os.path.join(remote_dest_dir,adir))



# 3. Main block
try:
    # 3.1. Connect to the FTP server
    print (f"Connecting to {ip} server")
    ftp = FTP()
    ftp.connect(ip,remote_port)
    ftp.login(remote_login,password)
    ftp.encoding = "utf-8"
    print ("Connection successful")

    # 3.2. Orient in the dirs 
    for control_dir in args.cntr.split(','):
        range_check = re.fullmatch(r"(\d+)-(\d+)",control_dir)
        if (range_check is not None):
            range_start = int(range_check.group(1))
            range_end = int(range_check.group(2))
            if (range_end >= range_start):
                for range_iter in range(range_start,range_end+1):
                    process_control_dir(str(range_iter))
        else:
            process_control_dir(control_dir)

    # control_dir = f"{control_root}/{args.cntr}"
    # local_control_dir = os.path.join("/home/mai",control_dir)
    # remote_control_dir = os.path.join("/",control_dir)

    # # 3.3. Walk local control dir and do things remotely
    # for walk_data in os.walk(local_control_dir):
    #     # 1. Check files in current dir
    #     # 1.1. Get files from remote source dir. Check which are still there and which are not.
    #     rel_dir = os.path.relpath(walk_data[0],local_control_dir)
    #     remote_source_dir = os.path.join(args.remote_src,rel_dir)
    #     remote_source_names = set(ftp.nlst(remote_source_dir))
    #     move_targets = {os.path.join(remote_source_dir,filename) for filename in walk_data[2]}
    #     exist_targets = remote_source_names & move_targets
    #     print (f"\nDirectory: {rel_dir}. Ready to process:", end='')
    #     print_file_set(exist_targets)
    #     missing_targets = move_targets - remote_source_names
    #     # print (f"Missing targets:", end='')
    #     # print_file_set(missing_targets)

    #     # a) still there - move
    #     # b) not there - look in the remote dest dir. If they are there, report as already moved
    #     # remote_dest_dir = remote contr + delta
    #     remote_dest_dir = os.path.join(remote_control_dir,rel_dir)
    #     exist_results = set(ftp.nlst(remote_dest_dir))
    #     check_missing = {filename.replace(remote_source_dir,remote_dest_dir) for filename in missing_targets}
    #     found_missing = check_missing & exist_results
    #     print (f"Already moved: ", end='')
    #     print_file_set(found_missing)
    #     notfound_missing = check_missing - exist_results
    #     print (f"Files not in either dir:", end=''    )
    #     print_file_set(notfound_missing)

    #     # c) all others - not found.
    #     # 1.2. Do move 
    #     if (len(exist_targets) > 0):
    #         ftp.cwd(remote_source_dir)
    #         for file in exist_targets:
    #             print(f"Moving {file}")
    #             try:
    #                 (move_src_dir, move_file) = os.path.split(file)
    #                 ftp.rename(move_file,os.path.join(remote_dest_dir,move_file))
    #                 print ("Moved ok")
    #             except Exception as ex:
    #                 print(ex)     
                       
    #     # 2. Check if child dirs exist and create when needed
    #     for adir in walk_data[1]:
    #         ftp_makedirs(ftp, remote_dest_dir, os.path.join(remote_dest_dir,adir))


except Exception as e:
    print(f"Error: {str(e)}")
finally:
    ftp.quit()

