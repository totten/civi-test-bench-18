#!/bin/bash

if [ -z "$TRIAL" ]; then
  echo "usage: TRIAL=n ./cleanup.sh"
  exit 1
fi
cd "trial-$TRIAL"
################################################################################

for d in dc* ; do 
  pushd "$d"
    mmv '*-start' '#1.begin'
    mmv '*-start ' '#1.begin'
    mmv '*-end' '#1.end'
    mmv '*-end ' '#1.end'
    mmv -r '*-junit' '#1.junit'
    
    for file in phpunit-*.log ; do
      cat "$file" | grep '\(ok\|not ok\)' | cut -f2,3,4 -d- | sed 's;data set #[0-9]\+ ;data set #X ;g' > "${file}-norm"
    done
  popd
done