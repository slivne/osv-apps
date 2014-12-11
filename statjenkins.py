#!/usr/bin/python3

import xml.etree.ElementTree as ET
import datetime
import json
import argparse
import sys
import collections
import traceback



def add_time(parent, name):
    e = ET.SubElement(parent, name)
    t = datetime.datetime.utcnow()
    ET.SubElement(e, 'date', val = t.date().isoformat(), format = 'ISO8601')
    ET.SubElement(e, 'time', val = t.time().isoformat(), format = 'ISO8601')

def jenkinsreport(val,units,name,description):
    report = ET.Element('report', categ = 'iperf')
    add_time(report, 'start')
    test = ET.SubElement(report, 'test', name = name, executed = 'yes')
    ET.SubElement(test, 'description').text = description
    res = ET.SubElement(test, 'result')
    ET.SubElement(res, 'success', passed = 'yes', state = '1', hasTimeOut = 'no')
    ET.SubElement(res, 'performance', unit = units, mesure = val, isRelevant = 'true')
    add_time(report, 'end')
    w = sys.stdout
    w.write(str(ET.tostring(report), 'UTF8'))

def json_from_file(name):
    try:
        json_data = open(name)
        data = json.load(json_data)
        json_data.close()
        return data
    except:
        t, value, tb = sys.exc_info()
        traceback.print_tb(tb)
        print("Bad formatted JSON file '" + name + "' error ", value.message)
        sys.exit(-1)

def run(file,path,units,name,description):
    val = json_from_file(file)[path]
    jenkinsreport (str(val),units,name,description)
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser('statjenkins')
    parser.add_argument('file',help='file to run statistic on')
    parser.add_argument('path',help='use xpath to search in json object')
    parser.add_argument('units',help='use xpath to search in json object')
    parser.add_argument('name', help='use xpath to search in json object')
    parser.add_argument('description', help='use xpath to search in json object')
    args=parser.parse_args()

    run(args.file,args.path,args.units,args.name,args.description)
