-- --------------------------------------------------------
-- Host:                         192.168.1.231
-- Server version:               5.7.27 - MySQL Community Server (GPL)
-- Server OS:                    linux-glibc2.12
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure stc_report.gm_mobile_network_registration_failure_daily_report
DROP PROCEDURE IF EXISTS `gm_mobile_network_registration_failure_daily_report`;
DELIMITER //
CREATE PROCEDURE `gm_mobile_network_registration_failure_daily_report`(
  IN `in_start_date` INT,
  IN `in_end_date` INT,
  IN `in_account_id` INT
)
BEGIN

  SELECT 
  report_metadata.IMSI AS IMSI,
  report_metadata.ICCID AS ICCID,
  network_failure.create_date,
  network_failure.VALUE AS `Network Error TYPE`,
  network_failure.service AS `Error Source (host)`,
  network_registration_failure_code.code AS `Error Code`
   FROM network_registration_failure_data network_failure
  INNER JOIN report_metadata ON report_metadata.IMSI=network_failure.imsi
  LEFT JOIN network_registration_failure_code ON network_registration_failure_code.value=network_failure.VALUE
  WHERE (network_failure.create_date BETWEEN in_start_date AND in_end_date)
  AND report_metadata.MNO_ACCOUNTID=in_account_id;



END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
