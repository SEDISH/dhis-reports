DROP PROCEDURE IF EXISTS hivPatientWithoutFirstVisit_event;
DELIMITER $$
CREATE PROCEDURE hivPatientWithoutFirstVisit_event(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'lV4LM75LrPt';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "DKSmlrXzuUX",
        "orgUnit", org_unit,
        "eventDate", DATE_FORMAT(MAX(DATE(enc.encounter_datetime)), date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", tmp.program_patient_id,
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "BruXV0FD2XS", # No. de patient attribué par le site
            "value", p.st_id
          ),
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", p.national_id
          ),
          JSON_OBJECT(
            "dataElement", "ofp7LiAyMsW", # Dernière date
            "value", MAX(DATE(enc.encounter_datetime))
          )
        )
      ) AS track_entity
      FROM isanteplus.patient p, openmrs.encounter enc,
        openmrs.encounter_type entype, isanteplus.tmp_idgen tmp
      WHERE p.patient_id=enc.patient_id
      AND enc.encounter_type=entype.encounter_type_id
      AND p.vih_status=1
      AND p.patient_id NOT IN (
        SELECT enco.patient_id
        FROM openmrs.encounter enco, openmrs.encounter_type enct
        WHERE enco.encounter_type=enct.encounter_type_id
        AND enct.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
          '349ae0b4-65c1-4122-aa06-480f186c8350')
      )
      AND tmp.identifier = p.identifier
      AND tmp.program_id = program
      GROUP BY p.patient_id
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/hiv_patient_without_first_visit_event.json';

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
