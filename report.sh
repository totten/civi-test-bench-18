#!/bin/bash

if [ -z "$TRIAL" ]; then
  echo "usage: TRIAL=n ./report.sh"
  exit 1
fi
set -ex
cd "trial-$TRIAL"
################################################################################

for d in dc* ; do
  echo
  pushd "$d" >> /dev/null
    echo "[[Steps for $d]]"
    for step in create karma upgrade phpunit-{api,civi,crm,e2e}; do
      echo "$d/$step :: $(cat $step.begin) => $(cat $step.end)"
    done
    
    echo "[[Test counts for $d]]"
    echo "$d/all :: " $(grep -a 'ok\|not ok' phpunit*.log | wc --lines) 
    for step in phpunit-{api,civi,crm,e2e} ; do
      echo "$d/$step :: " $( grep -a 'ok\|not ok' "$step.log" | wc --lines )
    done
    
    echo "[[All times for $d]]"
    cat *.begin *.end | sort
  popd >> /dev/null
done