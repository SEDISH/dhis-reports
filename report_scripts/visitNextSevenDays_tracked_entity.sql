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
      SELECT DISTINCT JSON_OBJECT (
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
            "program", "iTlI6sz0KWM",
            "enrollmentDate", DATE_FORMAT(DATE(NOW()), @date_format),
            "incidentDate", DATE_FORMAT(NOW(), @date_format)
          )
        )
      ) AS track_entity
      FROM (
        select DISTINCT pa.st_id, pa.national_id, pa.identifier, pa.given_name, pa.family_name,
          pa.gender, TIMESTAMPDIFF(YEAR, pa.birthdate,DATE(now())) as age, pa.telephone, f.name,
          asl.name_fr, DATE_FORMAT(pv.next_visit_date, "%d-%m-%Y") as nextVisit
        from isanteplus.patient pa, isanteplus.patient_visit pv, openmrs.form f,
          isanteplus.arv_status_loockup asl
        where pa.patient_id=pv.patient_id AND pv.form_id=f.form_id and pa.arv_status = asl.id
        and pv.next_visit_date between date(now()) and date_add(date(now()),interval 7 day)

        UNION

        select DISTINCT pa.st_id, pa.national_id, pa.identifier, pa.given_name, pa.family_name,
          pa.gender, TIMESTAMPDIFF(YEAR, pa.birthdate,DATE(now())) as age, pa.telephone, f.name,
          asl.name_fr, DATE_FORMAT(pd.next_dispensation_date, "%d-%m-%Y") as nextVisit
        from isanteplus.patient pa, isanteplus.patient_dispensing pd, openmrs.encounter enc,
          openmrs.form f, isanteplus.arv_status_loockup asl
        where pa.patient_id=pd.patient_id
        AND pd.encounter_id=enc.encounter_id
        AND enc.form_id=f.form_id
        AND pa.arv_status = asl.id
        and pd.next_dispensation_date between date(now()) and date_add(date(now()),interval 7 day)
      ) pat
    ) AS entities_list
  ) AS instance
) AS instances)
INTO OUTFILE '/var/lib/mysql-files/visitNextSevenDays_tracked_entity.json';

SET SESSION group_concat_max_len = @default_group_concat_max_len;
