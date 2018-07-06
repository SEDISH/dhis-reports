DROP VIEW IF EXISTS frequencyPrenatalVisitsPerPatient;

CREATE VIEW frequencyPrenatalVisitsPerPatient AS
SELECT vtype.patient_id,COUNT(*) AS total, vtype.encounter_date AS period
FROM isanteplus.visit_type vtype
WHERE vtype.concept_id=160288
AND vtype.v_type=1622
GROUP BY vtype.patient_id;

SELECT json_object(
"dataElement", "QUAy1Pp8ul0",
"categoryOptionCombo", "nqKuufIauMT",
"value", total2,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(distinct CASE WHEN (total = 1) THEN patient_id ELSE null END) AS total2,
    period
  FROM frequencyPrenatalVisitsPerPatient
  GROUP BY period
) A

union

SELECT json_object(
"dataElement", "QUAy1Pp8ul0",
"categoryOptionCombo", "wsjaSFgvsbe",
"value", total2,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(distinct CASE WHEN (total = 2) THEN patient_id ELSE null END) AS total2,
    period
  FROM frequencyPrenatalVisitsPerPatient
  GROUP BY period
) A

union

SELECT json_object(
"dataElement", "QUAy1Pp8ul0",
"categoryOptionCombo", "SUk8M0l3Uu0",
"value", total2,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(distinct CASE WHEN (total = 3) THEN patient_id ELSE null END) AS total2,
    period
  FROM frequencyPrenatalVisitsPerPatient
  GROUP BY period
) A

union

SELECT json_object(
"dataElement", "QUAy1Pp8ul0",
"categoryOptionCombo", "HzDKFjvs4q8",
"value", total2,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(distinct CASE WHEN (total >= 4) THEN patient_id ELSE null END) AS total2,
    period
  FROM frequencyPrenatalVisitsPerPatient
  GROUP BY period
) A
