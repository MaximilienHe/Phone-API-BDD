DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `call_all_procedures`()
BEGIN
CALL insert_4G_5G();
CALL insert_Carte_SD();
CALL insert_DAS();
CALL insert_SoC();
CALL insert_definition_ratio_ecran();
CALL insert_device_type();
CALL insert_mAh();
CALL insert_main_selfie_camera_number();
CALL insert_marque();
CALL insert_materials();
CALL insert_megapixels();
CALL insert_poids_g();
CALL insert_power_watt();
CALL insert_rafraichissement_ecran();
CALL insert_stockage_RAM();
CALL insert_taille_ecran();
CALL insert_technologie_ecran();
CALL update_announced_date();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`` PROCEDURE `call_all_procedures_device_title`(IN `device_title` VARCHAR(255))
BEGIN
    CALL insert_4G_5G_device_title(device_title);
    CALL insert_Carte_SD_device_title(device_title);
    CALL insert_DAS_device_title(device_title);
    CALL insert_SoC_device_title(device_title);
    CALL insert_definition_ratio_ecran_device_title(device_title);
    CALL insert_device_type_device_title(device_title);
    CALL insert_mAh_device_title(device_title);
    CALL insert_main_selfie_camera_number_device_title(device_title);
    CALL insert_marque_device_title(device_title);
    CALL insert_materials_device_title(device_title);
    CALL insert_megapixels_device_title(device_title);
    CALL insert_poids_g_device_title(device_title);
    CALL insert_power_watt_device_title(device_title);
    CALL insert_rafraichissement_ecran_device_title(device_title);
    CALL insert_stockage_RAM_device_title(device_title);
    CALL insert_taille_ecran_device_title(device_title);
    CALL insert_technologie_ecran_device_title(device_title);
    CALL update_announced_date();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_tests_specs`()
BEGIN
	DELETE FROM specs WHERE specs.category_name = "Tests";
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_useless_devices`()
BEGIN
	DELETE FROM devices WHERE announced_date < '2016-01-01';

	DELETE devices 
