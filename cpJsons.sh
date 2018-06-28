#!/bin/bash
if [ -z "$1" ]
then
  echo 'Pass destination catalog as an argument'
else
  sudo find /var/lib/mysql-files/ | egrep '.*\.json' | sudo xargs cp -t  $1
  sudo find /var/lib/mysql-files/ | egrep '.*\.json' | sudo xargs rm
  sudo find $1 | egrep '.*\.json' | sudo xargs  chmod -v 777 1> /dev/null
fi
