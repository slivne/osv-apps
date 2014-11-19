#!/usr/bin/env python
import collections
import fnmatch
import random
import os
import runpy
import argparse
import time
#import remote
import subprocess
import pprint
import json
import time
import re
#import wrkparse
import traceback
#import supervision
import shutil
import sys
from random import randrange
from contextlib import contextmanager
#from json_utils import *
from string import Template
from os import listdir
from os.path import isfile, join
from copy import deepcopy
from threading import Timer

class TimeoutTimer():
    def __init__(self,value):
        self.awesum="hh"
        self.timer = Timer(value,self.timeout)
        self.timer.start()

    def timeout(self):
        os._exit(1)

    def cancel(self):
        self.timer.cancel()


class ConfigTemplate(Template):
    delimiter = '$$'
    idpattern = r'[a-z][\.\-_a-z0-9]*'

#
# config files
#
def config_merge(a,b,path=None):
    if path is None: path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                config_merge(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass # same leaf value
            else:
                template = ConfigTemplate(b[key])
                val = template.substitute(a)
                a[key] = val
        else:
            a[key] = b[key]
    return a

def multi_config_merge(a,b):
    if a != b:
       config_merge(a["default"],b["default"])
       for config in b:
           if config != "default":
              if config in a:
                 config_merge(a[config],b[config])
              else:
                 a[config] = b[config]

    for config in a:
        if config != "default":
           tmp = a[config]
           a[config] = deepcopy(a["default"])
           config_merge(a[config],tmp)

def config_flatten(d, parent_key='', sep='.'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, collections.MutableMapping):
            items.extend(config_flatten(v, new_key).items())
        else:
            items.append((new_key, v))
    return dict(items)

def get_file(conf_file, name):
    if os.path.isabs(name) == False:
        name = os.path.join(os.path.dirname(conf_file),name)
    f = open(name)
    res = f.read()
    f.close()
    return res
    
def update_config_file(conf, file_name):
    p = re.compile('/file:(.*)\s*')
    if not isinstance(conf, dict):
        return
    for k,v in conf.items():
        if isinstance(v, dict):
            update_config_file(v, file_name)
        else  :          
            m = p.match(v)
            if m:
                conf[k] = get_file(file_name, m.group(1))

# TODO need to update the method config files are found - currently seraching up the path
def config(dir,params,selector):
    # find config files
    config_files = []
    old_dir = ""
    while old_dir != dir:
       old_dir = dir
       if os.path.isfile(os.path.join(dir,"test-config.json")):
          config_files.insert(0,os.path.join(dir,"test-config.json"))
       dir = os.path.abspath(os.path.join(dir,".."))
    result = ""

    # merge config files
    for fconfig in config_files:
       new_config = json.load(open(fconfig))
       update_config_file(new_config, fconfig)
       default = {}
       if "tester" in new_config:
          default["tester"] = new_config["tester"]
          del new_config["tester"]
       if "sut" in new_config:
          default["sut"] = new_config["sut"]
          del new_config["sut"]
       new_config["default"] = default
       if result == "":
          result = new_config
       multi_config_merge(result,new_config)

    # flatten config
    if selector not in result:
       selector = "default"
    config = config_flatten(result[selector])
    # apply params
    missing_key = False
    for key in config:
        template = ConfigTemplate(config[key])
        try:
           val = template.substitute(params)
           config[key] = val
        except KeyError:
           print "missing value for config value",key
           missing_key = True
    if missing_key:
       sys.exit (1)
    
    return config

#
# execution templates processing
#

def get_templates_from_list(list):
    return fnmatch.filter(list,"*.template.*")

def get_file_from_template(template):
    return template.replace(".template","")

def template_compare_filename(item1, item2):
    item1_val = int(item1.split("_")[1])
    item2_val = int(item2.split("_")[1])
    if item1_val < item2_val:
        return -1
    elif item1_val > item2_val:
        return 1
    else:
        return 0

def template_prepare(params,dir):
    for (dirpath, dirnames, filenames) in os.walk(dir):
        for filename in get_templates_from_list(filenames):
            template_apply(os.path.join(dirpath,filename),params)
        break
#        for dir in fnmatch.filter (dirnames,"[a-zA-Z0-9].*"):
#            template_prepare(params,dir)

def template_apply(in_file, params):
    out_file = get_file_from_template(in_file)
    in_fh = open(in_file, 'r')
    template = ConfigTemplate(in_fh.read())
    out_fh = open(out_file, 'w')
    try:
       out_fh.write(template.substitute(params))
    except KeyError, e:
       print "missing value for config value in",in_file, " key ", str(e)
       missing_key = True
       sys.exit (1)
    in_fh.close()
    out_fh.close()
    os.chmod(out_file,0755)
    print "compiling template",in_file,"->",out_file
    
#
# run logic
#
def run_file(file):
    print "running ",file
    if os.path.isabs(file) == False:
       file = os.path.abspath(file)
    save_cwd = os.getcwd()
    os.chdir(os.path.dirname(file))
    file_stdout = open(file + ".stdout_stderr","w")
    file_return = subprocess.call(file, stdout=file_stdout, stderr=subprocess.STDOUT, shell=True)
    file_stdout.close()
    os.chdir(save_cwd)
    print "return ",file_return
    return file_return


def extract_config_params_from_args(args):
    args_dictionary = vars(args)
    params = {}
    if args_dictionary['config_param'] != None:
       for key_val in args_dictionary['config_param']:
           key_vals = key_val.split(":")
           params[key_vals[0]] = key_vals[1]
    return params;


def run(args):
    compile(args)

    error = False
    for dir in args.directory:
        print "running files in",dir
        
        # timeout setting
        params = extract_config_params_from_args(args)
        configuration = config(dir,params,args.config_selection)
        timeout = None
        if "tester.timeout" in configuration:
           timeout = TimeoutTimer(int(configuration["tester.timeout"]))

        files = []
        for (dirpath, dirnames, filenames) in os.walk(dir):
            for filename in get_templates_from_list(filenames):
                files.append(filename)
            break
        files.sort(cmp=template_compare_filename)
        for file in files:
            file_return = run_file(os.path.join(dir,get_file_from_template(file)))
            if file_return != 0:
               error = True
               break

        if timeout:
           timeout.cancel()
        if error:
           break

    if error:
        print "error occured exiting"
        sys.exit(1)

def compile(args):
    params = extract_config_params_from_args(args)
    for dir in args.directory:
        print "compiling files in",dir
        configuration = config(dir,params,args.config_selection)
        template_prepare(configuration,dir)

def config_get_command(args):
    params = extract_config_params_from_args(args)
    if args.directory and len(args.directory) > 0:
        configuration = config(args.directory[0],params,args.config_selection)
        if args.param in configuration:
            print configuration[args.param]
            return
    print ""   

if __name__ == "__main__":
    parser = argparse.ArgumentParser('Tester')
    subparsers = parser.add_subparsers(help="command")

    _run = subparsers.add_parser('run')
    _run.add_argument('directory',nargs='+',help='directory to run tests')
    _run.add_argument('--config_param',action='append',help='config param to be passed')
    _run.add_argument('--config_selection',action="store",help='config selection based on test or hw',default="default")
    _run.set_defaults(func=run)

    _compile = subparsers.add_parser('compile')
    _compile.add_argument('directory',nargs='+',help='directory to compile tests')
    _compile.add_argument('--config_param',action='append',help='config param to be passed')
    _compile.add_argument('--config_selection',action="store",help='config selection based on test or hw',default="default")
    _compile.set_defaults(func=compile)

    _config_get = subparsers.add_parser('config-get')
    _config_get.add_argument('param',help='config param to extract')
    _config_get.add_argument('directory',nargs='+',help='directory to compile tests')
    _config_get.add_argument('--config_param',action='append',help='config param to be passed')
    _config_get.add_argument('--config_selection',action="store",help='config selection based on test or hw',default="default")
    _config_get.set_defaults(func=config_get_command)

    args=parser.parse_args()
    args.func(args)   

