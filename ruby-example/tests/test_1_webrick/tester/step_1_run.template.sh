#!/bin/bash
set -e

$WRK -c 128 -d 60s -t 4 http://$$sut.ip:8000/