FROM devices
JOIN specs 
ON devices.title = specs.device_title
WHERE specs.category_name = 'AddedData' 
AND specs.name = 'New OS' 
AND specs.value = 'Windows';

	DELETE devices FROM devices
    JOIN specs
    ON devices.title = specs.device_title
    WHERE specs.category_name = "AddedData" AND specs.name = "Type" AND specs.value NOT IN ("Smartphone", "Montre", "Tablette");
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_4G_5G`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name,
           CASE
               WHEN s.name = '4G bands' THEN '4G'
               WHEN s.name = '5G bands' THEN '5G'
           END AS name,
           "Oui" AS value
    FROM specs s
    WHERE s.name = '4G bands' OR s.name = '5G bands';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_4G_5G_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name,
           CASE
               WHEN s.name = '4G bands' THEN '4G'
               WHEN s.name = '5G bands' THEN '5G'
           END AS name,
           "Oui" AS value
    FROM specs s
    WHERE (s.name = '4G bands' OR s.name = '5G bands') AND s.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_Carte_SD`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_device_title VARCHAR(255);
  DECLARE cur_value VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT device_title, value FROM specs WHERE name = 'Card Slot';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cur_device_title, cur_value;
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF cur_value = 'No' THEN
      SET cur_value = "No";
    ELSE
      INSERT IGNORE INTO specs (device_title, category_name, name, value)
      VALUES (cur_device_title, 'AddedData', 'Carte SD', 'Oui');
    END IF;
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_Carte_SD_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_device_title VARCHAR(255);
  DECLARE cur_value VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT device_title, value FROM specs WHERE name = 'Card Slot' AND device_title = deviceTitle;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cur_device_title, cur_value;
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF cur_value = 'No' THEN
      SET cur_value = "No";
    ELSE
      INSERT IGNORE INTO specs (device_title, category_name, name, value)
      VALUES (cur_device_title, 'AddedData', 'Carte SD', 'Oui');
    END IF;
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_DAS`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE spec_value VARCHAR(255);
    DECLARE device_title VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT specs.device_title, specs.value FROM specs WHERE specs.name = "SAR EU";
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO device_title, spec_value;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET spec_value = TRIM(spec_value);
        SET spec_value = SUBSTRING(spec_value, 1, LOCATE(' ', spec_value));
        
        
        IF CAST(spec_value AS DECIMAL) IS NOT NULL THEN
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (device_title, "AddedData", "DAS", spec_value);
        END IF;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_DAS_device_title`(IN `deviceTitle` VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE spec_value VARCHAR(255);
    DECLARE device_title VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT specs.device_title, specs.value FROM specs WHERE specs.name = "SAR EU" AND specs.device_title = deviceTitle;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO device_title, spec_value;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET spec_value = TRIM(spec_value);
        SET spec_value = SUBSTRING(spec_value, 1, LOCATE(' ', spec_value));
        
        
        IF CAST(spec_value AS DECIMAL) IS NOT NULL THEN
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (device_title, "AddedData", "DAS", spec_value);
        END IF;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_SoC`()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_device_title VARCHAR(255);
  DECLARE v_value VARCHAR(255);
  DECLARE v_intermediate_value1 VARCHAR(255);
  DECLARE v_intermediate_value2 VARCHAR(255);
  DECLARE v_intermediate_value3 VARCHAR(255);
  DECLARE v_final_value VARCHAR(255);
  DECLARE v_second_brand_position INT;

  DECLARE cur CURSOR FOR 
    SELECT device_title, value
    FROM specs
    WHERE name = 'Chipset';

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_device_title, v_value;

    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Traitement 1
    SET v_intermediate_value1 = 
      CASE
        WHEN LOCATE(
          SUBSTRING_INDEX(v_value, ' ', 1),
          SUBSTRING(
            v_value,
            LENGTH(SUBSTRING_INDEX(v_value, ' ', 1)) + 2
          )
        ) > 0 THEN TRIM(
          SUBSTRING_INDEX(v_value, SUBSTRING_INDEX(v_value, ' ', 1), 1)
        )
        WHEN LOCATE(
          SUBSTRING_INDEX(v_value, ' ', 2),
          SUBSTRING(
            v_value,
            LENGTH(SUBSTRING_INDEX(v_value, ' ', 2)) + 3
          )
        ) > 0 THEN TRIM(
          SUBSTRING_INDEX(v_value, SUBSTRING_INDEX(v_value, ' ', 2), 1)
        )
        ELSE v_value
      END;

    -- Traitement 2
    SET v_intermediate_value2 = 
      CASE
        WHEN LOCATE(',', v_intermediate_value1) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value1, ',', 1))
        WHEN LOCATE('/', v_intermediate_value1) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value1, '/', 1))
        ELSE v_intermediate_value1
      END;

    -- Traitement 3
    SET v_intermediate_value3 = 
      CASE
        WHEN LOCATE(' - ', v_intermediate_value2) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value2, ' -', 1))
        ELSE v_intermediate_value2
      END;

    -- Traitement 4
    SET v_final_value = 
      CASE
        WHEN LOCATE('(', v_intermediate_value3) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value3, '(', 1))
        ELSE v_intermediate_value3
      END;

    -- Traitement final
    SET v_second_brand_position =
      (
        SELECT MIN(LOCATE(brand, v_final_value))
        FROM
        (
          SELECT 'Exynos' AS brand
          UNION ALL
          SELECT 'ATI'
          UNION ALL
          SELECT 'Broadcom'
          UNION ALL
          SELECT 'Spreadtrum'
          UNION ALL
                      SELECT 'Qualcomm'
          UNION ALL
          SELECT 'Google'
          UNION ALL
          SELECT 'Huawei'
          UNION ALL
          SELECT 'Intel'
          UNION ALL
          SELECT 'Kirin'
          UNION ALL
          SELECT 'Mediatek'
          UNION ALL
          SELECT 'Unisoc'
          UNION ALL
          SELECT 'Tiger'
        ) AS brands
        WHERE v_final_value REGEXP CONCAT('[[:<:]]', brand, '[[:>:]]')
        LIMIT 1 OFFSET 1
      );

    IF v_second_brand_position > 0 THEN
      SET v_final_value = SUBSTRING(v_final_value, 1, v_second_brand_position - 1);
    END IF;
	
    IF v_final_value = "" THEN
    	SET v_final_value = "ND";
	END IF;
    
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    VALUES (v_device_title, 'AddedData', 'SoC', v_final_value);

  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_SoC_device_title`(IN `deviceTitle` VARCHAR(255))
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_device_title VARCHAR(255);
  DECLARE v_value VARCHAR(255);
  DECLARE v_intermediate_value1 VARCHAR(255);
  DECLARE v_intermediate_value2 VARCHAR(255);
  DECLARE v_intermediate_value3 VARCHAR(255);
  DECLARE v_final_value VARCHAR(255);
  DECLARE v_second_brand_position INT;

  DECLARE cur CURSOR FOR 
    SELECT device_title, value
    FROM specs
    WHERE name = 'Chipset' AND device_title = deviceTitle;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_device_title, v_value;

    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Traitement 1
    SET v_intermediate_value1 = 
      CASE
        WHEN LOCATE(
          SUBSTRING_INDEX(v_value, ' ', 1),
          SUBSTRING(
            v_value,
            LENGTH(SUBSTRING_INDEX(v_value, ' ', 1)) + 2
          )
        ) > 0 THEN TRIM(
          SUBSTRING_INDEX(v_value, SUBSTRING_INDEX(v_value, ' ', 1), 1)
        )
        WHEN LOCATE(
          SUBSTRING_INDEX(v_value, ' ', 2),
          SUBSTRING(
            v_value,
            LENGTH(SUBSTRING_INDEX(v_value, ' ', 2)) + 3
          )
        ) > 0 THEN TRIM(
          SUBSTRING_INDEX(v_value, SUBSTRING_INDEX(v_value, ' ', 2), 1)
        )
        ELSE v_value
      END;

    -- Traitement 2
    SET v_intermediate_value2 = 
      CASE
        WHEN LOCATE(',', v_intermediate_value1) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value1, ',', 1))
        WHEN LOCATE('/', v_intermediate_value1) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value1, '/', 1))
        ELSE v_intermediate_value1
      END;

    -- Traitement 3
    SET v_intermediate_value3 = 
      CASE
        WHEN LOCATE(' - ', v_intermediate_value2) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value2, ' -', 1))
        ELSE v_intermediate_value2
      END;

    -- Traitement 4
    SET v_final_value = 
      CASE
        WHEN LOCATE('(', v_intermediate_value3) > 0 THEN TRIM(SUBSTRING_INDEX(v_intermediate_value3, '(', 1))
        ELSE v_intermediate_value3
      END;

    -- Traitement final
    SET v_second_brand_position =
      (
        SELECT MIN(LOCATE(brand, v_final_value))
        FROM
        (
          SELECT 'Exynos' AS brand
          UNION ALL
          SELECT 'ATI'
          UNION ALL
          SELECT 'Broadcom'
          UNION ALL
          SELECT 'Spreadtrum'
          UNION ALL
          SELECT 'Qualcomm'
          UNION ALL
          SELECT 'Google'
          UNION ALL
          SELECT 'Huawei'
          UNION ALL
          SELECT 'Intel'
          UNION ALL
          SELECT 'Kirin'
          UNION ALL
          SELECT 'Mediatek'
          UNION ALL
          SELECT 'Unisoc'
          UNION ALL
          SELECT 'Tiger'
        ) AS brands
        WHERE v_final_value REGEXP CONCAT('[[:<:]]', brand, '[[:>:]]')
        LIMIT 1 OFFSET 1
      );

    IF v_second_brand_position > 0 THEN
      SET v_final_value = SUBSTRING(v_final_value, 1, v_second_brand_position - 1);
    END IF;

	 IF v_final_value = "" THEN
    	SET v_final_value = "ND";
	END IF;

    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    VALUES (v_device_title, 'AddedData', 'SoC', v_final_value);

  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_definition_ratio_ecran`()
BEGIN

INSERT IGNORE INTO specs (device_title, category_name, name, value)
SELECT
device_title,
'AddedData',
'Definition Ecran',
CASE
    WHEN TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) = '' OR TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) = ' ' THEN 'ND'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) < 481 THEN 'SD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 481 AND 720 THEN 'HD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 721 AND 1080 THEN 'FullHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 1081 AND 1440 THEN 'QHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 1441 AND 2000 THEN 'QHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) > 2001 THEN 'UHD'
    ELSE TRIM(SUBSTRING_INDEX(specs.value, 'x', 1))
END AS definition
FROM specs
WHERE category_name = 'Display' AND name = 'Resolution';

INSERT IGNORE INTO specs (device_title, category_name, name, value)
SELECT
device_title,
'AddedData',
'Ratio Ecran',
CASE 
    WHEN TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+')) = '' OR TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+')) = ' ' THEN 'ND'
    ELSE TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+'))
END AS ratio
FROM specs
WHERE category_name = 'Display' AND name = 'Resolution';

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_definition_ratio_ecran_device_title`(IN `deviceTitle` VARCHAR(255))
BEGIN
INSERT IGNORE INTO specs (device_title, category_name, name, value)
SELECT
device_title,
"AddedData",
'Definition Ecran',
CASE
    WHEN TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) = '' OR TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) = ' ' THEN 'ND'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) < 480 THEN 'SD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 481 AND 720 THEN 'HD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 721 AND 1080 THEN 'FullHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 1081 AND 1440 THEN 'QHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) BETWEEN 1441 AND 2000 THEN 'QHD'
    WHEN CAST(TRIM(SUBSTRING_INDEX(specs.value, 'x', 1)) AS UNSIGNED) > 2001 THEN 'UHD'
    ELSE TRIM(SUBSTRING_INDEX(specs.value, 'x', 1))
