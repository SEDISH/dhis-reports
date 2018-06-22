USE isanteplus;

CREATE TABLE IF NOT EXISTS tmp_idgen (
  id INT AUTO_INCREMENT PRIMARY KEY,
  national_id VARCHAR(32) NOT NULL,
  gen_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  program_patient_id CHAR(11);
);

INSERT INTO tmp_idgen(national_id)
  SELECT pat.identifier
  FROM isanteplus.patient pat
  INNER JOIN isanteplus.patient_status_arv patstatus
  ON pat.patient_id=patstatus.patient_id
  INNER JOIN isanteplus.arv_status_loockup arv
  ON patstatus.id_status=arv.id
  GROUP BY pat.patient_id;
