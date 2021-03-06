#!/bin/sh 
#  Copyright (C) 2013 Cloudius Systems, Ltd.

PARAM_HELP_LONG="--help"
PARAM_ALL_FILES="--all"
PARAM_IMAGE="--image"

ALL_FILES=0
IMAGE=""
ROOT_SRC=$(pwd)

if test x"$TEST_BUCKET" = x""; then
  TEST_BUCKET=""
fi

print_help() {
 cat <<HLPEND

fetch_results.sh [$PARAM_HELP_LONG] TEST_BUCKET

Download tests results from a bucket, the test bucket can be a full path
to a file.

If it's a bucket name, the latest test will be retrieve

This script receives following command line arguments:   
    $PARAM_HELP_LONG - print this help screen and exit
    $PARAM_ALL_FILES - retrieve all files in the bucket
    $PARAM_IMAGE - return results of a specific image type
    <bucket_name> - bucket name to download, can be set with BUCKET_DIR environment
HLPEND
}

while test "$#" -ne 0
do
  case "$1" in
    "$PARAM_HELP_LONG_SRC")
      print_help
      exit -1
      ;;
    "$PARAM_ALL_FILES")
      ALL_FILES=1
      shift
      ;;
    "$PARAM_IMAGE")
      IMAGE="$2"
      shift 2
      ;;
      *)
      TEST_BUCKET=$1
      shift
      ;;
  esac
done


if [ "$TEST_BUCKET" = "" ]; then
    print_help
    exit -1
fi


handle_file() {
    NAME=$1
     if [[ $NAME  =~ ([^/]+)\.zip$ ]]; then
        FILE_NAME="${BASH_REMATCH[1]}"
        if [ $IMAGE == "" ]; then
          OUT_DIR="$FILE_NAME"
        else
          OUT_DIR="$IMAGE/$FILE_NAME"
        fi
        if [ -d "$OUT_DIR" ]; then
          echo "$OUT_DIR exists, skipping"
        else
	        mkdir -p "$OUT_DIR"
	        cd "$OUT_DIR" || exit -1
	        s3cmd get "$NAME"
	        unzip ./*.zip
	        rm "$FILE_NAME".zip
	        for f in *.json; do
             $ROOT_SRC/statjson.py $f > "$IMAGE.json"
#	           	           $ROOT_SRC/memaslap2json.py --delimiter '>>>>>>> end <<<<<<<' $f | $ROOT_SRC/statjson.py > "$f.json"
	        done
	        cd -
        fi
     fi 
}

if [[ "$TEST_BUCKET" == *.zip ]]; then
  handle_file "$TEST_BUCKET"
else
  if [ "$ALL_FILES" -eq 0 ]; then
    FILE=$(s3cmd ls "$TEST_BUCKET/$IMAGE"/* | awk '{print $4}' |sort | tail -1)
    handle_file "$FILE"
  else
    FILES=$(s3cmd ls "$TEST_BUCKET/$IMAGE"/* | awk '{print $4}')
    for FILE in ${FILES} ;
    do
       handle_file "$FILE"
    done
  fi
fi
#FILE=$1"."`date +"%y-%m-%d_%H-%M-%S"`.zip
#cd $2
#zip -r $FILE *
#s3cmd put $FILE $BUCKET
#rm $FILE 