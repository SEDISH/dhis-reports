DROP PROCEDURE IF EXISTS patient_status_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patient_status_tracked_entity(IN program CHAR(11), IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT JSON_OBJECT (
          "trackedEntity", "MCPQUTHX1Ze",
          "trackedEntityInstance", tmp.program_patient_id,
          "orgUnit", org_unit,
          "attributes", JSON_ARRAY(
            JSON_OBJECT(
              "attribute", "py0TvSTBlrr",
              "value", pat.family_name
              ),
            JSON_OBJECT(
              "attribute", "uWUIkGpSMa6",
              "value", pat.given_name
              ),
            JSON_OBJECT(
              "attribute", "Cn9LcaW7Orr",
              "value", pat.identifier
              )
            ),
          "enrollments", JSON_ARRAY(
            JSON_OBJECT(
              "orgUnit", org_unit,
              "program", program,
              "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
              "incidentDate", DATE_FORMAT(MAX(patstatus.start_date), date_format)
              )
            )
          ) AS track_entity
        FROM isanteplus.patient pat
        INNER JOIN isanteplus.patient_status_arv patstatus
        ON pat.patient_id = patstatus.patient_id
        INNER JOIN isanteplus.arv_status_loockup arv
        ON patstatus.id_status = arv.id
        INNER JOIN isanteplus.tmp_idgen tmp
        ON tmp.identifier = pat.identifier
        AND tmp.program_id = program
        GROUP BY pat.patient_id
      ) AS entities_list
    ) AS instance
  ) AS instances)
  INTO OUTFILE '/var/lib/mysql-files/patient_status_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
