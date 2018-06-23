-- The list of patients whose ARV refill date has expired
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
        "program", "JnV2CR1UKIZ",
        "programStage", "IqJDiNsnzI5",
        "orgUnit", @org_unit,
        "eventDate", DATE_FORMAT(pdisp.next_dispensation_date, @date_format),
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", "bJxlK2l2TGx",
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", # No. dentité nationale
            "value", p.national_id
          ),
          JSON_OBJECT(
            "dataElement", "XY1yClztxCG", # Date de naissance
            "value", p.birthdate
          ),
          JSON_OBJECT(
            "dataElement", "wyq5jC0iOBR", # Date de dispensation
            "value", pdisp.next_dispensation_date
          ),
          JSON_OBJECT(
            "dataElement", "VT5fvNKFHr7", # Date Visite
            "value", pdisp.visit_date
          )
        )
      ) AS track_entity
      FROM
      isanteplus.patient p, isanteplus.patient_dispensing pdisp,
      (SELECT pad.patient_id, MAX(pad.next_dispensation_date) as next_dispensation_date FROM isanteplus.patient_dispensing pad GROUP BY 1) B
      WHERE p.patient_id = pdisp.patient_id
      AND pdisp.patient_id = B.patient_id
      AND pdisp.next_dispensation_date = B.next_dispensation_date
      AND (TIMESTAMPDIFF(DAY,pdisp.next_dispensation_date,DATE(now())) BETWEEN 0 AND 90)
      AND p.patient_id NOT IN(SELECT dreason.patient_id FROM isanteplus.discontinuation_reason dreason WHERE dreason.reason IN(159,1667,159492))
      AND pdisp.arv_drug = 1065
      AND pdisp.drug_id NOT IN (select pp.drug_id FROM isanteplus.patient_prescription pp WHERE pp.patient_id = pdisp.patient_id
      AND pp.encounter_id = pdisp.encounter_id AND pp.drug_id = pdisp.drug_id AND pp.rx_or_prophy = 163768)
      GROUP BY pdisp.visit_date, p.st_id, p.national_id, p.given_name, p.family_name, p.birthdate, pdisp.next_dispensation_date
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/patientArvEnd_event.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
