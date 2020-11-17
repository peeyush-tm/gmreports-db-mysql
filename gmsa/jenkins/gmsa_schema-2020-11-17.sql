USE gmsa_reports;

DROP PROCEDURE IF EXISTS gm_data_report;
DELIMITER $$
CREATE PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
   -- Modified by : Rahul Panwar
  -- Date: JUne, 2020 
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns cdr data on the basis of 
  -- the served imsi and STOP_TIME
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

	-- Declaration of the variables 
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);
	
   -- typecasting for start_date
   SET start_date:= CAST(in_start_date AS DATEtime);
	
	SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	   -- setting the row number to 0
		-- creating the wholesale table
	  SET @row_number = 0;
	  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
	  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

	  -- creating the wholesale table with id - 1
	  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
	  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

	  -- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
	  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
		-- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
	  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
	  
		-- creating the temp complete wholesale table
	  DROP TABLE IF EXISTS temp_wholesale_plan_history;
		CREATE TEMPORARY TABLE temp_wholesale_plan_history
	  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
		  COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
		  COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
		  COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
	  FROM temp_first_wholesale_plan_history 
	  LEFT JOIN temp_second_wholesale_plan_history
		ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
		  AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
				
		  -- creating index on imsi column of wholesale table
	  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);


	DROP TABLE IF EXISTS temp_data_report_details;
    CREATE TEMPORARY TABLE temp_data_report_details
	SELECT 
	report_metadata.ICCID AS ICCID,
	report_metadata.MSISDN AS MSISDN,
	report_metadata.IMSI AS IMSI,
-- 	report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
	-- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	-- (select BILLING_CYCLE FROM tadig_mapping where UPPER(tadig_mapping.COUNTRY) = UPPER(report_metadata.ACCOUNT_COUNTRIE) LIMIT 1) AS BILLING_CYCLE_DATE,
    @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
