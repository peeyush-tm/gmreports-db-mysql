-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gm_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE  PROCEDURE `gm_voice_report`(IN `in_start_date` varchar(50)
, IN `in_end_date` varchar(50)

















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_voice_report_new'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns voice data  on the basis of 
  -- the served imsi and served flow id and ANMRECDAT
 
  -- Description: Procedure is use to generate the voice report according to the creation date  
  -- **********************************************************************
	
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- generate a table to fetch the data from the incomplete voice table  	
	DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
	CREATE TEMPORARY TABLE temp_voice_complete
	SELECT 
	report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_incompleted.CALLINGNUMBER,
	cdr_voice_incompleted.CALLEDNUMBER,
	cdr_voice_incompleted.CALLDURATION,
	cdr_voice_incompleted.ANMRECDAT ,
	cdr_voice_incompleted.EVENTSRECD,
	cdr_voice_incompleted.MCC,
	cdr_voice_incompleted.MNC ,
	cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
	cdr_voice_incompleted.MOCALL,
	cdr_voice_incompleted.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_incompleted 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
	or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	    
	-- generate a table to fetch the data from the complete voice table 
	DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
	CREATE TEMPORARY TABLE temp_voice_incomplete
	SELECT report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_completed.CALLINGNUMBER,
	cdr_voice_completed.CALLEDNUMBER,
	cdr_voice_completed.CALLDURATION,
	cdr_voice_completed.ANMRECDAT ,
	cdr_voice_completed.EVENTSRECD ,
	cdr_voice_completed.MCC,
	cdr_voice_completed.MNC ,
	cdr_voice_completed.CAUSEINDCAUSEVALUE,
	cdr_voice_completed.MOCALL,
	cdr_voice_completed.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_completed 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
		or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	

	CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

	-- preparing the data from merging the both table complete and incomplete	
	DROP  TEMPORARY TABLE if EXISTS temp_voice;
	CREATE TEMPORARY TABLE temp_voice
	SELECT * FROM temp_voice_complete                         
	UNION ALL 
	SELECT * FROM 	temp_voice_incomplete;

	-- final result report of the voice data 
	SELECT 
	temp_voice.ICCID  AS 'ICCID',
	temp_voice.IMSI AS 'IMSI',
	temp_voice.MSISDN AS 'MSISDN',
	-- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
	COUNTRY_CODE AS 'ACCOUNT ID',
	-- MNO_ACCOUNTID AS 'ACCOUNT ID',
	-- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
	'5' AS 'BILLING CYCLE DATE',
	CALLINGNUMBER AS 'CALLING PARTY NUMBER',
	CALLEDNUMBER AS 'CALLED',
	CALLDURATION AS 'ANSWER DURATION',
	case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS INT)*60 end as 'ANSWER DURATION ROUNDED',
	ANMRECDAT AS 'ORIGINATION DATE',
	concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
	-- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
	case when MOCALL=0 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case 
					 when LASTERBCSM = 13 
						  then 'Busy'   
					 when LASTERBCSM = 14 
						  then 'Not answered'   
					 when LASTERBCSM = 18 
						  then 'Abandoned i.e. Caller cut the call'
					 when LASTERBCSM = 13 
						  then 'Busy'      
			end 
	     when MOCALL=1 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case  when LASTERBCSM = 4
						  then 'Route selection failure' 
					when LASTERBCSM = 5 
						  then 'Busy'
					when LASTERBCSM = 6
						  then 'Not answered'
					when LASTERBCSM = 10
						  then 'Abandoned i.e. Caller cut the call'
			end
	end AS 'CALL TERMINATION REASON',
	'Circuit Switched' as 'CALL TYPE',
	case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
	temp_wholesale_plan_history.plan AS PLAN,
	cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
	FROM temp_voice
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
	and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
	left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
	and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC end = cdr_voice_tadig_codes.TC_MNC ;
-- 	GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';
	




END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
