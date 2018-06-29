#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Example usage: ./deleteAllProgramsData.sh <dhis_url:port> <dhis_password>"
  exit
fi

DHIS_URL=$1
DHIS_PASSWORD=$2

./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD mfyC6GCw1IH # hiv_patient_with_activity_after_disc
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD mBMK6RRLKEZ # list_pregnancy_women_receiving_in_clinic
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD x2NBbIpHohD # patient_status
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD JnV2CR1UKIZ # patientArvEnd
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD cBI32y2KeC9 # patientNextArvInThirtyDay
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD ewmeREcqCmN # patientStartingArv
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD rCJQM1bvXYm # visitNextFourteenDays
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD Lh9TkmcZf4a # patient_with_only_register_form
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD iTlI6sz0KWM # visitNextSevenDays
# ./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD Rnvvg6utP5O # consultationByDay
./deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD lV4LM75LrPt # hivPatientWithoutFirstVisit
