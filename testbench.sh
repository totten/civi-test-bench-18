#!/bin/bash

if [ -z "$TRIAL" ]; then
  echo "usage: TRIAL=n ./testbench.sh"
  exit 1
fi

mkdir -p "trial-$TRIAL"
cd "trial-$TRIAL"

################################################################################
BLDINTERVAL=45
TESTINTERVAL=15
#SUITES="karma phpunit-api phpunit-civi phpunit-crm phpunit-e2e upgrade"
#SUITES="karma phpunit-e2e"
SUITES="phpunit-e2e phpunit-api phpunit-civi phpunit-crm"
#SUITES="phpunit-api phpunit-crm"
TIME=/usr/bin/time
#TIME=time
BLDNAME=dcbench

################################################################################
function dopause() {
  local count=$1
  shift
  echo "$@ Letting the system rest a moment ($count sec)..."
  sleep $count
}

function dobenchmark() {
  local RUNNAME="$1"
  local VER="$2"
  local LOG="$HOME/testbench-result/trial-$TRIAL/$RUNNAME"
  export CIVICRM_LOCALES=en_US,fr_FR
  mkdir -p "$LOG"

  if [ -e "$HOME/bknix/build/$BLDNAME" ]; then
    echo y | civibuild destroy $BLDNAME
  fi

  date | tee "$LOG/create.begin"
  env OFFLINE=1 \
    $TIME civibuild create $BLDNAME --type drupal-clean --civi-ver "$VER" 2>&1 | tee "$LOG/create.log"
  date | tee "$LOG/create.end"
  for SUITE in $SUITES ; do
    date | tee "$LOG/$SUITE.begin"
    mkdir "$LOG/$SUITE.junit"
    $TIME civi-test-run -b $BLDNAME -j "$LOG/$SUITE.junit" "$SUITE" 2>&1 | tee "${LOG}/${SUITE}.log"
    date | tee "$LOG/$SUITE.end"
    dopause $TESTINTERVAL "Finished test suite."
  done

  dopause $BLDINTERVAL "All done."
}

################################################################################
#dobenchmark dc4720 4.7.20
dobenchmark dc53 5.3
#dobenchmark dc50 5.0
#dobenchmark dc51 5.1
#dobenchmark dc52 5.2
dobenchmark dc54 5.4
#dobenchmark dc55 master
