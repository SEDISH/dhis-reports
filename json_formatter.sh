#!/bin/bash
if [ -z "$1" ]; then
  echo "Name of script is required."
  exit
fi

echo "Executing $1 script"
USER=root
DB=isanteplus
DB_PASSWORD=password

mkdir -p report_results
mysql -u $USER -p$DB_PASSWORD $DB < report_scripts/$1 | sed 's/}/},/g' | sed 1d | sed '$ s/.$//' > report_results/$1-results.json
echo "Results saved to: $1-results.json"
