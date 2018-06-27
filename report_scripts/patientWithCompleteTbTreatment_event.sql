-- HIV patient with activity after discontinuation
DROP PROCEDURE IF EXISTS patientWithCompleteTbTreatment_event;
DELIMITER $$
CREATE PROCEDURE patientWithCompleteTbTreatment_event(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Bq4Kvi5KbiP';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "VQB3tC0FvOB",
          "orgUnit", org_unit,
          "eventDate", DATE_FORMAT(distinct_entity.visit_date, date_format),
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
              "dataElement", "ofp7LiAyMsW", -- Dernière date
              "value", DATE_FORMAT(distinct_entity.last_date, date_format)
            ),
            JSON_OBJECT(
              "dataElement", "uSSFtn7oU2n", -- Age
              "value", distinct_entity.age
            ),
            JSON_OBJECT(
              "dataElement", "vHkw3Habii4", -- Gender
              "value", distinct_entity.gender
            ),
            JSON_OBJECT(
              "dataElement", "ZffT4ZES0dI", -- Status de patient
              "value", distinct_entity.name_fr
            )
          )
        ) AS tracked_entity
        FROM (
          SELECT DISTINCT p.st_id, p.national_id, p.given_name,
            p.family_name,p.gender, TIMESTAMPDIFF(YEAR,p.birthdate,now()) AS age,
            stat.name_fr, p.last_visit_date AS last_date, tmp.program_patient_id,
            p.identifier, pdiag.visit_date
          FROM isanteplus.patient p
            INNER JOIN isanteplus.patient_tb_diagnosis pdiag
            ON pdiag.patient_id=p.patient_id
            LEFT OUTER JOIN isanteplus.arv_status_loockup stat
            ON stat.id=p.arv_status,
            isanteplus.tmp_idgen tmp
          WHERE pdiag.status_tb_treatment=2
            AND tmp.identifier = p.identifier
            AND tmp.program_id = program
        ) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances)
  INTO OUTFILE '/var/lib/mysql-files/patientWithCompleteTbTreatment_event.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
