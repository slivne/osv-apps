#!/bin/bash
set -e
memaslap -s $$sut.ip:11211 -t30s
