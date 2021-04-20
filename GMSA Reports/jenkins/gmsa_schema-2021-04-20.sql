-- --------------------------------------------------------
-- Host:                         192.168.1.231
-- Server version:               5.7.27 - MySQL Community Server (GPL)
-- Server OS:                    linux-glibc2.12
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table gmsa_reports.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0',
  `gc_account_id` int(11) DEFAULT '0',
  UNIQUE KEY `account` (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table gmsa_reports.gm_country_code_mapping: ~13 rows (approximately)
DELETE FROM `gm_country_code_mapping`;
/*!40000 ALTER TABLE `gm_country_code_mapping` DISABLE KEYS */;
INSERT INTO `gm_country_code_mapping` (`account`, `country_Code`, `gc_account_id`) VALUES
	('Airlinq', 1, 1),
	('ESIM', 2, 2),
	('Brazil', 100259213, 3),
	('Brazil_boot', 100266613, 4),
	('Brazil_phld', 100266713, 5),
	('Argentina', 100428114, 6),
	('Chile', 100432114, 7),
	('Brazil-production', 8, 8),
	('Columbia', 100432214, 9),
	('Ecuador', 100432014, 10),
	('Paraguay', 100246413, 11),
	('Peru', 100432314, 12),
	('Uruguay', 100246313, 13);
/*!40000 ALTER TABLE `gm_country_code_mapping` ENABLE KEYS */;

-- Dumping structure for procedure gmsa_reports.gm_get_supplier_account_id
DROP PROCEDURE IF EXISTS `gm_get_supplier_account_id`;
DELIMITER //
CREATE PROCEDURE `gm_get_supplier_account_id`(
	IN `in_account_id` INT
)
    COMMENT 'This procedure is used to return the supplier account id '
BEGIN
 /*
  --------------------------------------------------------------------------------------------------------------------------------------
  Description :  This procedure is used to return the supplier account id
  Created On  :  4 Nov 2020
  Created By  :  Saurabh kumar
  --------------------------------------------------------------------------------------------------------------------------------------
  Inputs :    IN `in_account_id` int(16), 
  Output  :   This procedure is used to return the supplier account id
  ---------------------------------------------------------------------------------------------------------------------------------------
*/
/*  SELECT COALESCE(country_Code,'0') AS country_ode FROM gm_country_code_mapping 
    WHERE account = (SELECT ACCOUNT_COUNTRIE FROM report_metadata WHERE ENT_ACCOUNTID = in_account_id LIMIT 1);
*/
/*	SELECT CASE WHEN in_account_id = 7 THEN 8
				WHEN in_account_id = 10 THEN 9
                WHEN in_account_id = 11 THEN 11
			ELSE in_account_id END AS country_ode ;
	*/		
			SELECT COALESCE(country_Code,'0') AS country_ode FROM gm_country_code_mapping 
			WHERE gm_country_code_mapping.gc_account_id=in_account_id;
			
			
			
			
			
			
			
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
