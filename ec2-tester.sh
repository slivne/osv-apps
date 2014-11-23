#!/bin/sh 
#
#  Copyright (C) 2013 Cloudius Systems, Ltd.
#
#  This work is open source software, licensed under the terms of the
#  BSD license as described in the LICENSE file in the top-level directory.
#


SRC_ROOT=`pwd`
AWS_REGION=us-east-1
AWS_ZONE=us-east-1c
AWS_PLACEMENT_GROUP=""
INSTANCE_TYPE=m3.xlarge
IMAGE_NAME=$SRC_ROOT/build/release.x64/usr.img
AMI_ID=""
OSV_VERSION=""
TESTS=""
SUT_OS=""
NO_KILL=0
EC2_KEYS=""

PARAM_HELP_LONG="--help"
PARAM_HELP="-h"
PARAM_SRC="--src"
PARAM_REGION="--region"
PARAM_ZONE="--zone"
PARAM_PLACEMENT_GROUP="--placement-group"
PARAM_IMAGE="--override-image"
PARAM_AMI="--ami"
PARAM_INSTANCE_TYPE="--instance-type"
PARAM_OSV_VERSION="--osv-version"
PARAM_SUT_OS="--sut-os"
PARAM_NO_KILL="--no-kill"
PARAM_EC2_KEY_NAME="--ec2-key"

print_help() {
 cat <<HLPEND

ec2_tester.sh [$PARAM_HELP] [$PARAM_HELP_LONG] [$PARAM_SRC src] [$PARAM_IMAGE image] [$PARAM_REGION region] [$PARAM_ZONE zone] [$PARAM_PLACEMENT_GROUP placement-group] [$PARAM_OSV_VERSION osv-version] test-directory ...

This script is used to run tests on an AWS against a spawnned aws node running an image

This script requires following Amazon credentials to be provided via environment variables:

    export AWS_ACCESS_KEY_ID=<Access key ID>
    export AWS_SECRET_ACCESS_KEY<Secret access key>

    See http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
    for more details

This script receives following command line arguments:
   
    $PARAM_HELP - print this help screen and exit
    $PARAM_SRC - osv src root
    $PARAM_REGION <region> - AWS region to work in
    $PARAM_ZONE <availability zone> - AWS availability zone to work in
    $PARAM_PLACEMENT_GROUP <placement group> - Placement group for instances created by this script
    $PARAM_IMAGE <image file> - do not rebuild OSv, upload specified image instead
    $PARAM_AMI <image file> - use specified ami
    $PARAM_INSTANCE_TYPE <ec2 instance type> - instance type to launch
    $PARAM_OSV_VERSION <osv-version> - osv version as string
    $PARAM_SUT_OS <os> - system under test os type
    $PARAM_NO_KILL - do not kill the SUT instances
    $PARAM_EC2_KEY_NAME <ec2-keys> - use the provided EC2 SSH key names
    <test directories> - list of test directories seperated by comma

HLPEND
}

while test "$#" -ne 0
do
  case "$1" in
    "$PARAM_SRC")
      SRC_ROOT=$2
      shift 2
      ;;
    "$PARAM_IMAGE")
      IMAGE_NAME=$2
      shift 2
      ;;
    "$PARAM_AMI")
      AMI_ID=$2
      shift 2
      ;;
    "$PARAM_INSTANCE_TYPE")
      INSTANCE_TYPE=$2
      shift 2
      ;;
    "$PARAM_REGION")
      AWS_REGION=$2
      shift 2
      ;;
    "$PARAM_ZONE")
      AWS_ZONE=$2
      shift 2
      ;;
    "$PARAM_PLACEMENT_GROUP")
      AWS_PLACEMENT_GROUP=$2
      shift 2
      ;;
    "$PARAM_OSV_VERSION")
      OSV_VERSION=$2
      shift 2
      ;;
    "$PARAM_SUT_OS")
      SUT_OS=$2
      shift 2
      ;;
    "$PARAM_NO_KILL")
      NO_KILL=1
	echo "instance will not be terminated, make sure to terminate it after the test"
      shift 1
      ;;
    "$PARAM_EC2_KEY_NAME")
      EC2_KEYS=" --ec2-key $EC2_KEY_NAME"
      shift 2
      ;;    
    "$PARAM_HELP")
      print_help
      exit 0
      ;;
    "$PARAM_HELP_LONG")
      print_help
      exit 0
      ;;
    *)
      if test x"$TESTS" = x""; then
         TESTS="$1"
      else
         TESTS="$TESTS $1"
      fi
      shift
      ;;
    esac
done

if test x"$TESTS" = x""; then
   print_help
   echo "no tests specified"
   exit 0
fi


SCRIPTS_ROOT="$SRC_ROOT/scripts"

. $SCRIPTS_ROOT/ec2-utils.sh

post_test_cleanup() {
 if test x"$TEST_INSTANCE_ID" != x""; then
	if test $NO_KILL = 1; then
		echo "stop_instance_forcibly " $TEST_INSTANCE_ID > clean_test.sh
		echo "wait_for_instance_shutdown " $TEST_INSTANCE_ID >> clean_test.sh
		echo "delete_instance " $TEST_INSTANCE_ID >> clean_test.sh
	else
    	stop_instance_forcibly $TEST_INSTANCE_ID
    	wait_for_instance_shutdown $TEST_INSTANCE_ID
    	delete_instance $TEST_INSTANCE_ID    	
	fi
	TEST_INSTANCE_ID=""
 fi
}

handle_test_error() {
 echo "=== Error occured. Cleaning up. ==="
 post_test_cleanup
 exit 1
}

