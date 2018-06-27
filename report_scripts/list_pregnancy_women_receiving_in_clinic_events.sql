-- List of visits by pregnant women to the clinic
DROP PROCEDURE IF EXISTS list_pregnancy_women_receiving_in_clinic_events;
DELIMITER $$
CREATE PROCEDURE list_pregnancy_women_receiving_in_clinic_events(IN org_unit VARCHAR(11))
BEGIN -- Vo6fHyvQhgJ TODO
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'mBMK6RRLKEZ';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "Vo6fHyvQhgJ",
          "orgUnit", org_unit,
          "eventDate", DATE_FORMAT(distinct_entity.start_date, date_format),
          "status", "COMPLETED",
          "storedBy", "admin",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "dataValues", JSON_ARRAY(
            JSON_OBJECT(
              "dataElement", "BruXV0FD2XS", -- No. de patient attribué par le site
              "value", distinct_entity.st_id
            ),
            JSON_OBJECT(
              "dataElement", "bzpXF1yVV74", -- No. dentité nationale
              "value", distinct_entity.national_id
            ),
            JSON_OBJECT(
              "dataElement", "vHkw3Habii4", -- Sexe
              "value", distinct_entity.gender
            ),
            JSON_OBJECT(
              "dataElement", "uSSFtn7oU2n", -- Age
              "value", distinct_entity.age
            ),
            JSON_OBJECT(
              "dataElement", "VT5fvNKFHr7", -- Date visite
              "value", distinct_entity.start_date
            )
          )
        ) AS tracked_entity
        FROM (SELECT DISTINCT p.st_id, p.national_id, p.given_name, p.family_name,
                p.gender, TIMESTAMPDIFF(YEAR, p.birthdate, NOW()) AS age, pp.start_date,
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
  INTO OUTFILE '/var/lib/mysql-files/list_pregnancy_women_receiving_in_clinic_events.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