END AS definition
FROM specs
WHERE category_name = 'Display' AND name = 'Resolution' AND device_title = deviceTitle;

INSERT IGNORE INTO specs (device_title, category_name, name, value)
SELECT
device_title,
'AddedData',
'Ratio Ecran',
CASE 
    WHEN TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+')) = '' OR TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+')) = ' ' THEN 'ND'
    ELSE TRIM(REGEXP_SUBSTR(value, '[[:digit:]]+:[[:digit:]]+'))
END AS ratio
FROM specs
WHERE category_name = 'Display' AND name = 'Resolution' AND device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_device_type`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT d.title, 'AddedData' AS category_name,
           'Type' AS name,
           CASE
               WHEN LOWER(d.description) LIKE '%tablet%' THEN 'Tablette'
               WHEN LOWER(d.description) LIKE '%watch%' THEN 'Montre'
               WHEN LOWER(d.description) LIKE '%smartphone%' THEN 'Smartphone'
               WHEN LOWER(d.description) LIKE "phone %" THEN "Téléphone"
               ELSE 'Autre'
           END AS value
    FROM devices d;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_device_type_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT d.title, 'AddedData' AS category_name,
           'Type' AS name,
           CASE
               WHEN LOWER(d.description) LIKE '%tablet%' THEN 'Tablette'
               WHEN LOWER(d.description) LIKE '%watch%' THEN 'Montre'
               WHEN LOWER(d.description) LIKE '%smartphone%' THEN 'Smartphone'
               WHEN LOWER(d.description) LIKE "phone %" THEN "Téléphone"
               ELSE 'Autre'
           END AS value
    FROM devices d WHERE d.title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_mAh`()
