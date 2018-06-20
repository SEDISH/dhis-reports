select json_object(
"dataElement", "nWxMCDOzaNt",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
select count(DISTINCT vtype.patient_id) as Total, vtype.encounter_date as Dt 
FROM isanteplus.visit_type vtype
WHERE vtype.concept_id=160288 AND v_type=1622
GROUP BY vtype.encounter_date
) A

