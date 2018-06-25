#!/bin/bash
if [ -z "$3" ]; then
  echo "Example usage: ./delete_events.sh <dhis_url> <dhis_password> <id_of_a_program>"
  exit
fi

USERNAME=admin
DHIS_URL=$1
DHIS_PASSWORD=$2
PROGRAM_ID=$3
PAGE_SIZE=10000

curl -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/26/events?pageSize=$PAGE_SIZE&program=$PROGRAM_ID" | \
  python3 -c "import sys, json; [print(el['href']) for el in json.load(sys.stdin)['events']]" | \
  while read url; do
     curl -X "DELETE" -u "$USERNAME:$DHIS_PASSWORD" $url 
  done