BEGIN
    -- Crée une variable pour stocker la valeur extraite de mAh
    DECLARE extracted_mAh_value VARCHAR(255);

    -- Déclare les variables pour contenir les valeurs récupérées du curseur
    DECLARE cur_device_title VARCHAR(255);
    DECLARE cur_mAh_value VARCHAR(255);

    -- Indique si le curseur a atteint la fin
    DECLARE done BOOLEAN DEFAULT FALSE;

    -- Crée un curseur pour parcourir les résultats de la requête
    DECLARE cur CURSOR FOR
        SELECT 
            specs.device_title,
            REGEXP_SUBSTR(specs.value, '\\d{1,4}(,\\d{3})*(\\.\\d+)?') AS mAh_value
        FROM
            specs
        WHERE
            specs.name = "Type" AND specs.category_name = "Battery"
        GROUP BY mAh_value
        ORDER BY mAh_value ASC;

    -- Déclare un gestionnaire pour déterminer si le curseur a atteint la fin
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Ouvre le curseur
    OPEN cur;

    -- Lit les valeurs du curseur dans les variables déclarées
    read_loop: LOOP
        FETCH cur INTO cur_device_title, cur_mAh_value;

        -- Si le curseur atteint la fin, il quitte la boucle
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Supprime les virgules des valeurs extraites de mAh
        SET extracted_mAh_value = REPLACE(cur_mAh_value, ',', '');

        -- Insère les nouvelles lignes de données avec les informations requises
        IF extracted_mAh_value REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (cur_device_title, 'AddedData', 'Taille Batterie (en mAh)', extracted_mAh_value);
        END IF;
    END LOOP;

    -- Ferme le curseur
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_mAh_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    -- Crée une variable pour stocker la valeur extraite de mAh
    DECLARE extracted_mAh_value VARCHAR(255);

    -- Déclare les variables pour contenir les valeurs récupérées du curseur
    DECLARE cur_device_title VARCHAR(255);
    DECLARE cur_mAh_value VARCHAR(255);

    -- Indique si le curseur a atteint la fin
    DECLARE done BOOLEAN DEFAULT FALSE;

    -- Crée un curseur pour parcourir les résultats de la requête
    DECLARE cur CURSOR FOR
        SELECT 
            specs.device_title,
            REGEXP_SUBSTR(specs.value, '\\d{1,4}(,\\d{3})*(\\.\\d+)?') AS mAh_value
        FROM
            specs
        WHERE
            specs.name = "Type" AND specs.category_name = "Battery" AND specs.device_title = deviceTitle
        GROUP BY mAh_value
        ORDER BY mAh_value ASC;

    -- Déclare un gestionnaire pour déterminer si le curseur a atteint la fin
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Ouvre le curseur
    OPEN cur;

    -- Lit les valeurs du curseur dans les variables déclarées
    read_loop: LOOP
        FETCH cur INTO cur_device_title, cur_mAh_value;

        -- Si le curseur atteint la fin, il quitte la boucle
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Supprime les virgules des valeurs extraites de mAh
        SET extracted_mAh_value = REPLACE(cur_mAh_value, ',', '');

        -- Insère les nouvelles lignes de données avec les informations requises
        IF extracted_mAh_value REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (cur_device_title, 'AddedData', 'Taille Batterie (en mAh)', extracted_mAh_value);
        END IF;
    END LOOP;

    -- Ferme le curseur
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_main_selfie_camera_number`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name, 'Nombre de capteurs (camera)' AS name, s.name AS value
    FROM specs s
    WHERE s.category_name = 'Main Camera' AND s.name IN ('Single', 'Dual', 'Triple', 'Quad', 'Five');

	INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name, 'Nombre de capteurs (selfie)' AS name, s.name AS value
    FROM specs s
    WHERE s.category_name = 'Selfie Camera' AND s.name IN ('Single', 'Dual', 'Triple', 'Quad', 'Five');
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_main_selfie_camera_number_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name, 'Nombre de capteurs (camera)' AS name, s.name AS value
    FROM specs s
    WHERE s.category_name = 'Main Camera' AND s.name IN ('Single', 'Dual', 'Triple', 'Quad', 'Five') AND s.device_title = deviceTitle;

	INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, 'AddedData' AS category_name, 'Nombre de capteurs (selfie)' AS name, s.name AS value
    FROM specs s
    WHERE s.category_name = 'Selfie Camera' AND s.name IN ('Single', 'Dual', 'Triple', 'Quad', 'Five') AND s.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_marque`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_device_title VARCHAR(255);
  DECLARE cur_brand_name VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT title, brand_name FROM devices;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cur_device_title, cur_brand_name;
    IF done THEN
      LEAVE read_loop;
    END IF;

    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    VALUES (cur_device_title, 'AddedData', 'Marque', cur_brand_name);
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_marque_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_device_title VARCHAR(255);
  DECLARE cur_brand_name VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT title, brand_name FROM devices WHERE title = deviceTitle;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cur_device_title, cur_brand_name;
    IF done THEN
      LEAVE read_loop;
    END IF;

    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    VALUES (cur_device_title, 'AddedData', 'Marque', cur_brand_name);
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_materials`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_device_title, v_back_material VARCHAR(255);
  DECLARE cur CURSOR FOR
    SELECT
	  device_title AS v_device_title,
      IF(INSTR(specs.value, ' back') > 0, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(specs.value, ' back', 1), ' ', -1)), 'ND') AS v_back_material
    FROM
      specs
    WHERE
      specs.name = 'Build';

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_device_title, v_back_material;

    IF done THEN
      LEAVE read_loop;
    END IF;
    
      INSERT IGNORE INTO specs(device_title, category_name, name, value)
      VALUES (v_device_title, 'AddedData', 'Matériau Arrière', v_back_material);
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_materials_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_device_title, v_back_material VARCHAR(255);
  DECLARE cur CURSOR FOR
    SELECT
	  device_title AS v_device_title,
      IF(INSTR(specs.value, ' back') > 0, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(specs.value, ' back', 1), ' ', -1)), 'ND') AS v_back_material
    FROM
      specs
    WHERE
      specs.name = 'Build' AND specs.device_title = deviceTitle;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_device_title, v_back_material;

    IF done THEN
      LEAVE read_loop;
    END IF;
    
      INSERT IGNORE INTO specs(device_title, category_name, name, value)
      VALUES (v_device_title, 'AddedData', 'Matériau Arrière', v_back_material);
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_megapixels`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, "AddedData", "Megapixels", TRIM(SUBSTRING_INDEX(s.value, ' MP', 1))
    FROM specs s
    WHERE s.category_name = "Main Camera"
        AND s.name NOT IN ("Selfie", "", " ", " ", "Video", "Features");
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_megapixels_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, "AddedData", "Megapixels", TRIM(SUBSTRING_INDEX(s.value, ' MP', 1))
    FROM specs s
    WHERE s.category_name = "Main Camera"
        AND s.name NOT IN ("Selfie", "", " ", " ", "Video", "Features") AND s.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_new_os`()
BEGIN
  INSERT IGNORE INTO specs (device_title, category_name, name, value)
  SELECT
    device_title,
    'AddedData' AS category_name,
    'New OS' AS name,
    CASE
      WHEN value LIKE '%Wear OS%' THEN 'Wear OS'
      WHEN value LIKE '%Android Wear OS%' THEN 'Wear OS'
      WHEN value LIKE '%Android%' THEN 'Android'
      WHEN value LIKE '% iOS%' THEN 'iOS'
      WHEN value LIKE '%HarmonyOS%' THEN 'HarmonyOS'
      WHEN value LIKE '%Windows%' THEN 'Windows'
      WHEN value LIKE '%iPadOS%' THEN 'iPadOS'
      WHEN value LIKE '%ChromeOS%' THEN 'ChromeOS'
      WHEN value LIKE '%watchOS%' THEN 'WatchOS'
      ELSE 'OS Propriétaire'
    END AS new_value
  FROM specs
  WHERE name = 'OS' AND category_name = 'Platform';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_new_os_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
  INSERT IGNORE INTO specs (device_title, category_name, name, value)
  SELECT
    device_title,
    'AddedData' AS category_name,
    'New OS' AS name,
    CASE
      WHEN value LIKE '%Wear OS%' THEN 'Wear OS'
      WHEN value LIKE '%Android Wear OS%' THEN 'Wear OS'
      WHEN value LIKE '%Android%' THEN 'Android'
      WHEN value LIKE '% iOS%' THEN 'iOS'
      WHEN value LIKE '%HarmonyOS%' THEN 'HarmonyOS'
      WHEN value LIKE '%Windows%' THEN 'Windows'
      WHEN value LIKE '%iPadOS%' THEN 'iPadOS'
      WHEN value LIKE '%ChromeOS%' THEN 'ChromeOS'
      WHEN value LIKE '%watchOS%' THEN 'WatchOS'
      ELSE 'OS Propriétaire'
    END AS new_value
  FROM specs
  WHERE name = 'OS' AND category_name = 'Platform' AND device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_poids_g`()
