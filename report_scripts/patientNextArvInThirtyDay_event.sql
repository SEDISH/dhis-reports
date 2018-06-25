-- The list of patients whose ARV refill date is expected within the next 30 days.
DROP PROCEDURE IF EXISTS patientNextArvInThirtyDay_event;
DELIMITER $$
CREATE PROCEDURE patientNextArvInThirtyDay_event(IN org_unit_code VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'cBI32y2KeC9';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT JSON_OBJECT (
        "program", program,
        "programStage", "yzcSkGEI4qe",
        "orgUnit", org_unit_code,
        "eventDate", DATE_FORMAT(pdisp.next_dispensation_date, date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", tmp.program_patient_id,
        "trackedEntityInstance", "bJxlK2l2TGx",
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", p.national_id
          ),
          JSON_OBJECT(
            "dataElement", "XY1yClztxCG", # Date de naissance
            "value", p.birthdate
          ),
          JSON_OBJECT(
            "dataElement", "wyq5jC0iOBR", # Date de dispensation
            "value", pdisp.next_dispensation_date
          ),
          JSON_OBJECT(
            "dataElement", "VT5fvNKFHr7", # Date Visite
            "value", pdisp.visit_date
          )
        )
      ) AS track_entity
      FROM
      isanteplus.patient p, isanteplus.patient_dispensing pdisp,
      (SELECT pad.patient_id, MAX(pad.next_dispensation_date) as next_dispensation_date
        FROM isanteplus.patient_dispensing pad GROUP BY 1) B, isanteplus.tmp_idgen tmp
      WHERE p.patient_id=pdisp.patient_id
      AND pdisp.patient_id = B.patient_id
      AND pdisp.next_dispensation_date = B.next_dispensation_date
      AND p.patient_id NOT IN(SELECT dreason.patient_id
        FROM isanteplus.discontinuation_reason dreason WHERE dreason.reason IN(159,1667,159492))
      AND pdisp.arv_drug = 1065
      AND tmp.identifier = p.identifier
      AND tmp.program_id = program
      AND p.patient_id NOT IN (SELECT ei.patient_id FROM isanteplus.exposed_infants ei)
      AND pdisp.drug_id NOT IN (select pp.drug_id
        FROM isanteplus.patient_prescription pp WHERE pp.patient_id = pdisp.patient_id
      AND pp.encounter_id = pdisp.encounter_id AND pp.drug_id = pdisp.drug_id AND pp.rx_or_prophy = 163768)
      AND DATEDIFF(pdisp.next_dispensation_date,now()) between 0 and 30
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patientNextArvInThirtyDay_event.json';

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
