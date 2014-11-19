#!/usr/bin/env python

import json
import argparse
import sys
import collections
import traceback
from __builtin__ import str

sum_values = {}
sq_values = {}
count_values = {}
total = 0
def inc_arr(arr, k, v):
    if k in arr:
        arr[k] = arr[k] + v
    else:
        arr[k] = v

def add_values(obj):
    global sum_values
    global sq_values
    global coiunt_values
    global total
    total = total + 1
    for k,v in obj.items():
        if isinstance(v,int) or isinstance(v,float) :
            inc_arr(sum_values, k, v)
            inc_arr(sq_values, k, v*v)
            inc_arr(count_values, k, 1)

def print_values():
    print ("{")
    for k,v in count_values.items():
        if k in sum_values:
            print ('"' + k + '"'+ ": " + str(float(sum_values[k])/v) + ",")
    print ('"total": ' + str(total) + '\n}')

def parse_file(name):        
    try:
        json_data = open(name)
        data = json.load(json_data)
        json_data.close()
        if isinstance(data, dict):
            add_values(data)
        else:
            for obj in data:
                add_values(obj)
    except:
        t, value, tb = sys.exc_info()
        traceback.print_tb(tb)
        print("Bad formatted JSON file '" + name + "' error ", value.message)
        sys.exit(-1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser('statjson')
    parser.add_argument('file',nargs='+',help='file to run statistic on')
    args=parser.parse_args()
    for f in args.file:
        parse_file(f) 
    print_values()