BEGIN
	INSERT IGNORE INTO specs (device_title, category_name, name, value)
	SELECT device_title, "AddedData", "Poids (en g)", v_value_grams
	FROM (
	    SELECT device_title, 
	           CEIL(REGEXP_SUBSTR(value, '\\d+(\\.\\d+)?')) AS v_value_grams 
	    FROM specs
	    WHERE name = 'Weight'
	) AS subquery
	WHERE v_value_grams REGEXP '^[0-9]+(\\.[0-9]+)?$';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_poids_g_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
	INSERT IGNORE INTO specs (device_title, category_name, name, value)
	SELECT device_title, "AddedData", "Poids (en g)", v_value_grams
	FROM (
	    SELECT device_title, 
	           CEIL(REGEXP_SUBSTR(value, '\\d+(\\.\\d+)?')) AS v_value_grams 
	    FROM specs
	    WHERE name = 'Weight'
	) AS subquery
	WHERE v_value_grams REGEXP '^[0-9]+(\\.[0-9]+)?$' AND device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_power_watt`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT t.device_title, 'AddedData', 'Puissance de charge (en W)', t.Power
    FROM (
        SELECT s.device_title,
            CASE WHEN s.value REGEXP '[0-9]+W? wired'
                THEN SUBSTRING_INDEX(SUBSTRING_INDEX(s.value, 'W wired', 1), ' ', -1)
                ELSE "" 
            END AS Power
        FROM specs AS s
        WHERE s.category_name = 'Battery' AND s.name = 'Charging'
    ) AS t
    WHERE t.Power REGEXP '^[0-9]+$';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_power_watt_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT t.device_title, 'AddedData', 'Puissance de charge (en W)', t.Power
    FROM (
        SELECT s.device_title,
            CASE WHEN s.value REGEXP '[0-9]+W? wired'
                THEN SUBSTRING_INDEX(SUBSTRING_INDEX(s.value, 'W wired', 1), ' ', -1)
                ELSE "" 
            END AS Power
        FROM specs AS s
        WHERE s.category_name = 'Battery' AND s.name = 'Charging'
    ) AS t
    WHERE t.Power REGEXP '^[0-9]+$' AND t.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_rafraichissement_ecran`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE hz_value VARCHAR(255);
    DECLARE device_title VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT specs.device_title, LEFT(REGEXP_SUBSTR(specs.value, '[0-9]+Hz'), LENGTH(REGEXP_SUBSTR(specs.value, '[0-9]+Hz')) - 2) AS hz_value
        FROM specs
        WHERE name = 'Type' AND category_name = 'Display';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO device_title, hz_value;
        IF done THEN
            LEAVE read_loop;
        END IF;
		
        IF hz_value = "" THEN
        	SET hz_value = "60";
        END IF;
        
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (device_title, 'AddedData', 'Rafraichissement Ecran (en Hz)', hz_value);
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_rafraichissement_ecran_device_title`(IN `deviceTitle` VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE hz_value VARCHAR(255);
    DECLARE device_title VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT specs.device_title, LEFT(REGEXP_SUBSTR(specs.value, '[0-9]+Hz'), LENGTH(REGEXP_SUBSTR(specs.value, '[0-9]+Hz')) - 2) AS hz_value
        FROM specs
        WHERE name = 'Type' AND category_name = 'Display' AND specs.device_title = deviceTitle;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO device_title, hz_value;
        IF done THEN
            LEAVE read_loop;
        END IF;
		
        IF hz_value = "" THEN
        	SET hz_value = "60";
        END IF;
        
        INSERT IGNORE INTO specs (device_title, category_name, name, value)
        VALUES (device_title, 'AddedData', 'Rafraichissement Ecran (en Hz)', hz_value);
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_stockage_RAM`()
BEGIN
DECLARE finished INT DEFAULT 0;
DECLARE cur_device_title VARCHAR(255);
DECLARE cur_value TEXT;
DECLARE cur_combination VARCHAR(255);
DECLARE cur_ram VARCHAR(255);
DECLARE cur_storage VARCHAR(255);

