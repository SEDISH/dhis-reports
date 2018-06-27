DROP PROCEDURE IF EXISTS consultationByDay_tracked_entity;
DELIMITER $$
CREATE PROCEDURE consultationByDay_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Rnvvg6utP5O';

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
              "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
            )
          )
        ) AS track_entity
        FROM isanteplus.patient pat, openmrs.visit patvi, openmrs.location loc,
        openmrs.encounter enc, isanteplus.tmp_idgen tmp, openmrs.encounter_type enct
        WHERE pat.patient_id=patvi.patient_id
        AND patvi.visit_id=enc.visit_id
        AND enc.location_id=loc.location_id
        AND enc.encounter_type=enct.encounter_type_id
        AND tmp.identifier = pat.identifier
        AND tmp.program_id = program
      ) AS entities_list
    ) AS instance
  ) AS instances)
  INTO OUTFILE '/var/lib/mysql-files/consultationByDay_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
