DROP PROCEDURE IF EXISTS generateID;
DELIMITER $$
CREATE PROCEDURE generateID(arg_id VARCHAR(32))
BEGIN
  DECLARE tmp_id INTEGER;
  DECLARE identifier VARCHAR(11);
  DECLARE result CHAR(11);
  DECLARE length INTEGER;
  DECLARE to_add INTEGER;

SET tmp_id = (SELECT id
            FROM tmp_idgen
            WHERE national_id = arg_id
            AND gen_timestamp = (SELECT MAX(gen_timestamp)
                                FROM tmp_idgen
                                WHERE national_id = arg_id));

SET identifier = CONCAT('R', tmp_id);
SET length = (SELECT LENGTH(identifier));

SET to_add = 11 - length;

WHILE to_add > 0 DO
  SET identifier = CONCAT(identifier, 0);
  SET to_add = to_add - 1;
END WHILE;

SET result = identifier;
SELECT result;

END $$
DELIMITER ;
