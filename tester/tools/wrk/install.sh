#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir
if [ ! -d wrk ]; then
   git clone https://github.com/tgrabiec/wrk.git wrk
   cd wrk
   make
   cd ..
fi

echo export WRK="`pwd`/wrk/wrk" > setenv.sh
echo export WRKPARSE="`pwd`/wrkparse.py" >> setenv.sh
