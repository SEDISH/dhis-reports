USE isanteplus;

CALL org_unit_etl_extension();
CALL dashboard_etl_extension();

CALL hiv_patient_with_activity_after_disc_tracked_entity();
CALL patient_status_tracked_entity();
CALL patientArvEnd_tracked_entity();
CALL patientNextArvInThirtyDay_tracked_entity();
CALL patientStartingArv_tracked_entity();
CALL visitNextFourteenDays_tracked_entity();
CALL patient_with_only_register_form_tracked_entity();
CALL visitNextSevenDays_tracked_entity();
-- CALL consultationByDay_tracked_entity();
CALL hivPatientWithoutFirstVisit_tracked_entity();
-- CALL consultationByDay_tracked_entity();
CALL dashboard_tracked_entity();

CALL hiv_patient_with_activity_after_disc_events();
CALL patient_status_event();
CALL patientArvEnd_event();
CALL patientNextArvInThirtyDay_event();
CALL patientStartingArv_events();
CALL visitNextFourteenDays_events();
CALL patient_with_only_register_form_event();
CALL visitNextSevenDays_event();
-- CALL consultationByDay_event();
CALL hivPatientWithoutFirstVisit_event();
-- CALL consultationByDay_event();
CALL dashboard_event();
