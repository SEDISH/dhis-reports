USE isanteplus;
SET @default_group_concat_max_len = 1024;
SET @max_group_concat_max_len = 4294967295;
SET @date_format = '%Y-%m-%d';
SET @org_unit = 'Vih6emBLLmw';

SET SESSION group_concat_max_len = @max_group_concat_max_len;

SELECT (SELECT CONCAT( '{\"trackedEntityInstances\": ', instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "trackedEntity", "MCPQUTHX1Ze",
        "orgUnit", @org_unit,
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
            "orgUnit", @org_unit,
            "program", "ewmeREcqCmN",
            "enrollmentDate", DATE_FORMAT(DATE(NOW()), @date_format),
            "incidentDate", DATE_FORMAT(pdis.visit_date, @date_format)
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
INTO OUTFILE '/var/lib/mysql-files/patientStartingArv_tracked_entity.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
