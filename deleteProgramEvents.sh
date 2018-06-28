#!/bin/bash
if [ -z "$3" ]; then
  echo "Example usage: ./deleteProgramEvents.sh <dhis_url:port> <dhis_password> <uid_of_a_program>"
  exit
fi

USERNAME=admin
DHIS_URL=$1
DHIS_PASSWORD=$2
PROGRAM_UID=$3
PAGE_SIZE=100000

mkdir -p logs

curl -k -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/26/events?pageSize=$PAGE_SIZE&program=$PROGRAM_UID" 2>/dev/null | \
  python3 -c "import sys, json; [print(el['href']) for el in json.load(sys.stdin)['events']]" | \
  while read url; do
     curl -k -X "DELETE" -u "$USERNAME:$DHIS_PASSWORD" $url 2>&1 | \
       awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> logs/delete_event_reports.log
  done
