USE gmsa_reports;


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
		SET @ACCOUNT_NAME = (SELECT ENT_ACCOUNT_NAME FROM report_metadata WHERE ENT_ACCOUNTID = in_account_id LIMIT 1);
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
		SELECT * FROM report_metadata
		WHERE ENT_ACCOUNTID = in_account_id;


		-- Processing of CDR DATA for monthly interval
		-- Filtering of CDR DATA on date interval
		DROP TABLE IF EXISTS temp_cdr_data_monthly_details;
		CREATE TEMPORARY TABLE temp_cdr_data_monthly_details
		SELECT IMSI,WHOLE_SALE_NAME,SERVICE_DATA_FLOW_ID,
			SUM(COALESCE(TOTAL_BYTES,0)) AS TOTAL_BYTES
		FROM temp_report_metadata
		LEFT JOIN cdr_data_details_vw
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
		INNER JOIN service_zone_details
			ON temp_cdr_data_monthly_details.SERVICE_DATA_FLOW_ID = service_zone_details.SERVICE_FLOW_ID
		LEFT JOIN rate_plan_details
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
		FROM temp_report_metadata
		LEFT JOIN cdr_data_details_vw
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
		INNER JOIN service_zone_details
			ON temp_cdr_data_yearly_details.SERVICE_DATA_FLOW_ID = service_zone_details.SERVICE_FLOW_ID
		LEFT JOIN rate_plan_details
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
		FROM temp_report_metadata
		LEFT JOIN cdr_sms_details
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
		INNER JOIN rate_plan_details
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
		FROM temp_report_metadata
		LEFT JOIN cdr_voice_completed
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
		INNER JOIN rate_plan_details
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
		FROM temp_report_metadata
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
		INNER JOIN rate_plan_details
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