-- Declare cursor
DECLARE cur CURSOR FOR
SELECT device_title, value
FROM specs
WHERE category_name = 'Memory' AND name = 'Internal';

-- Declare exit handler
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

-- Open cursor
OPEN cur;

read_loop: LOOP
FETCH cur INTO cur_device_title, cur_value;

IF finished = 1 THEN
  LEAVE read_loop;
END IF;

-- Split the combinations
WHILE LOCATE(',', cur_value) > 0 DO
  SET cur_combination = TRIM(SUBSTRING_INDEX(cur_value, ',', 1));
  SET cur_value = TRIM(SUBSTRING(cur_value, LOCATE(',', cur_value) + 1));

  SET cur_ram = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_combination, '\\d+(?=\\s*(GB|MB)\\s*RAM)'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_combination, '(GB|MB)\\s*RAM'));
  SET cur_storage = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_combination, '\\d+(?=\\s*(GB|MB|TB)(?!\\s*RAM))'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_combination, '(GB|MB|TB)(?!\\s*RAM)'));
  IF LENGTH(cur_storage) = 0 THEN
    SET cur_storage = '<1';
  END IF;

IF cur_ram = "" OR cur_ram = " " OR cur_ram IS NULL THEN
	SET cur_ram = "ND";
END IF;

IF cur_storage = "" OR cur_storage = " " OR cur_storage IS NULL THEN
	SET cur_storage = "ND";
END IF;

  INSERT IGNORE INTO `specs` (`device_title`, `category_name`, `name`, `value`)
  VALUES (cur_device_title, 'AddedData', 'RAM', cur_ram),
         (cur_device_title, 'AddedData', 'Stockage', cur_storage);
END WHILE;

-- Insert the last combination
SET cur_ram = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_value, '\\d+(?=\\s*(GB|MB)\\s*RAM)'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_value, '(GB|MB)\\s*RAM'));
SET cur_storage = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_value, '\\d+(?=\\s*(GB|MB|TB)(?!\\s*RAM))'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_value, '(GB|MB|TB)(?!\\s*RAM)'));
IF LENGTH(cur_storage) = 0 THEN
  SET cur_storage = '<1';
END IF;

