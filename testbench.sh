#!/bin/bash

function dobenchmark() {
  local BLDNAME="$1"
  local VER="$2"
  local LOG="$HOME/testbench-result/$BLDNAME"
  mkdir -p "$LOG" "$LOG/junit"

  if [ -e "$HOME/bknix/build/dcbench" ]; then
    echo y | civibuild destroy dcbench
  fi

  date > "$LOG/create-start"
  time civibuild create dcbench --type drupal-clean --civi-ver "$VER" 2>&1 | tee "$LOG/create.log"
  date > "$LOG/create-end"
  for SUITE in karma phpunit-api phpunit-civi phpunit-crm phpunit-e2e upgrade ; do
  #for SUITE in karma phpunit-e2e ; do
    date > "$LOG/$SUITE-start"
    time civi-test-run -b dcbench -j "$LOG/junit" "$SUITE" | tee "${LOG}/${SUITE}.log"
    date > "$LOG/$SUITE-end"
  done
}

#####

dobenchmark dc4720 4.7.20
dobenchmark dc53 5.3
dobenchmark dc50 5.0
dobenchmark dc51 5.1
dobenchmark dc52 5.2
dobenchmark dc54 5.4
dobenchmark dc55 master
