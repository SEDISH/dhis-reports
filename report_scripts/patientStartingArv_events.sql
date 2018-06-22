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
      SELECT DISTINCT JSON_OBJECT (
        "program", "ewmeREcqCmN",
        "programStage", "ZXfPQNL2Tmv",
        "orgUnit", @org_unit,
        "eventDate", DATE_FORMAT(pdis.visit_date, @date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
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
      FROM isanteplus.patient p,isanteplus.patient_dispensing pdis, (SELECT pdp.patient_id,MIN(pdp.visit_date) as visit_date FROM isanteplus.patient_dispensing pdp WHERE pdp.drug_id IN (select arvd.drug_id from isanteplus.arv_drugs arvd) GROUP BY 1) B
      WHERE p.patient_id=pdis.patient_id
      AND pdis.drug_id IN (select arvd.drug_id from isanteplus.arv_drugs arvd)
      AND B.patient_id = pdis.patient_id
      AND B.visit_date = pdis.visit_date
      AND p.patient_id NOT IN (SELECT ei.patient_id FROM isanteplus.exposed_infants ei)
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patientStartingArv_event.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
