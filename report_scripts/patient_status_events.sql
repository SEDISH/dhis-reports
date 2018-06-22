USE isanteplus;
SET @default_group_concat_max_len = 1024;
SET @max_group_concat_max_len = 4294967295;
SET @date_format = '%Y-%m-%d';
SET @org_unit = 'Vih6emBLLmw';

SET SESSION group_concat_max_len = @max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT JSON_OBJECT (
        "program", "x2NBbIpHohD",
        "programStage", "ROWwGepZ2yb",
        "orgUnit", @org_unit,
        "eventDate", DATE_FORMAT(MAX(patstatus.start_date), @date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", "bJxlK2l2TGx",
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "EhQ157ZZMny", # Contact
            "value", pat.mother_name
            ),
          JSON_OBJECT(
            "dataElement", "uSSFtn7oU2n", # Age
            "value", TIMESTAMPDIFF(YEAR, pat.birthdate, DATE(now()))
            ),
          JSON_OBJECT(
            "dataElement", "ofp7LiAyMsW", # Dernière date
            "value", MAX(patstatus.start_date)
            ),
          JSON_OBJECT(
            "dataElement", "vHkw3Habii4", # Gender
            "value", pat.gender
            ),
          JSON_OBJECT(
            "dataElement", "BruXV0FD2XS", # No. de patient attribué par le site
            "value", pat.st_id
            ),
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", pat.national_id
            ),
          JSON_OBJECT(
            "dataElement", "BaofPATSdwD", # Raison de discontinuation
            "value",  CASE
                        WHEN(patstatus.dis_reason=5240) THEN 'Perdu de vue'
                        WHEN (patstatus.dis_reason=159492) THEN 'Transfert'
                        WHEN (patstatus.dis_reason=159) THEN 'Décès'
                        WHEN (patstatus.dis_reason=1667) THEN 'Discontinuations'
                        WHEN (patstatus.dis_reason=1067) THEN 'Inconnue'
                      END
            ),
          JSON_OBJECT(
            "dataElement", "uliVoL9otho", # Telephone
            "value", pat.telephone
            ),
          JSON_OBJECT(
            "dataElement", "ZffT4ZES0dI", # Status de patient
            "value", arv.name_fr
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
INTO OUTFILE '/var/lib/mysql-files/patient_status_event.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
