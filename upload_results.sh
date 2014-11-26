#!/bin/sh 
#  Copyright (C) 2013 Cloudius Systems, Ltd.

if [ $# -lt 3 ]; then
    echo "Usage: upload_results name dir-path bucket [bucket-dir]"
    exit -1
fi

if [ $# -lt 4 ]; then
  BUCKET="$3/"
else
  BUCKET="$3$4/"
fi
FILE="$1."$(date +"%y-%m-%d_%H-%M-%S").zip
cd "$2"
zip -r "$FILE" ./*
s3cmd put "$FILE" "$BUCKET$FILE"
rm "$FILE"
