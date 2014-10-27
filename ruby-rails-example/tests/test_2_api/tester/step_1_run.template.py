#!/usr/bin/env python
import sys
import subprocess
import signal
import re
import urllib
import urllib2

def do_http_test():
    resp = urllib2.urlopen('$$sut.url_base')
    body = resp.read()
    print("response of /:%s" % body)
    if re.search(r'You&rsquo;re riding Ruby on Rails!', body) == None:
        return False
    
    resp = urllib2.urlopen('$$sut.url_base/items')
    body = resp.read()
    print("response of /items:%s" % body)
    if re.search(r'Listing items', body) == None:
        return False
    
    resp = urllib2.urlopen('$$sut.url_base/items/new')
    body = resp.read()
    print("response of /items/new:%s" % body)
    if re.search(r'Description', body) == None:
        return False
    
    try:
        resp = urllib2.urlopen('$$sut.url_base/invalid_url')
    except urllib2.HTTPError, e:
        print("e.code:%d" % e.code)
        if e.code == 404:
            return True
    except:
        return False
    return False


if do_http_test():
   print "all tests passed ok"
   sys.exit(0)

print "one of the tests failes"
sys.exit(1)
