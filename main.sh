#!/bin/bash
if [ -z "$3" ]; then
  echo "Example usage: sudo ./main.sh <dhis_url:port> <db_password> <dhis_password>";
  exit;
fi

USERNAME=admin
DHIS_URL=$1;
DB_PASS=$2;
DHIS_PASSWORD=$3;
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
mkdir -p $scriptDir/logs;

python $scriptDir/etl_extension/org_units/sync_org_unit.py $DB_PASS $DHIS_PASSWORD $DHIS_URL
$scriptDir/generateAllData.sh $DB_PASS;
$scriptDir/deleteAllProgramsData.sh $DHIS_URL $DHIS_PASSWORD;

curl -k -X POST -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/26/maintenance/analyticsTablesClear" 2>&1 | \
  awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> $scriptDir/logs/analyticsRun.log;

$scriptDir/sendAllData.sh $DHIS_URL $DHIS_PASSWORD;

curl -k -X POST -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/25/resourceTables/analytics" 2>&1 | \
  awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> $scriptDir/logs/analyticsRun.log;
