-- The list of patients whose ARV refill date is expected within the next 30 days.
DROP PROCEDURE IF EXISTS patientNextArvInThirtyDay_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patientNextArvInThirtyDay_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'cBI32y2KeC9';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "trackedEntity", "MCPQUTHX1Ze",
        "trackedEntityInstance", tmp.program_patient_id,
        "orgUnit", org_unit,
        "attributes", JSON_ARRAY(
        JSON_OBJECT(
          "attribute", "py0TvSTBlrr",
          "value", p.family_name
        ),
        JSON_OBJECT(
          "attribute", "uWUIkGpSMa6",
          "value", p.given_name
        ),
        JSON_OBJECT(
          "attribute", "Cn9LcaW7Orr",
          "value", p.identifier
        )
        ),
        "enrollments", JSON_ARRAY(
          JSON_OBJECT(
            "orgUnit", org_unit,
            "program", program,
            "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
            "incidentDate", DATE_FORMAT(pdisp.next_dispensation_date, date_format)
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
INTO OUTFILE '/var/lib/mysql-files/patientNextArvInThirtyDay_tracked_entity.json';

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
