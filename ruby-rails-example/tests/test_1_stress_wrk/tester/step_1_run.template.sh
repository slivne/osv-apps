#!/bin/bash
set -e

$WRK -c 128 -d 60s -t 4 $$tester.url_base
$WRK -c 128 -d 60s -t 4 $$tester.url_base/items
