-- Dasboar report
DROP PROCEDURE IF EXISTS dashboard_tracked_entity;
DELIMITER $$
CREATE PROCEDURE dashboard_tracked_entity(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Q7pD6QSyVwF';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  CALL patient_insert_idgen(program);

  SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT JSON_OBJECT (
          "trackedEntity", "vZqorMSOYSr",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "orgUnit", org_unit,
          "attributes", JSON_ARRAY(
            JSON_OBJECT(
              "attribute", "bmVKAcfjORB", -- LocationId
              "value", distinct_entity.location_id
              )
            ),
          "enrollments", JSON_ARRAY(
            JSON_OBJECT(
              "orgUnit", org_unit,
              "program", program,
              "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
              "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
              )
            )
          ) AS track_entity
        FROM (SELECT p.location_id,
            COUNT(
            DISTINCT CASE WHEN ( -- Réguliers (actifs sous ARV)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 6 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_regular_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Réguliers (actifs sous ARV)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 6 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_regular_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Rendez-vous ratés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 8 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_missingAppointment_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Rendez-vous ratés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 8 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_missingAppointment_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 9 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_lostToFollowUp_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 9 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_lostToFollowUp_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Arrêtés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 2 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_stopped_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Arrêtés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 2 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_stopped_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 3 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_transfert_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 3 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_transfert_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 1 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_deathOnART_adult,
             COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE id_status = 1 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_deathOnART_child,
            COUNT(
            DISTINCT CASE WHEN (
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART WHERE AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_total_adult,
            COUNT(
            DISTINCT CASE WHEN (
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_HAART
                        WHERE AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_total_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Récents Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 7 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_recentOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Récents Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 7 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_recentOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Actifs en Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 11 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_actifOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Actifs en Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 11 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_actifOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 9 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_lostToFollowUpOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 9 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_lostToFollowUpOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 3 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_transferredOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 3 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_transferredOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 1 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_deathOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 1 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_deathOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN (
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_total_adult,
            COUNT(
            DISTINCT CASE WHEN (
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_total_child,
            COUNT(p.patient_id) AS grandTotal
        FROM patient p
        GROUP BY p.location_id
        ) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances)
  INTO OUTFILE '/var/lib/mysql-files/dashboard_tracked_entity.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
