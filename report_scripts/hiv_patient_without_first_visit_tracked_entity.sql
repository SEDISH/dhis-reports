DROP PROCEDURE IF EXISTS hivPatientWithoutFirstVisit_tracked_entity;
DELIMITER $$
CREATE PROCEDURE hivPatientWithoutFirstVisit_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'lV4LM75LrPt';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  CALL patient_insert_idgen(program);

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
              "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
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
  INTO OUTFILE '/var/lib/mysql-files/hiv_patient_without_first_visit_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
