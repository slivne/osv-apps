#!/bin/bash

set -e

echo "api/os/name start"
curl -s http://$1:8000/os/name 
echo "api/os/name end"
