#!/bin/bash
if [ -z "$1" ]; then
  echo "type db password"
  exit
fi

USER=root
DB=isanteplus

# create procedure for etl
mysql -u $USER -p$1 -D $DB -e "source ./org_unit_etl_extension.sql";

# create procedures for convertion
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/hiv_patient_with_activity_after_disc_events.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/hiv_patient_with_activity_after_disc_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/idgen.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patient_status_events.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patient_insert_idgen.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patient_status_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientArvEnd_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientArvEnd_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientNextArvInThirtyDay_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientNextArvInThirtyDay_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientStartingArv_events.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patientStartingArv_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/visitNextFourteenDays_events.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/visitNextFourteenDays_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/visitNextSevenDays_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/visitNextSevenDays_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patient_with_only_register_form_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/patient_with_only_register_form_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/consultationByDay_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/consultationByDay_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/hiv_patient_without_first_visit_event.sql";
mysql -u $USER -p$1 -D $DB -e "source ./report_scripts/hiv_patient_without_first_visit_tracked_entity.sql";

#  generate and format the data
mkdir -p report_results
mysql -u $USER -p$1 $DB < report_scripts/generate_event_reports.sql
./cp_jsons.sh ./report_results/

./json_formatter.sh communityArvDistribution.sql  $1
./json_formatter.sh exposed_infants_register_in_ptme_program.sql  $1
./json_formatter.sh hiv_transmission_risks_factor.sql  $1
./json_formatter.sh number_eligible_children_for_pcr.sql  $1
./json_formatter.sh number_exposed_infants_tested_by_pcr.sql  $1
./json_formatter.sh number_infants_from_mother_on_prophylaxis.sql  $1
./json_formatter.sh numberOfPatientByArvStatus.sql  $1
./json_formatter.sh number_patient_beneficie_pcr.sql  $1
./json_formatter.sh numberPatientReceivingARVByPeriod.sql  $1
./json_formatter.sh number_pregnancy_women_had_prenatal_cons.sql  $1
./json_formatter.sh number_prenatal_visit_by_site.sql  $1
./json_formatter.sh number_visits_by_pregnant_women_to_the_clinic.sql  $1
./json_formatter.sh pregnancy_women_on_haart.sql  $1
./json_formatter.sh firstVisitAge.sql  $1
