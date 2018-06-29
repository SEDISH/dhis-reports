#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Example usage: ./sendAllData.sh <dhis_url:port> <dhis_password>";
  exit;
fi

USERNAME=admin;
DHIS_URL=$1;
DHIS_PASSWORD=$2;
PAGE_SIZE=100000;
MATCH_FILE='.*\.json';
JSON_CATALOG='./report_results/';
SUBURL='/api/26';
ADD_PARAMS='';

function send_files() {
  find $JSON_CATALOG | egrep $MATCH_FILE | \
  while read path; do
    LOG_FILE=$( echo $path | sed 's/.*\///' | sed 's/\.json/.log/' | sed 's/^/post_/');
    curl -k -d "@$path"  -H "Content-Type: application/json" -X POST -u "$USERNAME:$DHIS_PASSWORD" \
        "http://$DHIS_URL/api/26/$SUBURL$ADD_PARAMS" 2>&1 | \
      awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> logs/$LOG_FILE;
  done
}

mkdir -p logs;

MATCH_FILE='.*\_tracked_entity.json';
SUBURL='trackedEntityInstances';
ADD_PARAMS='?importStrategy=CREATE_AND_UPDATE'; # Add &orgUnitIdScheme=code here in order to use organization code
send_files;

MATCH_FILE='.*\_event.json';
SUBURL='events';
ADD_PARAMS='?importStrategy=CREATE_AND_UPDATE'; # Add &orgUnitIdScheme=code here in order to use organization code
send_files;

MATCH_FILE='.*\.sql-results.json';
SUBURL='dataValueSets';
ADD_PARAMS='?strictCategoryOptionCombos=true&orgUnitIdScheme=code';
send_files;
