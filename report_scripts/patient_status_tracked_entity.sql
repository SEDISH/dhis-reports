USE isanteplus;
SET @default_group_concat_max_len = 1024;
SET @max_group_concat_max_len = 4294967295;
SET @date_format = '%Y-%m-%d';
SET @org_unit = 'Vih6emBLLmw';

SET SESSION group_concat_max_len = @max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT JSON_OBJECT (
        "trackedEntity", "MCPQUTHX1Ze",
        "orgUnit", @org_unit,
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
            "orgUnit", @org_unit,
            "program", "x2NBbIpHohD",
            "enrollmentDate", DATE_FORMAT(DATE(NOW()), @date_format),
            "incidentDate", DATE_FORMAT(MAX(patstatus.start_date), @date_format)
            )
          )
        ) AS track_entity
      FROM isanteplus.patient pat
      INNER JOIN isanteplus.patient_status_arv patstatus
      ON pat.patient_id=patstatus.patient_id
      INNER JOIN isanteplus.arv_status_loockup arv
      ON patstatus.id_status=arv.id
      GROUP BY pat.patient_id
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patient_status_tracked_entity.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