IF cur_ram = "" OR cur_ram = " " OR cur_ram IS NULL THEN
	SET cur_ram = "ND";
END IF;

IF cur_storage = "" OR cur_storage = " " OR cur_storage IS NULL THEN
	SET cur_storage = "ND";
END IF;

INSERT IGNORE INTO `specs` (`device_title`, `category_name`, `name`, `value`)
VALUES (cur_device_title, 'AddedData', 'RAM', cur_ram),
       (cur_device_title, 'AddedData', 'Stockage', cur_storage);
END LOOP read_loop;

-- Close cursor
CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_stockage_RAM_device_title`(IN `deviceTitle` VARCHAR(255))
BEGIN
DECLARE finished INT DEFAULT 0;
DECLARE cur_device_title VARCHAR(255);
DECLARE cur_value TEXT;
DECLARE cur_combination VARCHAR(255);
DECLARE cur_ram VARCHAR(255);
DECLARE cur_storage VARCHAR(255);

-- Declare cursor
DECLARE cur CURSOR FOR
SELECT device_title, value
FROM specs
WHERE category_name = 'Memory' AND name = 'Internal' AND device_title = deviceTitle;

-- Declare exit handler
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

-- Open cursor
OPEN cur;

read_loop: LOOP
FETCH cur INTO cur_device_title, cur_value;

IF finished = 1 THEN
  LEAVE read_loop;
END IF;

-- Split the combinations
WHILE LOCATE(',', cur_value) > 0 DO
  SET cur_combination = TRIM(SUBSTRING_INDEX(cur_value, ',', 1));
  SET cur_value = TRIM(SUBSTRING(cur_value, LOCATE(',', cur_value) + 1));

  SET cur_ram = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_combination, '\\d+(?=\\s*(GB|MB)\\s*RAM)'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_combination, '(GB|MB)\\s*RAM'));
  SET cur_storage = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_combination, '\\d+(?=\\s*(GB|MB|TB)(?!\\s*RAM))'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_combination, '(GB|MB|TB)(?!\\s*RAM)'));
  IF LENGTH(cur_storage) = 0 THEN
    SET cur_storage = '<1';
  END IF;

IF cur_ram = "" OR cur_ram = " " OR cur_ram IS NULL THEN
	SET cur_ram = "ND";
END IF;

IF cur_storage = "" OR cur_storage = " " OR cur_storage IS NULL THEN
	SET cur_storage = "ND";
END IF;

  INSERT IGNORE INTO `specs` (`device_title`, `category_name`, `name`, `value`)
  VALUES (cur_device_title, 'AddedData', 'RAM', cur_ram),
         (cur_device_title, 'AddedData', 'Stockage', cur_storage);
END WHILE;

-- Insert the last combination
SET cur_ram = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_value, '\\d+(?=\\s*(GB|MB)\\s*RAM)'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_value, '(GB|MB)\\s*RAM'));
SET cur_storage = CONCAT(REGEXP_REPLACE(REGEXP_SUBSTR(cur_value, '\\d+(?=\\s*(GB|MB|TB)(?!\\s*RAM))'), '[^0-9.]', ''), ' ', REGEXP_SUBSTR(cur_value, '(GB|MB|TB)(?!\\s*RAM)'));
IF LENGTH(cur_storage) = 0 THEN
  SET cur_storage = '<1';
END IF;

IF cur_ram = "" OR cur_ram = " " OR cur_ram IS NULL THEN
	SET cur_ram = "ND";
END IF;

IF cur_storage = "" OR cur_storage = " " OR cur_storage IS NULL THEN
	SET cur_storage = "ND";
END IF;

INSERT IGNORE INTO `specs` (`device_title`, `category_name`, `name`, `value`)
VALUES (cur_device_title, 'AddedData', 'RAM', cur_ram),
       (cur_device_title, 'AddedData', 'Stockage', cur_storage);
END LOOP read_loop;

-- Close cursor
CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_taille_ecran`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT 
        s.device_title,
        'AddedData',
        'Taille Ecran (en pouces)',
        CASE
            WHEN TRIM(SUBSTRING_INDEX(s.value, ' ', 1)) REGEXP '^[0-9]+[.][0-9]+$' THEN TRIM(SUBSTRING_INDEX(s.value, ' ', 1))
            ELSE 'Non Défini'
        END AS inches
    FROM specs s
    WHERE 
        s.category_name = 'Display'
        AND s.name = 'Size';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_taille_ecran_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT 
        s.device_title,
        'AddedData',
        'Taille Ecran (en pouces)',
        CASE
            WHEN TRIM(SUBSTRING_INDEX(s.value, ' ', 1)) REGEXP '^[0-9]+[.][0-9]+$' THEN TRIM(SUBSTRING_INDEX(s.value, ' ', 1))
            ELSE 'Non Défini'
        END AS inches
    FROM specs s
    WHERE 
        s.category_name = 'Display'
        AND s.name = 'Size'
        AND s.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_technologie_ecran`()
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, "AddedData", 'Technologie Ecran',
    CASE 
        WHEN s.value LIKE '%OLED%' OR s.value LIKE '%AMOLED%' THEN 'OLED'
        WHEN s.value LIKE '%LCD%' OR s.value LIKE '%IPS%' OR s.value LIKE '%PLS%' OR s.value LIKE '%TFT%' OR s.value LIKE '%TN%' THEN 'LCD'
        ELSE 'Autre'
    END
    FROM specs s
    WHERE s.category_name = 'Display' AND s.name = 'Type';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_technologie_ecran_device_title`(IN deviceTitle VARCHAR(255))
