DROP PROCEDURE IF EXISTS org_unit_etl_extension;
DELIMITER $$
CREATE PROCEDURE org_unit_etl_extension()
BEGIN
  DECLARE attr_type TEXT;

  ALTER TABLE patient
  ADD COLUMN attribute_reference TEXT DEFAULT NULL
  AFTER last_updated_date;

  SET attr_type = (SELECT location_attribute_type_id
                    FROM `openmrs`.location_attribute_type
                    WHERE uuid = '6242bf19-207e-4076-9d28-9290525b8ed9');

  SET SQL_SAFE_UPDATES = 0;
  UPDATE patient p, `openmrs`.location_attribute loc_attr
  SET attribute_reference = loc_attr.value_reference, last_updated_date = NOW()
  WHERE p.location_id = loc_attr.location_id
  AND loc_attr.attribute_type_id = attr_type
  AND attribute_reference = NULL;

  SET SQL_SAFE_UPDATES = 1;

END $$
DELIMITER ;
