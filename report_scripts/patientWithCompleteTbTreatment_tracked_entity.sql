-- HIV patient with activity after discontinuation
DROP PROCEDURE IF EXISTS patientWithCompleteTbTreatment_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patientWithCompleteTbTreatment_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Bq4Kvi5KbiP';

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
        FROM (
          SELECT DISTINCT p.st_id, p.national_id, p.given_name,
            p.family_name,p.gender, TIMESTAMPDIFF(YEAR,p.birthdate,now()) AS age,
            stat.name_fr, p.last_visit_date AS last_date, tmp.program_patient_id,
            p.identifier
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
  INTO OUTFILE '/var/lib/mysql-files/patientWithCompleteTbTreatment_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
