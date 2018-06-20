select json_object(
"dataElement", "VJerPEgdSX3",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
SELECT COUNT(DISTINCT pv.patient_id) AS Total, pv.encounter_date AS Dt
FROM isanteplus.pediatric_hiv_visit pv
WHERE pv.prophylaxie72h=1065
GROUP BY pv.encounter_date
) A
