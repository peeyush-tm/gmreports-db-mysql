-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE DEFINER=`developer`@`%` PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50)
,
	IN `in_end_date` varchar(50)
)
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Description: Procedure is use to generate the voicce report according to the creation date  
  -- **********************************************************************
	SELECT 
    report_metadata.ICCID,
	report_metadata.MSISDN,
	report_metadata.IMSI,
	report_metadata.RATE_PLAN_NAME,
    cdr_voice_details.START_TIME,
	cdr_voice_details.CALLINGNUMBER,
	cdr_voice_details.CALLEDNUMBER,
	cdr_voice_details.CALLDURATION,
	cdr_voice_details.ANMRECDAT
	FROM (report_metadata
	INNER JOIN cdr_voice_rw_completed_calls_archive
    INNER JOIN cdr_voice_rw_incompleted_calls_archive
	ON report_metadata.ID = cdr_voice_rw_completed_calls_archive.ID
    and report_metadata.ID = cdr_voice_rw_incompleted_calls_archive.ID)
	WHERE IAMRECDAT >= to_date(in_start_date, 'YYYY-MM-DD HH24:MI:SS')
    AND  IAMRECDAT <= to_date(in_start_date, 'YYYY-MM-DD HH24:MI:SS'); 

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