BEGIN
    INSERT IGNORE INTO specs (device_title, category_name, name, value)
    SELECT s.device_title, "AddedData", 'Technologie Ecran',
    CASE 
        WHEN s.value LIKE '%OLED%' OR s.value LIKE '%AMOLED%' THEN 'OLED'
        WHEN s.value LIKE '%LCD%' OR s.value LIKE '%IPS%' OR s.value LIKE '%PLS%' OR s.value LIKE '%TFT%' OR s.value LIKE '%TN%' THEN 'LCD'
        ELSE 'Autre'
    END
    FROM specs s
    WHERE s.category_name = 'Display' AND s.name = 'Type' AND s.device_title = deviceTitle;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_announced_date`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_id INT;
  DECLARE cur_title VARCHAR(255);
  DECLARE cur_description TEXT;
  DECLARE cur_announced_date VARCHAR(255);
  DECLARE spec_value VARCHAR(255);
  DECLARE year, month, day INT;
  DECLARE month_day VARCHAR(255);
  DECLARE cur CURSOR FOR SELECT id, title, description FROM devices;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cur_id, cur_title, cur_description;
    IF done THEN
      LEAVE read_loop;
    END IF;

    BEGIN
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET spec_value = NULL;
      SELECT value INTO spec_value FROM specs WHERE specs.device_title = cur_title AND specs.name = "Announced" AND specs.category_name = "Launch" LIMIT 1;
    END;

	  SET spec_value = SUBSTRING_INDEX(spec_value, 'Released', 1);
    IF spec_value IS NOT NULL THEN
      -- Case 1: Year, Month, Day
      IF spec_value REGEXP '^[0-9]{4}, [A-Z][a-z]+ [0-9]{1,2}' THEN
        SET year = SUBSTRING_INDEX(spec_value, ', ', 1);
        SET month_day = TRIM(SUBSTRING_INDEX(spec_value, ', ', -1));
        SET month = MonthNameToNumber(TRIM(SUBSTRING_INDEX(month_day, ' ', 1)));
        SET day = TRIM(SUBSTRING_INDEX(month_day, ' ', -1));
        SET cur_announced_date = CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'));

      -- Case 2: Year, Month
      ELSEIF spec_value REGEXP '^[0-9]{4}, [A-Z][a-z]+' THEN
        SET year = SUBSTRING_INDEX(spec_value, ', ', 1);
        SET month = MonthNameToNumber(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(spec_value, ', ', -1), '.', 1)));
        SET cur_announced_date = CONCAT(year, '-', LPAD(month, 2, '0'), '-01');

      -- Case 3: Year, Quarter
      ELSEIF spec_value REGEXP '^[0-9]{4}, Q[1-4]' THEN
        SET year = SUBSTRING_INDEX(spec_value, ', ', 1);
        SET month = (CAST(SUBSTRING(spec_value, 8, 1) AS UNSIGNED) - 1) * 3 + 1;
        SET cur_announced_date = CONCAT(year, '-', LPAD(month, 2, '0'), '-01');

      -- Case 4: Year only
      ELSEIF spec_value REGEXP '^[0-9]{4}$' THEN
        SET year = spec_value;
        SET cur_announced_date = CONCAT(year, '-01-01');
      END IF;
      
    ELSE
      -- Old method
      SET @regex = '(Announced )((?:Q[1-4]|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4}|[0-9]{4})';
      SET @start_pos = LOCATE('Announced', cur_description) + 10;
      SET @date_format = TRIM(SUBSTRING(cur_description, @start_pos));

      IF LOCATE('Q', @date_format) = 1 THEN
        SET @quarter = CAST(SUBSTRING(@date_format, 2, 1) AS UNSIGNED);
        SET @year = CAST(SUBSTRING(@date_format, 4, 4) AS UNSIGNED);
        SET @month = 3 * (@quarter - 1) + 1;
        SET cur_announced_date = CONCAT(STR_TO_DATE(CONCAT('01-', @month, '-', @year), '%d-%m-%Y'), ' | ', @date_format);
      ELSEIF LEFT(@date_format, 4) REGEXP '^[0-9]{4}' THEN
        SET cur_announced_date = CONCAT(STR_TO_DATE(CONCAT('01-01-', LEFT(@date_format, 4)), '%d-%m-%Y'), ' | ', @date_format);
      ELSE
        SET cur_announced_date = CONCAT(STR_TO_DATE(CONCAT('01-', MonthNameToNumber(SUBSTRING(@date_format, 1, 3)), '-', SUBSTRING(@date_format, 5, 4)), '%d-%m-%Y'), ' | ', @date_format);
      END IF;
    END IF;

    UPDATE devices SET announced_date = cur_announced_date WHERE id = cur_id;
  END LOOP;

  CLOSE cur;
END$$
DELIMITER ;
