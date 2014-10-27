#!/bin/bash
set -e

if [ ! -d wrk ]; then
   git clone https://github.com/tgrabiec/wrk.git wrk
   cd wrk
   make
   cd ..

   echo export WRK="`pwd`/wrk/wrk" > setenv.sh
   echo export WRKPARSE="`pwd`/wrkparse.py" >> setenv.sh
fi
