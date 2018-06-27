USE isanteplus;

set @org_unit = 'duiCIjNovr0';

CALL hiv_patient_with_activity_after_disc_tracked_entity(@org_unit);
CALL patient_status_tracked_entity(@org_unit);
CALL patientArvEnd_tracked_entity(@org_unit);
CALL patientNextArvInThirtyDay_tracked_entity(@org_unit);
CALL patientStartingArv_tracked_entity(@org_unit);
CALL visitNextFourteenDays_tracked_entity(@org_unit);
CALL visitNextSevenDays_tracked_entity(@org_unit);
CALL consultationByDay_tracked_entity(@org_unit);
CALL hivPatientWithoutFirstVisit_tracked_entity(@org_unit);

CALL hiv_patient_with_activity_after_disc_events(@org_unit);
CALL patient_status_events(@org_unit);
CALL patientArvEnd_event(@org_unit);
CALL patientNextArvInThirtyDay_event(@org_unit);
CALL patientStartingArv_events(@org_unit);
CALL visitNextFourteenDays_events(@org_unit);
CALL visitNextSevenDays_event(@org_unit);
CALL consultationByDay_event(@org_unit);
CALL hivPatientWithoutFirstVisit_event(@org_unit);
