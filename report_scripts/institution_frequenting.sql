DROP VIEW IF EXISTS institutionFrequenting;

CREATE VIEW institutionFrequenting AS
SELECT DISTINCT p.patient_id, p.vih_status, p.date_created, enc.encounter_datetime
FROM isanteplus.patient p
LEFT OUTER JOIN openmrs.encounter enc
ON p.patient_id = enc.patient_id;

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "HtHMxWFa0ZO",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 1) THEN patient_id else null END) AS total,
    date_created AS period
  FROM institutionFrequenting
  GROUP BY date_created
) A

union

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "GPMeqcqFR6H",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 0) THEN patient_id else null END) AS total,
    date_created AS period
  FROM institutionFrequenting
  GROUP BY date_created
) A

union

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "dNQ5Qd5Ypu6",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 0 OR vih_status = 1) THEN patient_id else null END) AS total,
    date_created AS period
  FROM institutionFrequenting
  GROUP BY date_created
) A

union

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "jCChsvPa8ku",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 1) THEN patient_id else null END) AS total,
    encounter_datetime AS period
  FROM institutionFrequenting
  GROUP BY encounter_datetime, patient_id
) A

union

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "o0DVZV8QhCD",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 0) THEN patient_id else null END) AS total,
    encounter_datetime AS period
  FROM institutionFrequenting
  GROUP BY encounter_datetime, patient_id
) A

union

SELECT json_object(
"dataElement", "p8XJAdMAnry",
"categoryOptionCombo", "KI7XSbYybHF",
"value", total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
  SELECT
    COUNT(DISTINCT CASE WHEN (vih_status = 0 OR vih_status = 1) THEN patient_id else null END) AS total,
    encounter_datetime AS period
  FROM institutionFrequenting
  GROUP BY encounter_datetime, patient_id
) A;
