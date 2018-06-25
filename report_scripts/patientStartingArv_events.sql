DROP PROCEDURE IF EXISTS patientStartingArv_events;
DELIMITER $$
CREATE PROCEDURE patientStartingArv_events(IN org_unit_code VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'ewmeREcqCmN';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "ZXfPQNL2Tmv",
        "orgUnit", org_unit_code,
        "eventDate", DATE_FORMAT(pdis.visit_date, date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", tmp.program_patient_id,
        "trackedEntityInstance", "bJxlK2l2TGx",
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "VT5fvNKFHr7", # Date visite
            "value", pdis.visit_date
          ),
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", p.national_id
          ),
          JSON_OBJECT(
            "dataElement", "XY1yClztxCG", # Date de naissance
            "value", p.birthdate
          )
        )
      ) AS track_entity
      FROM isanteplus.patient p,isanteplus.patient_dispensing pdis, (SELECT pdp.patient_id, MIN(pdp.visit_date) as visit_date
                                                                      FROM isanteplus.patient_dispensing pdp
                                                                      WHERE pdp.drug_id IN (select arvd.drug_id
                                                                                            from isanteplus.arv_drugs arvd)
                                                                      GROUP BY 1) B, isanteplus.tmp_idgen tmp
      WHERE p.patient_id=pdis.patient_id
      AND pdis.drug_id IN (select arvd.drug_id from isanteplus.arv_drugs arvd)
      AND B.patient_id = pdis.patient_id
      AND B.visit_date = pdis.visit_date
      AND p.patient_id NOT IN (SELECT ei.patient_id FROM isanteplus.exposed_infants ei)
      AND tmp.identifier = p.identifier
      AND tmp.program_id = program
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patientStartingArv_event.json';

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
