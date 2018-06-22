#!/bin/bash
if [ -z "$1" ]
then
  echo 'Pass destination catalog as an argument'
else
  sudo find /var/lib/mysql-files/ | egrep 'patient_status.*\.json' | sudo xargs cp -t  $1
  sudo find /var/lib/mysql-files/ | egrep 'patient_status.*\.json' | sudo xargs rm
  sudo find $1 | egrep 'patient_status.*\.json' | sudo xargs  chmod -v 777
fi
