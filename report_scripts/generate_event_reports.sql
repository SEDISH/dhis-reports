USE isanteplus;

set @org_unit = 'Vih6emBLLmw';

CALL patient_status_tracked_entity(@org_unit);
CALL patientArvEnd_tracked_entity(@org_unit);
CALL patientNextArvInThirtyDay_tracked_entity(@org_unit);
CALL patientStartingArv_tracked_entity(@org_unit);
CALL visitNextFourteenDays_tracked_entity(@org_unit);
CALL visitNextSevenDays_tracked_entity(@org_unit);

CALL patient_status_events(@org_unit);
CALL patientArvEnd_event(@org_unit);
CALL patientNextArvInThirtyDay_event(@org_unit);
CALL patientStartingArv_events(@org_unit);
CALL visitNextFourteenDays_events(@org_unit);
CALL visitNextSevenDays_event(@org_unit);
