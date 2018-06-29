-- Dasboar report
DROP PROCEDURE IF EXISTS dashboard_event;
DELIMITER $$
CREATE PROCEDURE dashboard_event(IN org_unit VARCHAR(11))
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INTEGER DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Q7pD6QSyVwF';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "zqbLP5kJWAf",
          "orgUnit", org_unit,
          "eventDate", DATE_FORMAT(distinct_entity.discontinuation_date, date_format),
          "status", "COMPLETED",
          "storedBy", "admin",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "dataValues", JSON_ARRAY(
            JSON_OBJECT(
              "dataElement", "ziEdMTsddYv", -- Sous TAR- Régulier (A)
              "value", distinct_entity.onHaart_regular_adult
            ),
            JSON_OBJECT(
              "dataElement", "n0wrx5yvjhz", -- Sous TAR- Régulier (E)
              "value", distinct_entity.onHaart_regular_child
            ),
            JSON_OBJECT(
              "dataElement", "QFjqA8SSmDG", -- Sous TAR- Rendez-vous ratés (A)
              "value", distinct_entity.onHaart_missingAppointment_adult
            ),
            JSON_OBJECT(
              "dataElement", "tUWg18xVIJw", -- Sous TAR- Rendez-vous ratés (E)
              "value", distinct_entity.onHaart_missingAppointment_child
            ),
            JSON_OBJECT(
              "dataElement", "YxfC3gJjEKL", -- Sous TAR- Perdus de vue (A)
              "value", distinct_entity.onHaart_lostToFollowUp_adult
            ),
            JSON_OBJECT(
              "dataElement", "NE4xBXQnJFL", -- Sous TAR- Perdus de vue (E)
              "value", distinct_entity.onHaart_lostToFollowUp_child
            ),
            JSON_OBJECT(
              "dataElement", "Dp95xn5tNRJ", -- Sous TAR- Arrêtés (A)
              "value", distinct_entity.onHaart_stopped_adult
            ),
            JSON_OBJECT(
              "dataElement", "fDkWpV6cChZ", -- Sous TAR- Arrêtés (E)
              "value", distinct_entity.onHaart_stopped_child
            ),
            JSON_OBJECT(
              "dataElement", "Dp95xn5tNRJ", -- Sous TAR- Arrêtés (A)
              "value", distinct_entity.onHaart_stopped_adult
            ),
            JSON_OBJECT(
              "dataElement", "fDkWpV6cChZ", -- Sous TAR- Arrêtés (E)
              "value", distinct_entity.onHaart_stopped_child
            ),
          )
        ) AS tracked_entity
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
  INTO OUTFILE '/var/lib/mysql-files/dashboard_event.json';

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
