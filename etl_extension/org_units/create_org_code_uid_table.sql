CREATE TABLE IF NOT EXISTS org_code_uid (
  uid VARCHAR(32) PRIMARY KEY,
  code TEXT DEFAULT NULL,
  `path` VARCHAR(255) DEFAULT NULL
);