-- 	report_metadata.WHOLE_SALE_NAME AS PLAN,
	temp_wholesale_plan_history.plan AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   cdr_data_details_vw.UPLINK_BYTES AS TRANSMIT_BYTE,
   cdr_data_details_vw.DOWNLINK_BYTES AS RECEIVE_BYTES,
	cdr_data_details_vw.TOTAL_BYTES AS DATAUSAGE,
	-- sum(cdr_data_details_vw.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details_vw.APN_ID AS APN,
	cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
--   cdr_data_details_vw.SERVED_IMSI AS OPERATOR_NETWORK,
  -- concat(cdr_data_details_vw.ULI_MCC,case when CHAR_LENGTH(cdr_data_details_vw.ULI_MNC)=1 then  concat('0',cdr_data_details_vw.ULI_MNC) else cdr_data_details_vw.ULI_MNC end ) AS OPERATOR_NETWORK,
	(select COUNTRY FROM tadig_mapping where tadig_mapping.SGSN_IP = cdr_data_details_vw.SERVING_NODE_IPADDR LIMIT 1) AS OPERATOR_NETWORK,
    cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
	cdr_data_details_vw.DURATION_SEC AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
	cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
  	cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number,
   cdr_data_details_vw.CHARGING_ID
	from	((report_metadata
	INNER JOIN cdr_data_details_vw
 	ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
	LEFT JOIN gm_country_code_mapping ON report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	LEFT JOIN temp_wholesale_plan_history ON temp_wholesale_plan_history.IMSI=report_metadata.IMSI
	AND (cdr_data_details_vw.START_TIME BETWEEN  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
	   WHERE 
		DATE(cdr_data_details_vw.STOP_TIME) = DATE(start_date)
	  AND report_metadata.ENT_ACCOUNTID=in_account_id
	GROUP BY SERVED_IMSI,CHARGING_ID,LOCAL_SEQUENCE_NUMBER,START_TIME
    ORDER BY SERVED_IMSI,CHARGING_ID,LOCAL_SEQUENCE_NUMBER,START_TIME;
    
    DROP TABLE IF EXISTS temp_data_report_details_complete;
    CREATE TEMPORARY TABLE temp_data_report_details_complete
    SELECT * FROM temp_data_report_details;
    
	DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
	select 
    `ICCID`,
    `MSISDN`,
    `IMSI`,
    `SUPPLIER_ACCOUNT_ID`,
    `BILLING_CYCLE_DATE`,
    `PLAN`,
    (SELECT MIN(ORIGINATION_DATE)  FROM temp_data_report_details_complete
    WHERE temp_data_report_details_complete.IMSI = temp_data_report_details.IMSI AND 
		temp_data_report_details_complete.CHARGING_ID = temp_data_report_details.CHARGING_ID
		) AS ORIGINATION_DATE,
    `TRANSMIT_BYTE`,
    `RECEIVE_BYTES`,
    `DATAUSAGE`,
    CEIL(`DATAUSAGE`/1024) AS DATAUSAGE_ROUNDED,
    `APN`,
    `DEVICE_IP_ADDRESS`,
    `OPERATOR_NETWORK`,
    `ORIGINATION_DATE` AS ORIGINATION_DATE_RECORD_OPEN,
    `ORIGINATION_PLAN_DATE`,
    `SESSION_DURATION`,
    `CALL_TERMINATION_REASON`,
    `RATING_STREAM_ID`,
    `SERVING_SWITCH`,
    `CALL_TECHNOLOGY_TYPE`,
    `GGSN_IP_ADDRESS`,
    `Record_Sequence_Number`
    -- `CHARGING_ID` 
    from temp_data_report_details ;
	
	
  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
        OR BILLING_CYCLE_DATE IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
         OR TRANSMIT_BYTE IS NULL OR RECEIVE_BYTES IS NULL OR DATAUSAGE IS NULL
         OR APN IS NULL OR DEVICE_IP_ADDRESS IS NULL OR OPERATOR_NETWORK IS NULL
        OR ORIGINATION_DATE_RECORD_OPEN IS NULL OR ORIGINATION_PLAN_DATE IS NULL
        OR SESSION_DURATION IS NULL OR CALL_TERMINATION_REASON IS NULL
		  OR RATING_STREAM_ID IS NULL OR SERVING_SWITCH IS NULL
        OR CALL_TECHNOLOGY_TYPE IS NULL 
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL FROM temp_cdr_data_return_table
	-- WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
 
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_get_big_invoice_report;
DELIMITER $$
CREATE PROCEDURE `gm_get_big_invoice_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'This procedure is used to get the monthly recurring changes of cdr on the basis of account id'
BEGIN
/*
		----------------------------------------------------------------------------------------------------------------
		Description	:  This procedure is used to get the big invoice report on the basis of account id.
		Created On  :  18 Aug 2020
		Created By	:  Saurabh kumar
        ----------------------------------------------------------------------------------------------------------------
		Inputs		:   IN in_start_date : start date
					:	IN in_end_date   : end date
					:	IN in_account_id : account id
		Output		:	Return big invoice report	
		-----------------------------------------------------------------------------------------------------------------
	*/
		-- Preparing the hard coded values for report
		SET @ACCOUNT_ID = in_account_id;
		SET @ACCOUNT_NAME = (SELECT ACCOUNT_NAME FROM report_metadata WHERE ENT_ACCOUNTID = in_account_id LIMIT 1);
		SET @OPERATOR_ACCOUNT_ID = (SELECT '119008793');
		SET @ACCOUNT_TAX_ID = (SELECT '59.275.792/0001-50');
		SET @BILLING_CYCLE = (SELECT 206);
		SET @BILLING_MONTH = (SELECT MONTH(in_start_date));
		SET @BILLING_YEAR = (SELECT YEAR(in_start_date));
		SET @INVOICE_ID = (select CONCAT('AQ',in_account_id,SUBSTR(YEAR(in_start_date),3),MONTH(in_start_date),DAY(in_start_date),HOUR(in_start_date),MINUTE(in_start_date),SECOND(in_start_date)));
		SET @CURRENCY_CODE = (SELECT 'BRL');
		SET @BILLABLE_FLAG = (SELECT 'Y');

		-- Preparing the invoice data and due date
		SET @INVOICE_DATE =( select CONCAT(YEAR(in_start_date),MONTH(in_start_date),DAY(in_start_date),HOUR(in_start_date),MINUTE(in_start_date),SECOND(in_start_date)));
		SET @DUE_START_DATE = date_add(str_to_date(in_start_date,'%Y-%m-%d') ,INTERVAL 1 MONTH); 
		SET @DUE_DATE =(select CONCAT(YEAR(@DUE_START_DATE),MONTH(@DUE_START_DATE),DAY(@DUE_START_DATE),HOUR(@DUE_START_DATE),MINUTE(@DUE_START_DATE),SECOND(@DUE_START_DATE)));
			
		-- Temporary table to store the details of IMSI for only required account id
		DROP TABLE IF EXISTS temp_report_metadata;
		CREATE TEMPORARY TABLE temp_report_metadata
		SELECT * FROM .report_metadata
		WHERE ENT_ACCOUNTID = in_account_id;


		-- Processing of CDR DATA for monthly interval
		-- Filtering of CDR DATA on date interval
		DROP TABLE IF EXISTS temp_cdr_data_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_data_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,SERVICE_DATA_FLOW_ID,
			SUM(COALESCE(TOTAL_BYTES,0)) AS TOTAL_BYTES
		FROM .temp_report_metadata
		LEFT JOIN .cdr_data_details_vw
			ON temp_report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
		WHERE cdr_data_details_vw.START_TIME BETWEEN in_start_date and in_end_date
		GROUP BY IMSI,WHOLE_SALE_NAME,SERVICE_DATA_FLOW_ID;

		-- Defining the diff types of usage for CDR DATA for monthly interval
		DROP TABLE IF EXISTS temp_cdr_data_monthly_price_details;
		CREATE TEMPORARY TABLE temp_cdr_data_monthly_price_details
		SELECT IMSI,WHOLE_SALE_NAME,
			SERVICE_DATA_FLOW_ID,service_zone_details.ZONE,GC_PLAN_NAME,GM_PLAN_NAME,INCLUDED_VOLUME,
			PRICE,`INTERVAL`,TOTAL_BYTES,
			CASE WHEN TOTAL_BYTES <= INCLUDED_VOLUME * 1024 * 1024 THEN TOTAL_BYTES ELSE INCLUDED_VOLUME * 1024 * 1024 END AS INCLUDED_VOLUME_USED,
			CASE WHEN TOTAL_BYTES > INCLUDED_VOLUME * 1024 * 1024 THEN TOTAL_BYTES - INCLUDED_VOLUME * 1024 * 1024
				ELSE 0 END AS OVERAGE_VOLUME,
			0 AS ROAMING_USAGE,
			CASE WHEN TOTAL_BYTES > INCLUDED_VOLUME * 1024 * 1024 THEN ((TOTAL_BYTES - INCLUDED_VOLUME * 1024 * 1024)/1024.0) * PRICE
				ELSE 0 END AS OVERAGE_CHARGES,
			0 AS ROAMING_CHARGES
		FROM temp_cdr_data_monthly_details
		INNER JOIN .service_zone_details
			ON temp_cdr_data_monthly_details.SERVICE_DATA_FLOW_ID = service_zone_details.SERVICE_FLOW_ID
		LEFT JOIN .rate_plan_details
			ON rate_plan_details.GC_PLAN_NAME = WHOLE_SALE_NAME
				AND rate_plan_details.ZONE = service_zone_details.ZONE
		WHERE (`INTERVAL` IS NULL OR `INTERVAL` = 'MONTHLY');

		-- Aggregation of CDR DATA for Monthly Interval	
		DROP TABLE IF EXISTS temp_cdr_data_monthly_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_data_monthly_price_agg_details
		SELECT SUM(TOTAL_BYTES) AS TOTAL_BYTES,
				SUM(INCLUDED_VOLUME) AS INCLUDED_VOLUME,
				SUM(INCLUDED_VOLUME_USED) AS INCLUDED_VOLUME_USED,
				SUM(OVERAGE_VOLUME) AS OVERAGE_VOLUME,
				SUM(OVERAGE_CHARGES) AS OVERAGE_CHARGES,
				SUM(ROAMING_USAGE) AS ROAMING_USAGE,
				SUM(ROAMING_CHARGES) AS ROAMING_CHARGES
		FROM temp_cdr_data_monthly_price_details;

		-- Processing of CDR DATA for Yearly Interval
		-- Filteration must be done from start of the year for the given date
		SET @yearly_start_date = (SELECT CONCAT(LEFT(in_start_date, 5),'01-',RIGHT(in_start_date,2)));
		DROP TABLE IF EXISTS temp_cdr_data_yearly_details;
		CREATE TEMPORARY TABLE temp_cdr_data_yearly_details
		SELECT IMSI,WHOLE_SALE_NAME,SERVICE_DATA_FLOW_ID,
			SUM(COALESCE(TOTAL_BYTES,0)) AS TOTAL_BYTES
		FROM .temp_report_metadata
		LEFT JOIN .cdr_data_details_vw
			ON temp_report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
		WHERE cdr_data_details_vw.START_TIME BETWEEN @yearly_start_date and in_end_date
		GROUP BY IMSI,WHOLE_SALE_NAME,SERVICE_DATA_FLOW_ID;

		-- Processing of CDR DATA for Yearly Interval
		DROP TABLE IF EXISTS temp_cdr_data_yearly_price_details;
		CREATE TEMPORARY TABLE temp_cdr_data_yearly_price_details
		SELECT IMSI,WHOLE_SALE_NAME,
			SERVICE_DATA_FLOW_ID,service_zone_details.ZONE,GC_PLAN_NAME,GM_PLAN_NAME,INCLUDED_VOLUME,
			PRICE,`INTERVAL`,TOTAL_BYTES,
			CASE WHEN TOTAL_BYTES <= INCLUDED_VOLUME * 1024 * 1024 THEN TOTAL_BYTES 
				ELSE INCLUDED_VOLUME * 1024 * 1024 END AS INCLUDED_VOLUME_USED,
			CASE WHEN TOTAL_BYTES > INCLUDED_VOLUME * 1024 * 1024 THEN TOTAL_BYTES - INCLUDED_VOLUME * 1024 * 1024
				ELSE 0 END AS OVERAGE_VOLUME,
			0 AS ROAMING_USAGE,
			CASE WHEN TOTAL_BYTES > INCLUDED_VOLUME * 1024 * 1024 THEN ((TOTAL_BYTES - INCLUDED_VOLUME * 1024 * 1024)/1024.0) * PRICE
				ELSE 0 END AS OVERAGE_CHARGES,
			0 AS ROAMING_CHARGES
		FROM temp_cdr_data_yearly_details
		INNER JOIN .service_zone_details
			ON temp_cdr_data_yearly_details.SERVICE_DATA_FLOW_ID = service_zone_details.SERVICE_FLOW_ID
		LEFT JOIN .rate_plan_details
			ON rate_plan_details.GC_PLAN_NAME = WHOLE_SALE_NAME
				AND rate_plan_details.ZONE = service_zone_details.ZONE
		WHERE (`INTERVAL` = 'YEARLY')
			AND PLAN_TYPE = 'DATA';
			
		-- Aggregation of CDR DATA for Yearly Interval	
		DROP TABLE IF EXISTS temp_cdr_data_yearly_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_data_yearly_price_agg_details
		SELECT SUM(TOTAL_BYTES) AS TOTAL_BYTES,
				SUM(INCLUDED_VOLUME) AS INCLUDED_VOLUME,
				SUM(INCLUDED_VOLUME_USED) AS INCLUDED_VOLUME_USED,
				SUM(OVERAGE_VOLUME) AS OVERAGE_VOLUME,
				SUM(OVERAGE_CHARGES) AS OVERAGE_CHARGES,
				SUM(ROAMING_USAGE) AS ROAMING_USAGE,
				SUM(ROAMING_CHARGES) AS ROAMING_CHARGES
		FROM temp_cdr_data_yearly_price_details;

		-- Combining of CDR DATA for monthly and yearly interval
		DROP TABLE IF EXISTS temp_cdr_data_monthly_yearly_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_data_monthly_yearly_price_agg_details
		SELECT TOTAL_BYTES,INCLUDED_VOLUME,INCLUDED_VOLUME_USED,OVERAGE_VOLUME,OVERAGE_CHARGES,ROAMING_USAGE,ROAMING_CHARGES
		FROM temp_cdr_data_yearly_price_agg_details
		UNION
		SELECT TOTAL_BYTES,INCLUDED_VOLUME,INCLUDED_VOLUME_USED,OVERAGE_VOLUME,OVERAGE_CHARGES,ROAMING_USAGE,ROAMING_CHARGES
		FROM temp_cdr_data_monthly_price_agg_details;

		-- Final Aggregation of CDR DATA
		DROP TABLE IF EXISTS temp_cdr_data_total_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_data_total_price_agg_details
		SELECT CEIL(SUM(TOTAL_BYTES)/(1024*1024*1.0)) AS TOTAL_VOLUME,
				CEIL(SUM(INCLUDED_VOLUME)) AS INCLUDED_VOLUME,
				CEIL(SUM(INCLUDED_VOLUME_USED)/(1024*1024*1.0)) AS INCLUDED_VOLUME_USED,
				CEIL(SUM(OVERAGE_VOLUME)/(1024*1024*1.0)) AS OVERAGE_VOLUME,
				ROUND(SUM(OVERAGE_CHARGES),4) AS OVERAGE_CHARGES,
				CEIL(SUM(ROAMING_USAGE)) AS ROAMING_USAGE,
				ROUND(SUM(ROAMING_CHARGES),4) AS ROAMING_CHARGES
		FROM temp_cdr_data_monthly_yearly_price_agg_details;

		-- Processing of CDR SMS for monthly interval  
		-- Filtering of CDR SMS on date interval  
		DROP TABLE IF EXISTS temp_cdr_sms_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_sms_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,
			COALESCE(COUNT(*)) AS SMS_COUNT
		FROM .temp_report_metadata
		LEFT JOIN .cdr_sms_details
			ON temp_report_metadata.MSISDN = cdr_sms_details.SOURCE 
			OR temp_report_metadata.MSISDN = cdr_sms_details.DESTINATION
		WHERE cdr_sms_details.FINAL_TIME BETWEEN in_start_date and in_end_date
			AND SMS_STATUS ='Success'
		GROUP BY IMSI,WHOLE_SALE_NAME;

		-- Defining the diff types of usage for CDR SMS for monthly interval
		DROP TABLE IF EXISTS temp_cdr_sms_monthly_price_details;
		CREATE TEMPORARY TABLE temp_cdr_sms_monthly_price_details
		SELECT IMSI,WHOLE_SALE_NAME,
			GC_PLAN_NAME,GM_PLAN_NAME,INCLUDED_VOLUME,
			PRICE,`INTERVAL`,SMS_COUNT,
			CASE WHEN SMS_COUNT <= INCLUDED_VOLUME THEN SMS_COUNT
				ELSE INCLUDED_VOLUME END AS INCLUDED_VOLUME_USED,
			CASE WHEN SMS_COUNT > INCLUDED_VOLUME THEN SMS_COUNT - INCLUDED_VOLUME
				ELSE 0 END AS OVERAGE_VOLUME,
			0 AS ROAMING_USAGE,
			CASE WHEN SMS_COUNT > INCLUDED_VOLUME THEN (SMS_COUNT - INCLUDED_VOLUME) * PRICE
				ELSE 0 END AS OVERAGE_CHARGES,
			0 AS ROAMING_CHARGES
		FROM temp_cdr_sms_monthly_details
		INNER JOIN .rate_plan_details
			ON rate_plan_details.GC_PLAN_NAME = WHOLE_SALE_NAME
		WHERE PLAN_TYPE = 'SMS_MO';

		-- Final Aggregation of CDR DATA
		DROP TABLE IF EXISTS temp_cdr_sms_total_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_sms_total_price_agg_details
		SELECT SUM(SMS_COUNT) AS TOTAL_VOLUME,
				SUM(INCLUDED_VOLUME) AS INCLUDED_VOLUME,
				SUM(INCLUDED_VOLUME_USED) AS INCLUDED_VOLUME_USED,
				SUM(OVERAGE_VOLUME) AS OVERAGE_VOLUME,
				ROUND(SUM(OVERAGE_CHARGES),4) AS OVERAGE_CHARGES,
				SUM(ROAMING_USAGE) AS ROAMING_USAGE,
				ROUND(SUM(ROAMING_CHARGES),4) AS ROAMING_CHARGES
		FROM temp_cdr_sms_monthly_price_details;


		-- Processing of CDR VOICE for monthly interval
		-- Filtering of CDR VOICE complete on date interval
		DROP TABLE IF EXISTS temp_cdr_voice_complete_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_voice_complete_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,
			SUM(COALESCE(CALLDURATION,0)) AS CALLDURATION
		FROM .temp_report_metadata
		LEFT JOIN .cdr_voice_completed
				ON (temp_report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
					OR temp_report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
		WHERE cdr_voice_completed.ANMRECDAT BETWEEN in_start_date and in_end_date
			AND MOCALL = 1
		GROUP BY IMSI,WHOLE_SALE_NAME;

        -- -- Combining of CDR VOICE for Complete and Incomplete
		DROP TABLE IF EXISTS temp_cdr_voice_complete_incomplete_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_voice_complete_incomplete_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,CALLDURATION
		FROM temp_cdr_voice_complete_monthly_details;
		
		-- Aggregation of CDR VOICE
		DROP TABLE IF EXISTS temp_cdr_voice_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_voice_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,SUM(COALESCE(CALLDURATION,0)) AS CALLDURATION
		FROM temp_cdr_voice_complete_incomplete_monthly_details
		GROUP BY IMSI,WHOLE_SALE_NAME;

		-- Defining the diff types of usage for CDR DATA for monthly interval
		DROP TABLE IF EXISTS temp_cdr_voice_monthly_price_details;
		CREATE TEMPORARY TABLE temp_cdr_voice_monthly_price_details
		SELECT IMSI,WHOLE_SALE_NAME,
			GC_PLAN_NAME,GM_PLAN_NAME,INCLUDED_VOLUME,
			PRICE,`INTERVAL`,CALLDURATION,
			CASE WHEN CALLDURATION <= INCLUDED_VOLUME * 60 THEN CALLDURATION
				ELSE INCLUDED_VOLUME * 60 END AS INCLUDED_VOLUME_USED,
			CASE WHEN CALLDURATION > INCLUDED_VOLUME * 60 THEN CALLDURATION - INCLUDED_VOLUME * 60
				ELSE 0 END AS OVERAGE_VOLUME,
			0 AS ROAMING_USAGE,
			CASE WHEN CALLDURATION > INCLUDED_VOLUME * 60 THEN ((CALLDURATION - INCLUDED_VOLUME * 60)/60.0) * PRICE
				ELSE 0 END AS OVERAGE_CHARGES,
			0 AS ROAMING_CHARGES
		FROM temp_cdr_voice_monthly_details
		INNER JOIN .rate_plan_details
			ON rate_plan_details.GC_PLAN_NAME = WHOLE_SALE_NAME
		WHERE PLAN_TYPE = 'VOICE_MO';

		-- Final Aggregation of CDR VOICE
		DROP TABLE IF EXISTS temp_cdr_voice_total_price_agg_details;
		CREATE TEMPORARY TABLE temp_cdr_voice_total_price_agg_details
		SELECT CEIL(SUM(CALLDURATION)/60.0) AS TOTAL_VOLUME,
				CEIL(SUM(INCLUDED_VOLUME)) AS INCLUDED_VOLUME,
				CEIL(SUM(INCLUDED_VOLUME_USED)/60.0) AS INCLUDED_VOLUME_USED,
				CEIL(SUM(OVERAGE_VOLUME)/60.0) AS OVERAGE_VOLUME,
				ROUND(SUM(OVERAGE_CHARGES),4) AS OVERAGE_CHARGES,
				CEIL(SUM(ROAMING_USAGE)) AS ROAMING_USAGE,
				ROUND(SUM(ROAMING_CHARGES),4) AS ROAMING_CHARGES
		FROM temp_cdr_voice_monthly_price_details;

		-- Processing of SUBSCRIBER
		-- Selection of subscriber
		DROP TABLE IF EXISTS temp_subscriber_monthly_details;
		CREATE TEMPORARY TABLE temp_subscriber_monthly_details
		SELECT WHOLE_SALE_NAME,
			COALESCE(COUNT(*),0) AS SUBSCRIBER_COUNT
		FROM .temp_report_metadata
		GROUP BY WHOLE_SALE_NAME;

		-- Defining the diff types of usage for CDR DATA for monthly interval
		DROP TABLE IF EXISTS temp_subscriber_monthly_price_details;
		CREATE TEMPORARY TABLE temp_subscriber_monthly_price_details
		SELECT WHOLE_SALE_NAME,
			GC_PLAN_NAME,GM_PLAN_NAME,0 AS INCLUDED_VOLUME,
			PRICE,`INTERVAL`,SUBSCRIBER_COUNT,
			0 AS INCLUDED_VOLUME_USED,
			0 AS OVERAGE_VOLUME,
			0 AS OVERAGE_CHARGES, 
			0 AS ROAMING_USAGE,
			0 AS ROAMING_CHARGES
		FROM temp_subscriber_monthly_details
		INNER JOIN .rate_plan_details
			ON rate_plan_details.GC_PLAN_NAME = WHOLE_SALE_NAME
		WHERE PLAN_TYPE = 'SUBSCRIBER';

		-- Final Aggregation of SUBSCRIBER	
		DROP TABLE IF EXISTS temp_subscriber_total_price_agg_details;
		CREATE TEMPORARY TABLE temp_subscriber_total_price_agg_details
		SELECT SUM(SUBSCRIBER_COUNT) AS TOTAL_VOLUME,
				0 AS INCLUDED_VOLUME,
				0 AS INCLUDED_VOLUME_USED,
				0 AS OVERAGE_VOLUME,
				ROUND(SUM(PRICE * SUBSCRIBER_COUNT),4) AS OVERAGE_CHARGES,
				0 ROAMING_USAGE,
				0 AS ROAMING_CHARGES
		FROM temp_subscriber_monthly_price_details;

		-- Preparing the various counts for subscriber
		SET @TOTAL_SUBSCRIBERS = (SELECT COUNT(*) FROM temp_report_metadata);
		SET @TOTAL_ACTIVE_SUBSCRIBERS = (SELECT COALESCE(COUNT(*),0) FROM temp_report_metadata WHERE SIM_STATE = 'Activated');
		SET @TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD =(SELECT COALESCE(COUNT(DISTINCT IMSI),0) FROM temp_cdr_data_monthly_details);

		-- returning the results by combining the data of subscriber,data,voice and sms
		SELECT 'SUBS_MONTHLY' AS CHARGED_RECORD_TYPE,@ACCOUNT_ID AS ACCOUNT_ID,@ACCOUNT_NAME AS ACCOUNT_NAME,@OPERATOR_ACCOUNT_ID AS OPERATOR_ACCOUNT_ID,
			@ACCOUNT_TAX_ID AS ACCOUNT_TAX_ID,@BILLING_CYCLE AS BILLING_CYCLE,@BILLING_MONTH AS BILLING_MONTH,@BILLING_YEAR AS BILLING_YEAR,
			@INVOICE_ID AS INVOICE_ID,@CURRENCY_CODE AS CURRENCY_CODE,@BILLABLE_FLAG AS BILLABLE_FLAG,@INVOICE_DATE AS INVOICE_DATE,@DUE_DATE AS DUE_DATE,
			@TOTAL_SUBSCRIBERS AS TOTAL_SUBSCRIBERS,@TOTAL_ACTIVE_SUBSCRIBERS AS TOTAL_ACTIVE_SUBSCRIBERS,
			@TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD AS TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD,
			0 AS TOTAL_VOLUME,0 AS TOTAL_INCLUDED_VOLUME_USED,0 AS TOTAL_OVERAGE_VOLUME_USED,0 AS TOTAL_ROAMING_VOLUME_USED,
			OVERAGE_CHARGES AS TOTAL_CHARGES,0 AS TOTAL_OVERAGE_CHARGES,ROAMING_CHARGES AS TOTAL_ROAMING_CHARGES
		FROM temp_subscriber_total_price_agg_details
		UNION
		SELECT 'DATA_MONTHLY' AS CHARGED_RECORD_TYPE,@ACCOUNT_ID AS ACCOUNT_ID,@ACCOUNT_NAME AS ACCOUNT_NAME,@OPERATOR_ACCOUNT_ID AS OPERATOR_ACCOUNT_ID,
			@ACCOUNT_TAX_ID AS ACCOUNT_TAX_ID,@BILLING_CYCLE AS BILLING_CYCLE,@BILLING_MONTH AS BILLING_MONTH,@BILLING_YEAR AS BILLING_YEAR,
			@INVOICE_ID AS INVOICE_ID,@CURRENCY_CODE AS CURRENCY_CODE,@BILLABLE_FLAG AS BILLABLE_FLAG,@INVOICE_DATE AS INVOICE_DATE,@DUE_DATE AS DUE_DATE,
			0 AS TOTAL_SUBSCRIBERS,0 AS TOTAL_ACTIVE_SUBSCRIBERS,
			0 AS TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD,
			INCLUDED_VOLUME_USED + OVERAGE_VOLUME AS TOTAL_VOLUME,INCLUDED_VOLUME_USED AS TOTAL_INCLUDED_VOLUME_USED,OVERAGE_VOLUME AS TOTAL_OVERAGE_VOLUME_USED,ROAMING_USAGE AS TOTAL_ROAMING_VOLUME_USED,
			OVERAGE_CHARGES AS TOTAL_CHARGES,OVERAGE_CHARGES AS TOTAL_OVERAGE_CHARGES,ROAMING_CHARGES AS TOTAL_ROAMING_CHARGES
		FROM temp_cdr_data_total_price_agg_details
		UNION
		SELECT 'SMSMO_MONTHLY' AS CHARGED_RECORD_TYPE,@ACCOUNT_ID AS ACCOUNT_ID,@ACCOUNT_NAME AS ACCOUNT_NAME,@OPERATOR_ACCOUNT_ID AS OPERATOR_ACCOUNT_ID,
			@ACCOUNT_TAX_ID AS ACCOUNT_TAX_ID,@BILLING_CYCLE AS BILLING_CYCLE,@BILLING_MONTH AS BILLING_MONTH,@BILLING_YEAR AS BILLING_YEAR,
			@INVOICE_ID AS INVOICE_ID,@CURRENCY_CODE AS CURRENCY_CODE,@BILLABLE_FLAG AS BILLABLE_FLAG,@INVOICE_DATE AS INVOICE_DATE,@DUE_DATE AS DUE_DATE,
			0 AS TOTAL_SUBSCRIBERS,0 AS TOTAL_ACTIVE_SUBSCRIBERS,
			0 AS TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD,
			TOTAL_VOLUME AS TOTAL_VOLUME,INCLUDED_VOLUME_USED AS TOTAL_INCLUDED_VOLUME_USED,OVERAGE_VOLUME AS TOTAL_OVERAGE_VOLUME_USED,ROAMING_USAGE AS TOTAL_ROAMING_VOLUME_USED,
			OVERAGE_CHARGES AS TOTAL_CHARGES,OVERAGE_CHARGES AS TOTAL_OVERAGE_CHARGES,ROAMING_CHARGES AS TOTAL_ROAMING_CHARGES
		FROM temp_cdr_sms_total_price_agg_details
		UNION
		SELECT 'VOICEMO_MONTHLY' AS CHARGED_RECORD_TYPE,@ACCOUNT_ID AS ACCOUNT_ID,@ACCOUNT_NAME AS ACCOUNT_NAME,@OPERATOR_ACCOUNT_ID AS OPERATOR_ACCOUNT_ID,
			@ACCOUNT_TAX_ID AS ACCOUNT_TAX_ID,@BILLING_CYCLE AS BILLING_CYCLE,@BILLING_MONTH AS BILLING_MONTH,@BILLING_YEAR AS BILLING_YEAR,
			@INVOICE_ID AS INVOICE_ID,@CURRENCY_CODE AS CURRENCY_CODE,@BILLABLE_FLAG AS BILLABLE_FLAG,@INVOICE_DATE AS INVOICE_DATE,@DUE_DATE AS DUE_DATE,
			0 AS TOTAL_SUBSCRIBERS,0 AS TOTAL_ACTIVE_SUBSCRIBERS,
			0 AS TOTAL_ACTIVE_SUBSCRIBERS_CHARGED_PERIOD,
			INCLUDED_VOLUME_USED + OVERAGE_VOLUME AS TOTAL_VOLUME,INCLUDED_VOLUME_USED AS TOTAL_INCLUDED_VOLUME_USED,OVERAGE_VOLUME AS TOTAL_OVERAGE_VOLUME_USED,ROAMING_USAGE AS TOTAL_ROAMING_VOLUME_USED,
			OVERAGE_CHARGES AS TOTAL_CHARGES,OVERAGE_CHARGES AS TOTAL_OVERAGE_CHARGES,ROAMING_CHARGES AS TOTAL_ROAMING_CHARGES
		FROM temp_cdr_voice_total_price_agg_details;


END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_get_mno_account_id;
DELIMITER $$
CREATE PROCEDURE `gm_get_mno_account_id`(
IN in_account_id INT
)
    COMMENT 'This procedure is used to return the MNO account id '
BEGIN
 /*
  --------------------------------------------------------------------------------------------------------------------------------------
  Description :  This procedure is used to return the MNO account id
  Created On  :  11 Nov 2020
  Created By  :  Saurabh kumar
  --------------------------------------------------------------------------------------------------------------------------------------
  Inputs :    IN `in_account_id` int(16), 
  Output  :   This procedure is used to return the supplier account id
  ---------------------------------------------------------------------------------------------------------------------------------------
*/
  SELECT MNO_ACCOUNTID FROM report_metadata WHERE ENT_ACCOUNTID = in_account_id LIMIT 1;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS gm_get_supplier_account_id;
DELIMITER $$
CREATE PROCEDURE `gm_get_supplier_account_id`(
IN in_account_id INT
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
	SELECT CASE WHEN in_account_id = 7 THEN 8
				WHEN in_account_id = 10 THEN 9
                WHEN in_account_id = 11 THEN 11
			ELSE in_account_id END AS country_ode ;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_mobile_number_reconciliation_report;
DELIMITER $$
CREATE PROCEDURE `gm_mobile_number_reconciliation_report`(
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  
  
  
  
  
  
  
  
   
  
  DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table;
    CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table
    SELECT ICCID ,
    IMSI , 
    MSISDN ,
    gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
  case when SIM_STATE='Warm' then 'Device Shipped'
   when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL'  then 'UnSoldNewVehicle' 
   when SIM_STATE='Active' then 'Subscribed' 
   when SIM_STATE='Suspend' then 'Dormant' 
   else SIM_STATE end as SIM_STATE_GM,
     SIM_STATE as SIM_STATE_GT,

    CASE WHEN WHOLE_SALE_NAME ='null' THEN NULL ELSE WHOLE_SALE_NAME END AS PRICING_PLAN,
    0 AS COMMUNCATION_PLAN,
    CASE WHEN ACTIVATION_DATE ='null' THEN NULL ELSE ACTIVATION_DATE END AS ICCID_ACTIVATION_DATE,
    
    CASE WHEN BOOTSTRAP_ICCID ='null' THEN NULL ELSE BOOTSTRAP_ICCID END AS BOOTSTRAP_ICCID
    FROM report_metadata
   left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
   where report_metadata.ENT_ACCOUNTID=in_account_id;
   
   -- applying the check of mandatory column
   DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table_new;
   CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table_new
     SELECT temp_mobile_reconciliation_data_return_table.*,
    CASE WHEN `ICCID` IS NULL OR `MSISDN` IS NULL OR `IMSI` IS NULL 
      OR `SUPPLIER_ACCOUNT_ID` IS NULL OR `SIM_STATE_GT` IS NULL OR `SIM_STATE_GM` IS NULL OR `PRICING_PLAN` IS NULL
      OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL OR `BOOTSTRAP_ICCID` IS NULL
      THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;
  
  -- updating the value for WARM state sim
	UPDATE temp_mobile_reconciliation_data_return_table_new
    SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
	
    SELECT * FROM temp_mobile_reconciliation_data_return_table_new
    ORDER BY MANDATORY_COL_NULL DESC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_sms_delivered_report;
DELIMITER $$
CREATE PROCEDURE `gm_sms_delivered_report`(
IN `in_start_date` varchar(50), 
IN `in_end_date` varchar(50), 
IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_delivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_delivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the delivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms delivered report genarted 
  -- **********************************************************************
	
   -- Declaring the variables 
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
	 SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
	-- Preparing the billing dates
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
		   -- setting the row number to 0
		-- creating the wholesale table
	  SET @row_number = 0;
	  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
	  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

	  -- creating the wholesale table with id - 1
	  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
	  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

	  -- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
	  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
		-- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
	  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
	  
		-- creating the temp complete wholesale table
	  DROP TABLE IF EXISTS temp_wholesale_plan_history;
		CREATE TEMPORARY TABLE temp_wholesale_plan_history
	  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
		  COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
		  COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
		  COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
	  FROM temp_first_wholesale_plan_history 
	  LEFT JOIN temp_second_wholesale_plan_history
		ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
		  AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
				
		  -- creating index on imsi column of wholesale table
	  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

    DROP TABLE IF EXISTS temp_cdr_sms_delivered_return_table;
    CREATE TEMPORARY TABLE temp_cdr_sms_delivered_return_table
  -- preparing the reports data from the different table on the basis of the SMS type and time 
	SELECT 
    report_metadata.ICCID AS ICCID,
	report_metadata.MSISDN AS MSISDN,
	report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   -- report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
    @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   -- (select BILLING_CYCLE FROM tadig_mapping where UPPER(tadig_mapping.COUNTRY) = UPPER(report_metadata.ACCOUNT_COUNTRIE) LIMIT 1) AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
	-- report_metadata.WHOLE_SALE_NAME AS PLAN,
	 temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
	else NULL end AS SERVING_SWITCH,
	case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
	else NULL end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
	else NULL end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
/*	  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
	else NULL end  AS OPERATOR_NETWORK */
	CASE WHEN cdr_sms_details.SMS_TYPE='MO' THEN (SELECT COUNTRY FROM tadig_mapping WHERE UPPER(tadig_mapping.TADIG_CODE) = UPPER(cdr_sms_details.ORIGINATION_GT) LIMIT 1)
	WHEN cdr_sms_details.SMS_TYPE='MT' THEN (SELECT COUNTRY FROM tadig_mapping WHERE UPPER(tadig_mapping.TADIG_CODE) = UPPER(cdr_sms_details.DESTINATION_GT) LIMIT 1)
	END AS OPERATOR_NETWORK
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))	
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
	and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
	and report_metadata.ENT_ACCOUNTID=in_account_id;
	-- GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,ORIGINATION_DATE ;
	
		SELECT temp_cdr_sms_delivered_return_table.*,
	  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
		  OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
		  OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
				OR OPERATOR_NETWORK IS NULL
		THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
	  FROM temp_cdr_sms_delivered_return_table
	-- 	WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
		ORDER BY MANDATORY_COL_NULL DESC;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_voice_report;
DELIMITER $$
CREATE PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
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
    SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
 	
	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- generate a table to fetch the data from the complete voice table 
	DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
	CREATE TEMPORARY TABLE temp_voice_complete
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
	ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
		or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
	and report_metadata.ENT_ACCOUNTID=in_account_id;
	
		   -- setting the row number to 0
		-- creating the wholesale table
	  SET @row_number = 0;
	  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
	  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

	  -- creating the wholesale table with id - 1
	  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
	  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
	  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

	  -- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
	  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
		-- adding index on temporary wholesale table
	  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
	  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
	  
		-- creating the temp complete wholesale table
	  DROP TABLE IF EXISTS temp_wholesale_plan_history;
		CREATE TEMPORARY TABLE temp_wholesale_plan_history
	  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
		  COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
		  COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
		  COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
	  FROM temp_first_wholesale_plan_history 
	  LEFT JOIN temp_second_wholesale_plan_history
		ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
		  AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
				
		  -- creating index on imsi column of wholesale table
	  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

	-- preparing the data from merging the both table complete and incomplete	
	DROP  TEMPORARY TABLE if EXISTS temp_voice;
	CREATE TEMPORARY TABLE temp_voice
	SELECT * FROM temp_voice_complete;                         
	
    DROP TABLE IF EXISTS temp_voice_data_return_table;
    CREATE TEMPORARY TABLE temp_voice_data_return_table
	-- final result report of the voice data 
	SELECT 
	temp_voice.ICCID  AS 'ICCID',
	temp_voice.IMSI AS 'IMSI',
	temp_voice.MSISDN AS 'MSISDN',
	-- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
	COUNTRY_CODE AS 'ACCOUNT ID',
	-- MNO_ACCOUNTID AS 'ACCOUNT ID',
	-- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
	@TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',
	CALLINGNUMBER AS 'CALLING PARTY NUMBER',
	CALLEDNUMBER AS 'CALLED',
	CALLDURATION AS 'ANSWER DURATION',
	case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS UNSIGNED)*60 end as 'ANSWER DURATION ROUNDED',
	ANMRECDAT AS 'ORIGINATION DATE',
    (SELECT COUNTRY FROM tadig_mapping WHERE tadig_mapping.TADIG_CODE = cdr_voice_tadig_codes.TC_TADIG_CODE LIMIT 1) AS 'OPERATOR NETWORK',
	-- concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
	-- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
	 case when MOCALL=0 OR MOCALL IS NULL 
      then LASTERBCSM
       when MOCALL=1 
      then COALESCE(LASTERBCSM,0)
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
	
	
	  SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `ACCOUNT ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
		OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
			OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
		OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
		THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
	  FROM temp_voice_data_return_table 
	  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
	  ORDER BY MANDATORY_COL_NULL DESC;


END$$
DELIMITER ;
