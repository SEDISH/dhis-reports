-- List of visits by pregnant women to the clinic
DROP PROCEDURE IF EXISTS list_pregnancy_women_receiving_in_clinic_tracked_entity;
DELIMITER $$
CREATE PROCEDURE list_pregnancy_women_receiving_in_clinic_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'mBMK6RRLKEZ';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  CALL patient_insert_idgen(program);

  SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT JSON_OBJECT (
          "trackedEntity", "MCPQUTHX1Ze",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "orgUnit", org_unit,
          "attributes", JSON_ARRAY(
            JSON_OBJECT(
              "attribute", "py0TvSTBlrr",
              "value", distinct_entity.family_name
              ),
            JSON_OBJECT(
              "attribute", "uWUIkGpSMa6",
              "value", distinct_entity.given_name
              ),
            JSON_OBJECT(
              "attribute", "Cn9LcaW7Orr",
              "value", distinct_entity.identifier
              )
            ),
          "enrollments", JSON_ARRAY(
            JSON_OBJECT(
              "orgUnit", org_unit,
              "program", program,
              "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
              "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
              )
            )
          ) AS track_entity
        FROM (SELECT DISTINCT p.st_id, p.national_id A, p.given_name, p.family_name,
                p.gender, TIMESTAMPDIFF(YEAR, p.birthdate, NOW()) AS Age, pp.start_date,
                p.identifier, tmp.program_patient_id
              FROM isanteplus.patient p, isanteplus.patient_pregnancy pp, tmp_idgen tmp,
              (SELECT pap.patient_id, MAX(pap.start_date) as start_date FROM isanteplus.patient_pregnancy pap GROUP BY 1) B
              WHERE p.patient_id=pp.patient_id
              AND pp.patient_id = B.patient_id
              AND pp.start_date = B.start_date
              AND p.gender <> 'M'
              AND tmp.identifier = p.identifier
              AND tmp.program_id = program
              ORDER BY pp.start_date DESC) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances)
  INTO OUTFILE '/var/lib/mysql-files/list_pregnancy_women_receiving_in_clinic_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
