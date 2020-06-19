
-- Dumping structure for procedure gm_reports.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE PROCEDURE `gm_data_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)
, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_data_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns cdr data on the basis of 
  -- the served imsi and STOP_TIME
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

	-- Declaration of the variables 
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- prepare the data report with the multiple tables joins 
	
	
	SELECT 
	report_metadata.ICCID AS ICCID,
	report_metadata.MSISDN AS MSISDN,
	report_metadata.IMSI AS IMSI,
-- 	report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
	-- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	'5' AS BILLING_CYCLE_DATE,
-- 	report_metadata.WHOLE_SALE_NAME AS PLAN,
	wholesale_plan_history.NEW_VALUE AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   cdr_data_details_vw.UPLINK_BYTES AS TRANSMIT_BYTE,
   cdr_data_details_vw.DOWNLINK_BYTES AS RECEIVE_BYTES,
	cdr_data_details_vw.TOTAL_BYTES AS DATAUSAGE,
	-- sum(cdr_data_details_vw.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details_vw.APN_ID AS APN,
	cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
--   cdr_data_details_vw.SERVED_IMSI AS OPERATOR_NETWORK,
   concat(cdr_data_details_vw.ULI_MCC,',',cdr_data_details_vw.ULI_MNC) AS OPERATOR_NETWORK,
	cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
	cdr_data_details_vw.DURATION_SEC AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
	cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
  	cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then 'UTRAN - 3G' when cdr_data_details_vw.RAT_TYPE=6 then 'EUTRAN - 4G' when cdr_data_details_vw.RAT_TYPE=2 then 'GERAN - 2G' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
	from	((report_metadata
	INNER JOIN cdr_data_details_vw
 	ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join wholesale_plan_history on wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_data_details_vw.RECORD_OPENING_TIME between  wholesale_plan_history.CREATE_DATE and wholesale_plan_history.CREATE_DATE)))
	   WHERE 
		  date(cdr_data_details_vw.STOP_TIME) = date(start_date)
	   and report_metadata.MNO_ACCOUNTID=in_account_id
	group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID;
	/*
	FROM ((report_metadata
	INNER JOIN cdr_data_details
	ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI)
	INNER JOIN pgw_svc_data
	ON pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account)
	WHERE date(cdr_data_details.STOP_TIME) = date(start_date)
	group by cdr_data_details.SERVED_IMSI, pgw_svc_data.CHARGING_ID;
*/

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE PROCEDURE `gm_sms_undelivered_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_undelivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the undelivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms undelivered report genarted 
  -- **********************************************************************

	 -- Declaring the variables 
 	 DECLARE date_duration VARCHAR(50);
 	 DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
   

	 -- preparing the billing dates 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	 -- select concat(@temp_date ,' - ',date_duration);
	
	-- preparing the reports data from the different table on the basis of the SMS type and time 
   SELECT 
	report_metadata.ICCID as ICCID,
	report_metadata.MSISDN as MSISDN,
	report_metadata.IMSI as IMSI,
 --  report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
-- 	concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	 gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   '5' AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
	-- report_metadata.WHOLE_SALE_NAME AS PLAN,
	wholesale_plan_history.NEW_VALUE AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   /*cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
   cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,*/
	 case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
	else cdr_sms_details.ORIGINATION_GT end AS SERVING_SWITCH,
	case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
	else cdr_sms_details.SOURCE end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
	else cdr_sms_details.DESTINATION end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
	  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
	else cdr_sms_details.DESTINATION end  AS OPERATOR_NETWORK,
   cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join wholesale_plan_history on wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_sms_details.FINAL_TIME between  wholesale_plan_history.CREATE_DATE and wholesale_plan_history.CREATE_DATE))	
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and cdr_sms_details.SMS_STATUS ='Failed'
   and report_metadata.MNO_ACCOUNTID=in_account_id
   GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,  ORIGINATION_DATE ;
   
END//
DELIMITER ;
