# List of patients who started an HAART regimen
DROP PROCEDURE IF EXISTS patientStartingArv_events;
DELIMITER $$
CREATE PROCEDURE patientStartingArv_events(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'ewmeREcqCmN';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "ZXfPQNL2Tmv",
        "orgUnit", org_unit,
        "eventDate", DATE_FORMAT(distinct_entity.visit_date, date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", distinct_entity.program_patient_id,
        "trackedEntityInstance", "bJxlK2l2TGx",
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "VT5fvNKFHr7", # Date visite
            "value", distinct_entity.visit_date
          ),
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", distinct_entity.national_id
          ),
          JSON_OBJECT(
            "dataElement", "XY1yClztxCG", # Date de naissance
            "value", distinct_entity.birthdate
          )
        )
      ) AS tracked_entity
      FROM (SELECT DISTINCT MIN(DATE(pdis.visit_date)) as visit_date, p.national_id, p.given_name,
            p.family_name, p.birthdate, tmp.program_patient_id, p.identifier
            FROM isanteplus.patient p,isanteplus.patient_dispensing pdis, isanteplus.tmp_idgen tmp
            WHERE p.patient_id=pdis.patient_id
            AND pdis.drug_id IN (select arvd.drug_id from isanteplus.arv_drugs arvd)
            AND pdis.visit_date=(SELECT MIN(pdp.visit_date) FROM isanteplus.patient_dispensing pdp WHERE pdp.patient_id=p.patient_id)
            AND tmp.identifier = p.identifier
            AND tmp.program_id = program
            GROUP BY p.patient_id) AS distinct_entity
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patientStartingArv_event.json';

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