create_ami() {

 if test x"$AWS_PLACEMENT_GROUP" != x""; then
  PLACEMENT_GROUP_PARAM="--placement-group $AWS_PLACEMENT_GROUP"
 fi

  echo "=== Create OSv instance ==="
 $SCRIPTS_ROOT/release-ec2.sh --private-ami-only \
                              --override-version $TEST_OSV_VER \
                              --region $AWS_REGION \
                              --zone $AWS_ZONE \
                              --override-image $IMAGE_NAME \
                            $EC2_KEYS \
                              $PLACEMENT_GROUP_PARAM || handle_test_error
 AMI_ID=`get_ami_id_by_name OSv-$TEST_OSV_VER`
 echo "AMI created $AMI_ID"
}


prepare_instance_for_test() {
echo "prepare_instance_for_test"
 PLACEMENT_GROUP_PARAM=""
 if test x"$AWS_PLACEMENT_GROUP" != x""; then
  PLACEMENT_GROUP_PARAM="--placement-group $AWS_PLACEMENT_GROUP"
 fi

 EC2_USER_DATA_PARAM=""
 if test x"$SUT_OS" != x""; then
    selector="ec2_$INSTANCE_TYPE"
    EC2_USER_DATA="`$SCRIPTS_ROOT/tester.py config-get sut.os.linux.ec2_user_data --config_param sut.ip:$TEST_INSTANCE_IP --config_param tester.ip:127.0.0.1 --config_selection $selector $TESTS`"
    EC2_USER_DATA_FILE="/tmp/ec2_user_data.$$"
    if test x"$EC2_USER_DATA" != x""; then
       $SCRIPTS_ROOT/tester.py config-get sut.os.$SUT_OS.ec2_user_data --config_param sut.ip:$TEST_INSTANCE_IP --config_param tester.ip:127.0.0.1 --config_selection $selector $TESTS > $EC2_USER_DATA_FILE
       EC2_USER_DATA_PARAM="--user-data-file $EC2_USER_DATA_FILE"
    fi
 fi

 TEST_INSTANCE_ID=`ec2-run-instances $AMI_ID --availability-zone $AWS_ZONE \
                                                  --instance-type $INSTANCE_TYPE \
                                                  $PLACEMENT_GROUP_PARAM \
                                                  $EC2_USER_DATA_PARAM \
												  $EC2_KEYS \
                                                  | tee /dev/tty | ec2_response_value INSTANCE INSTANCE`

 if test x"$TEST_INSTANCE_ID" = x""; then
    echo "Failed to create template instance."
    handle_test_error
    break;
 fi

 echo New instance ID is $TEST_INSTANCE_ID

 wait_for_instance_startup $TEST_INSTANCE_ID 300 || handle_test_error

 ec2-get-console-output $TEST_INSTANCE_ID

 echo Renaming newly created instance OSv-$OSV_VER
 rename_object $TEST_INSTANCE_ID $TEST_INSTANCE_NAME

 TEST_INSTANCE_IP=`get_instance_private_ip $TEST_INSTANCE_ID`

 if test x"$TEST_INSTANCE_IP" = x""; then
  handle_test_error
 fi
}

prepare_image_for_test() {
  echo "=== Update image according to tests ==="
  selector="ec2_$INSTANCE_TYPE"
  OSV_CMDLINE="`$SCRIPTS_ROOT/tester.py config-get sut.os.osv.cmdline --config_param sut.ip:$TEST_INSTANCE_IP --config_param tester.ip:127.0.0.1 --config_selection $selector $TESTS`"
  # TODO assuming all tests cmdlines are the same / all instance types are the same
  if test x"$OSV_CMDLINE" != x""; then
     echo "$SCRIPTS_ROOT/imgedit.py setargs $IMAGE_NAME $OSV_CMDLINE"
     $SCRIPTS_ROOT/imgedit.py setargs $IMAGE_NAME $OSV_CMDLINE
  fi
}

if test x"$OSV_VERSION" = x""; then
   OSV_VERSION=`$SCRIPTS_ROOT/osv-version.sh` 
fi
TEST_OSV_VER=$OSV_VERSION-ec2-tester-`timestamp`
TEST_INSTANCE_NAME=OSv-$TEST_OSV_VER

if test x"$AMI_ID" = x""; then
   prepare_image_for_test
   create_ami
fi
AMI_NAME=`get_ami_name_by_id $AMI_ID`
TEST_INSTANCE_NAME=OSv-`get_ami_name_by_id $AMI_ID`-ec2-tester-`timestamp`


ANY_TEST_FAILED=0
for TEST in "$TESTS";
do
  FAIL=0
  echo "=== create instance type $INSTANCE_TYPE for test $TEST ==="
  prepare_instance_for_test

sleep 240

  echo "=== Ping Host ==="
  ping -c 4 $TEST_INSTANCE_IP
  FAIL=$?

  if test $FAIL = 0; then
     echo "=== Run tester ==="
     # TODO FIX LOCAL IP
     selector="ec2_$INSTANCE_TYPE"
     echo "$SCRIPTS_ROOT/tester.py run --config_param sut.ip:$TEST_INSTANCE_IP --config_param tester.ip:127.0.0.1 --config_selection $selector $TEST"
     $SCRIPTS_ROOT/tester.py run --config_param sut.ip:$TEST_INSTANCE_IP --config_param tester.ip:127.0.0.1 --config_selection $selector $TEST
     FAILE=$?
  fi
  ec2-get-console-output $TEST_INSTANCE_ID
   
  echo "=== cleaning up for test $TEST ==="
  post_test_cleanup

  if test $FAIL != 0; then
     echo "=== test $TEST failed ==="
     ANY_TEST_FAILED=1
  fi
done

exit $ANY_TEST_FAILED

