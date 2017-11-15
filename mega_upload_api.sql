REM  Organization		: SunTec Business Solutions Pvt. Ltd.
REM			  	  321 Nila, TechnoPark, Kariavattom,
REM			  	  Trivandrum, India-695 581
REM			  	  Phone No : 0091-471-2700984
REM  Copyright (c) 2017, SunTec Business Solutions Pvt. Ltd. All rights reserved.
REM
REM  ATTENTION: Please do not type any thing in this part (below).PVCS will automatically update the values.
REM  File Name			: $Workfile:$
REM  Revision No		: $Revision:$
REM  TimeStamp			: $Modtime:$
REM  Checked in On		: $Date:$
REM  Archive			: $Archive:$
REM  ATTENTION: Please do not type any thing in this part (above).PVCS will automatically update the values.
REM
REM  Author			: 
REM  Error Number Prefix  	:
REM  Last Error Number    	:
REM  Header comments		: PMS 61488
REM  Modification Details	:
REM  Modified by 	| Date   | Reference to PRS/URS/PMS number & Explanation
REM  Sunitha		| 01/03/2017 | PMS 61725
REM  Vidya V		| 15/06/2017 | PMS 62023
REM  Vidya V		| 03/08/2017 | PMS 63141

CREATE OR REPLACE PACKAGE mega_upload_api AS	
				      		 
    	PROCEDURE priority_definition(ip_det_id			IN  VARCHAR2,
				      ip_excel_id 		IN  VARCHAR2,
				      op_err_code		OUT VARCHAR2,
				      op_err_msg		OUT VARCHAR2);     
						  		    
	PROCEDURE validate_priority_data(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2);
	
	FUNCTION get_cust_no(ip_cust_id IN VARCHAR2) RETURN NUMBER;

	PROCEDURE validate_standard(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2);
	
	PROCEDURE standard_pricelist(ip_xl_id IN VARCHAR2,
			ip_template_id IN VARCHAR2,
			op_tv_uid 	OUT VARCHAR2, 
			op_eff_from_date OUT VARCHAR2,
			op_eff_to_date	OUT VARCHAR2,
			op_err_code	OUT VARCHAR2,
			op_err_msg	OUT VARCHAR2);
			
	PROCEDURE validate_neg_data(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2);
	
	PROCEDURE negotiated_pricelist(ip_xl_id IN VARCHAR2,
					ip_template_id IN VARCHAR2,
					op_tv_uid 			OUT VARCHAR2, 
					op_act_id 			OUT VARCHAR2,							  	 
					op_cust_id 			OUT VARCHAR2,
					op_eff_from_date		OUT VARCHAR2,
					op_eff_to_date			OUT VARCHAR2,
					op_stv_id			OUT VARCHAR2,
					op_stv_inh_ind			OUT VARCHAR2,
					op_err_code			OUT VARCHAR2,
					op_err_msg			OUT VARCHAR2);

	PROCEDURE standard_pricelist_single_grp(ip_group_id			IN  VARCHAR2,
					     ip_excel_id 			IN  VARCHAR2,
					     op_tv_uid 				OUT VARCHAR2, 
					     op_eff_from_date			OUT VARCHAR2,
					     op_eff_to_date			OUT VARCHAR2,
					     op_err_code			OUT VARCHAR2,
					     op_err_msg				OUT VARCHAR2) ;
					     
	PROCEDURE negotiated_pricelist_grp(ip_group_id			IN  VARCHAR2,
					ip_excel_id 			IN  VARCHAR2,
					op_tv_uid 			OUT VARCHAR2, 
					op_act_id 			OUT VARCHAR2,							  	 
					op_cust_id 			OUT VARCHAR2,
					op_eff_from_date		OUT VARCHAR2,
					op_eff_to_date			OUT VARCHAR2,
					op_stv_id			OUT VARCHAR2,
					op_stv_inh_ind			OUT VARCHAR2,
					op_err_code			OUT VARCHAR2,
					op_err_msg			OUT VARCHAR2);
	
END mega_upload_api;
/
CREATE OR REPLACE PACKAGE BODY mega_upload_api AS

	g_rows		NUMBER(5) := 2000;
	--g_date_format	VARCHAR2(30) := 'DD/MM/RRRR HH24:MI:SS';
	g_date_format	VARCHAR2(30) := 'DD/MON/RRRR';

	TYPE err_arr IS TABLE OF CSTM_MEGA_UPLOAD_ERROR_MSG%ROWTYPE INDEX BY BINARY_INTEGER;
	g_err_tab err_arr;
	
	TYPE cmud_arry IS TABLE OF CSTM_MEGA_UPLOAD_DET.CMUD_ID%TYPE INDEX BY BINARY_INTEGER; 	
	
	TYPE det_seq_arr IS TABLE OF CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL2%TYPE INDEX BY VARCHAR2(100); 	
				   
	
	g_cmud_id_tab_type 	cmud_arry;
	
	g_grp_seq_tab_type 	det_seq_arr;
	
	TYPE cmud_arr IS TABLE OF CSTM_MEGA_UPLOAD_DET.CMUD_ID%TYPE INDEX BY BINARY_INTEGER;       	
	g_cmud_id_tab cmud_arr;

	TYPE tcg_arr IS TABLE OF TARIFF_VARIATION.TV_TCG_CODE%TYPE INDEX BY BINARY_INTEGER; 
	
	TYPE priority_def_rec IS RECORD(cmud_cmu_id 	 CSTM_MEGA_UPLOAD_DET.CMUD_CMU_ID%TYPE,		      	      
				   cmud_id 		 CSTM_MEGA_UPLOAD_DET.CMUD_ID%TYPE,		      	      
				   group_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL2%TYPE,	      	      
				   grp_seq_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL3%TYPE,	      	      
				   market	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL4%TYPE,	      	      
				   division		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL5%TYPE,		      
				   priority		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL6%TYPE,		      
				   term_code		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL7%TYPE,
				   cust_no		 CUSTOMER_MASTER.CM_CUST_NO%TYPE);
			
	TYPE  priority_def_tab	IS TABLE OF priority_def_rec INDEX BY BINARY_INTEGER;	

	TYPE std_def_rec IS RECORD(cmud_cmu_id 	 	 CSTM_MEGA_UPLOAD_DET.CMUD_CMU_ID%TYPE,		      	      
				   cmud_id 		 CSTM_MEGA_UPLOAD_DET.CMUD_ID%TYPE,		      	      
				   group_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL1%TYPE,	      	      
				   grp_seq_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL2%TYPE,	      	      
				   country	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL3%TYPE,
				   tv_tcg_code		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL4%TYPE,
				   tv_des		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL5%TYPE,
				   tv_tarif_band	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL6%TYPE,		      
				   gbt_des		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL7%TYPE,		      
				   tv_qos_code		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL8%TYPE,		      
				   tv_tf_code		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL9%TYPE,		      
				   tv_pricing_template	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL10%TYPE,
				   tv_tariff_class	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL11%TYPE,
				   tv_from_date		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL12%TYPE,
				   tv_to_date		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL13%TYPE,
				   tv_trans_currency	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL14%TYPE,
				   --ts_usage_data	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL15%TYPE,
				   tc_cum_type		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL15%TYPE,
				   tc_rate_type 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL16%TYPE,
				   tier_from		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL17%TYPE,
				   tier_to		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL18%TYPE,
				   rate		 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL19%TYPE,
				   tcr_upper_limit	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL20%TYPE,
				   cmud_data_col21	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL21%TYPE,
				   cmud_data_col22	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL22%TYPE,
				   cmud_data_col23	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL23%TYPE,
				   cmud_data_col24	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL24%TYPE,
				   cmud_data_col25	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL25%TYPE,
				   cmud_data_col26	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL26%TYPE,
				   cmud_data_col27	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL27%TYPE,
				   cmud_data_col28	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL28%TYPE,
				   cmud_data_col29	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL29%TYPE,
				   cmud_data_col30	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL30%TYPE,
				   cmud_data_col31	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL31%TYPE,
				   cmud_data_col32	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL32%TYPE,
				   cmud_data_col33	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL33%TYPE,
				   cmud_data_col34	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL34%TYPE,
				   cmud_data_col35	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL35%TYPE,
				   cmud_data_col36	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL36%TYPE,
				   cmud_data_col37	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL37%TYPE,
				   cmud_data_col38	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL38%TYPE,
				   cmud_data_col39 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL39%TYPE,
				   cmud_data_col40	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL40%TYPE,
				   cmud_data_col41	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL41%TYPE,
				   cmud_data_col42	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL42%TYPE,
				   cmud_data_col43   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL43%TYPE,
				   cmud_data_col44   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL44%TYPE,
				   cmud_data_col45	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL45%TYPE,
				   cmud_data_col46   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL46%TYPE,
				   cmud_data_col47   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL47%TYPE,
				   status		 CSTM_MEGA_UPLOAD_DET.CMUD_STATUS%TYPE
				   );

	TYPE  std_def_tab IS TABLE OF std_def_rec INDEX BY BINARY_INTEGER;	

	TYPE neg_def_rec IS RECORD(cmud_cmu_id 	 	 CSTM_MEGA_UPLOAD_DET.CMUD_CMU_ID%TYPE,		      	      
				   cmud_id 		 CSTM_MEGA_UPLOAD_DET.CMUD_ID%TYPE,		      	      
				   group_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL1%TYPE,	      	      
				   grp_seq_id	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL2%TYPE,	      	      
				   country	     	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL3%TYPE,
				   tv_tcg_code		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL4%TYPE,
				   cust_no		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL5%TYPE,
				   tv_tarif_band	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL6%TYPE,
				   gbt_des	 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL7%TYPE,		      
				   tc_rate_type		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL8%TYPE,		      
				   tier_from		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL9%TYPE,		      
				   tier_to	 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL10%TYPE,
				   rate	 		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL11%TYPE,
				   tv_pricing_template	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL12%TYPE,
				   ts_des 		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL13%TYPE,
				   tv_tariff_class	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL14%TYPE,
				   tv_qos_code	 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL15%TYPE,
				   tv_trans_currency	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL16%TYPE,
				   stv_from_date 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL17%TYPE,
				   stv_to_date		 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL18%TYPE,
				   cmud_data_col19	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL19%TYPE,
				   cmud_data_col20	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL20%TYPE,
				   cmud_data_col21	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL21%TYPE,
				   cmud_data_col22	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL22%TYPE,
				   cmud_data_col23	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL23%TYPE,
				   cmud_data_col24	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL24%TYPE,
				   cmud_data_col25	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL25%TYPE,
				   cmud_data_col26	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL26%TYPE,
				   cmud_data_col27	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL27%TYPE,
				   cmud_data_col28	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL28%TYPE,
				   cmud_data_col29	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL29%TYPE,
				   cmud_data_col30	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL30%TYPE,
				   cmud_data_col31	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL31%TYPE,
				   cmud_data_col32	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL32%TYPE,
				   cmud_data_col33	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL33%TYPE,
				   cmud_data_col34	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL34%TYPE,
				   cmud_data_col35	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL35%TYPE,
				   cmud_data_col36	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL36%TYPE,
				   cmud_data_col37	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL37%TYPE,
				   cmud_data_col38	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL38%TYPE,
				   cmud_data_col39 	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL39%TYPE,
				   cmud_data_col40	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL40%TYPE,
				   cmud_data_col41	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL41%TYPE,
				   cmud_data_col42	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL42%TYPE,
				   cmud_data_col43   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL43%TYPE,
				   cmud_data_col44   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL44%TYPE,
				   cmud_data_col45	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL45%TYPE,
				   cmud_data_col46   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL46%TYPE,
				   cmud_data_col47   	 CSTM_MEGA_UPLOAD_DET.CMUD_DATA_COL47%TYPE,
				   status		 CSTM_MEGA_UPLOAD_DET.CMUD_STATUS%TYPE
				   );

	TYPE  neg_def_tab IS TABLE OF neg_def_rec INDEX BY BINARY_INTEGER;	
	
	g_tcg_tab			tcg_arr; 
	
	subs_tariff_var_obj 		subs_tariff_variation_api_obj 		:= subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	subs_tariff_var  		subs_tariff_var_api_obj_array 		:= subs_tariff_var_api_obj_array(subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)) ;--dc
	tariff_var_obj 			tariff_variation_api_obj 		:= tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_variation_array   	tariff_variation_api_obj_array  	:= tariff_variation_api_obj_array(tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC
	tariff_call_rates_obj		call_rates_api_obj			:= call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_call_rates_array		call_rates_api_obj_array		:= call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC

	tariff_call_scheme_obj		call_scheme_api_obj 			:= call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)));--DC
	tariff_call_scheme_array	call_scheme_api_obj_array 		:= call_scheme_api_obj_array(call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null));--DC

	charge_code_user_attr		ccua_api_obj				:= ccua_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
					
	--ORATERMINATE 		EXCEPTION;--PMS 58712
	
	--PRAGMA EXCEPTION_INIT( ORATERMINATE, -22222 );--PMS 58712
	
	
/*-------------------------------------------------------------------------------------------------
	 Procedure 	:  log_error
	 Purpose	:
	-------------------------------------------------------------------------------------------------*/

	/*PROCEDURE debug_log(ip_message in varchar2) IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN

		INSERT INTO TEST_DEBUG1(T_ID ,T_MSG ) VALUES (T_ID.NEXTVAL,ip_message);	
		commit;

	EXCEPTION
		--WHEN ORATERMINATE THEN
		--	RAISE ORATERMINATE;
	WHEN OTHERS THEN
		ROLLBACK;
		Stbms_Err.disp_err( 100030, SQLERRM );
	END debug_log;	 */
	
/*-------------------------------------------------------------------------------------------------
	Procedure    : clear --PMS 58712
	Purpose      :
*-------------------------------------------------------------------------------------------------*/
	
	PROCEDURE clear AS
	
	BEGIN
		g_err_tab.delete; 
				 
	EXCEPTION
		WHEN OTHERS THEN
		STBMS_ERR.DISP_ERR( 100071, SQLERRM );
	
END clear;


/*-------------------------------------------------------------------------------------------------
 Procedure	: load_err
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE load_err(	ip_xl_id IN VARCHAR2,
			ip_det_id IN VARCHAR2,
			ip_err_code IN VARCHAR2,
			ip_err_msg IN VARCHAR2,
			ip_flag IN VARCHAR2 DEFAULT 'P',
			ip_dmy_stat IN VARCHAR2 DEFAULT NULL) IS

m_index NUMBER(10);
BEGIN
	m_index := g_err_tab.COUNT + 1;								  			

	g_err_tab(m_index).CMUEM_REC_ID 	:= MEGA_UPLOAD_ERROR_SEQ.NEXTVAL;
	g_err_tab(m_index).CMUEM_CMU_ID 	:= ip_xl_id;
	g_err_tab(m_index).CMUEM_CMUD_ID 	:= ip_det_id;
	g_err_tab(m_index).CMUEM_ERROR_CODE 	:= ip_err_code;
	g_err_tab(m_index).CMUEM_ERROR_MSG 	:= ip_err_msg;
	g_err_tab(m_index).CMUEM_DATE_TIME 	:= SYSDATE;
	
	
	
	IF ip_flag ='P'THEN
		g_err_tab(m_index).CMUEM_ERROR_TYPE := 'P';
	ELSE 
		g_err_tab(m_index).CMUEM_ERROR_TYPE := 'V';
	END IF;
	
	
EXCEPTION
	WHEN OTHERS THEN
	Stbms_Err.disp_err (100072,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END load_err;


/*-------------------------------------------------------------------------------------------------
 Procedure	: load_up_err
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE load_up_err(	ip_xl_id IN VARCHAR2,
			ip_det_id IN VARCHAR2,
			ip_grp_id IN VARCHAR2,
			ip_seq_id IN VARCHAR2,
			ip_err_code IN VARCHAR2,
			ip_err_msg IN VARCHAR2,
			ip_flag IN VARCHAR2 DEFAULT 'P',
			ip_dmy_stat IN VARCHAR2 DEFAULT NULL) IS

m_index NUMBER(10);
BEGIN
	m_index := g_err_tab.COUNT + 1;								  			

	g_err_tab(m_index).CMUEM_REC_ID 	:= MEGA_UPLOAD_ERROR_SEQ.NEXTVAL;
	g_err_tab(m_index).CMUEM_CMU_ID 	:= ip_xl_id;
	g_err_tab(m_index).CMUEM_CMUD_ID 	:= ip_det_id;
	g_err_tab(m_index).CMUEM_ERROR_CODE 	:= ip_err_code;
	g_err_tab(m_index).CMUEM_ERROR_MSG 	:= ip_err_msg;
	g_err_tab(m_index).CMUEM_DATE_TIME 	:= SYSDATE;
	
	
	
	IF ip_flag ='P'THEN
		g_err_tab(m_index).CMUEM_ERROR_TYPE := 'P';
	ELSE 
		g_err_tab(m_index).CMUEM_ERROR_TYPE := 'V';
	END IF;

	g_grp_seq_tab_type(ip_grp_id) 	:= ip_seq_id;
	
	
EXCEPTION
	WHEN OTHERS THEN
	Stbms_Err.disp_err (100072,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END load_up_err;
/*-------------------------------------------------------------------------------------------------
	 Function	: is_number -- PMS 61725
	 Purpose	: 
-------------------------------------------------------------------------------------------------*/
	
	FUNCTION is_number( chk_data_in VARCHAR2 ) RETURN BOOLEAN IS
	                dummy NUMBER(38,4);
	BEGIN
	                dummy := TO_NUMBER(chk_data_in);
	                RETURN TRUE;
	EXCEPTION
	                WHEN VALUE_ERROR THEN
	                                RETURN FALSE;
	END;
/*-------------------------------------------------------------------------------------------------
 Procedure	: check_err_table
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE check_err_table(ip_xl_id IN VARCHAR2,ip_grp_id IN VARCHAR2,ip_type IN VARCHAR2 ) IS

m_det_id VARCHAR2(100) := '';

	CURSOR
		cmuem_cur IS
	SELECT 
		1
	FROM
		CSTM_MEGA_UPLOAD_ERROR_MSG
	WHERE
		CMUEM_CMU_ID = ip_xl_id
	AND
		CMUEM_CMUD_ID = m_det_id;
		
	

m_err_cnt  VARCHAR2(10);

BEGIN

	FOR i IN 1 .. g_cmud_id_tab_type.COUNT LOOP
	
		m_det_id := g_cmud_id_tab_type(i);
		
		m_err_cnt := NULL;
				
		OPEN cmuem_cur;
		FETCH cmuem_cur INTO m_err_cnt;
		
		IF cmuem_cur%NOTFOUND THEN		
			IF ip_type ='V' THEN
				load_err(ip_xl_id,m_det_id,'V10025','Error in Some Other Functional id - '||ip_grp_id,'V','Y');
			ELSE
				load_err(ip_xl_id,m_det_id,'P10016','Error in Some Other Functional id - '||ip_grp_id,'P','Y');
			END IF;
		END IF;

		IF cmuem_cur%ISOPEN THEN CLOSE cmuem_cur; END IF;
	
	END LOOP;
	
EXCEPTION
	WHEN OTHERS THEN
		IF cmuem_cur%ISOPEN THEN CLOSE cmuem_cur; END IF;
		Stbms_Err.disp_err (100073,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END check_err_table;

/*-------------------------------------------------------------------------------------------------
 Procedure	: check_group_err
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE check_group_err(ip_xl_id IN VARCHAR2,ip_grp_id IN VARCHAR2,ip_type IN VARCHAR2 ) IS

m_det_id VARCHAR2(100) := '';
m_grp_seq VARCHAR2(100):= '';

	CURSOR
		cmuem_cur IS
	SELECT 
		1
	FROM
		CSTM_MEGA_UPLOAD_ERROR_MSG
	WHERE
		CMUEM_CMU_ID = ip_xl_id
	AND
		CMUEM_CMUD_ID = m_det_id;
		
	

m_err_cnt  VARCHAR2(10);

BEGIN

	FOR i IN 1 .. g_cmud_id_tab_type.COUNT LOOP
	
		m_det_id := g_cmud_id_tab_type(i);
		m_grp_seq := g_grp_seq_tab_type(ip_grp_id);
		
		m_err_cnt := NULL;
				
		OPEN cmuem_cur;
		FETCH cmuem_cur INTO m_err_cnt;
		
		IF cmuem_cur%NOTFOUND THEN		
			IF ip_type ='V' THEN
				load_err(ip_xl_id,m_det_id,'V10025','Validation Error in Tier Sequence - '||m_grp_seq||' of Term Group - '||ip_grp_id,'V','Y');
			ELSE
				load_err(ip_xl_id,m_det_id,'P10016','Processing Error in Tier Sequence - '||m_grp_seq||' of Term Group - '||ip_grp_id,'P','Y');
			END IF;
		END IF;

		IF cmuem_cur%ISOPEN THEN CLOSE cmuem_cur; END IF;
	
	END LOOP;
	
EXCEPTION
	WHEN OTHERS THEN
		IF cmuem_cur%ISOPEN THEN CLOSE cmuem_cur; END IF;
		Stbms_Err.disp_err (100073,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END check_group_err;	

/*-------------------------------------------------------------------------------------------------
Procedure 	: log_error
 Purpose	: 
-------------------------------------------------------------------------------------------------*/
PROCEDURE log_error( ip_excel_id 	IN VARCHAR2,
					 ip_group_id	IN VARCHAR2)IS PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN

	FORALL i IN 1 .. g_err_tab.COUNT
		INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);																	

	UPDATE 
		CSTM_MEGA_UPLOAD_DET
	SET
		CMUD_STATUS = 'E',
		CMUD_ERROR_TYPE = 'P',
		CMUD_ERROR_DESC = g_err_tab(1).CMUEM_ERROR_MSG--,
		--CMUD_STATUS_DUMMY = 'N'
	WHERE
		CMUD_CMU_ID = ip_excel_id
	AND
		CMUD_ID =ip_group_id;	
			
	g_err_tab.DELETE;
	
	check_err_table(ip_excel_id,ip_group_id,'P');

	FORALL i IN 1 .. g_err_tab.COUNT
		INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);				
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Stbms_Err.disp_err (100074,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END log_error;

/*-------------------------------------------------------------------------------------------------
Procedure 	: log_prcs_error
 Purpose	: 
-------------------------------------------------------------------------------------------------*/
PROCEDURE log_prcs_error( ip_excel_id 	IN VARCHAR2,
					 ip_group_id	IN VARCHAR2)IS PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN

	FORALL i IN 1 .. g_err_tab.COUNT
		INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);																	

	UPDATE 
		CSTM_MEGA_UPLOAD_DET
	SET
		CMUD_STATUS = 'E',
		CMUD_ERROR_TYPE = 'P'
	WHERE
		CMUD_CMU_ID = ip_excel_id
	AND
		CMUD_DATA_COL1 = ip_group_id;	
			
	g_err_tab.DELETE;
	
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Stbms_Err.disp_err (100074,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END log_prcs_error;
/*-------------------------------------------------------------------------------------------------
Procedure 	: log_data_error
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE log_data_error( ip_excel_id 	IN  VARCHAR2,
					 	  ip_group_id	IN  VARCHAR2)IS PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN

	FORALL i IN 1 .. g_err_tab.COUNT
		INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
																	

	UPDATE 
		CSTM_MEGA_UPLOAD_DET
	SET
		CMUD_STATUS = 'E',
		CMUD_ERROR_TYPE = 'P'
	WHERE
		CMUD_CMU_ID = ip_excel_id
	AND
		CMUD_DATA_COL1 = ip_group_id;
		
		
	g_err_tab.DELETE;
	check_group_err(ip_excel_id,ip_group_id,'P');

	FORALL i IN 1 .. g_err_tab.COUNT
		INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);		
		
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Stbms_Err.disp_err( 100035, SQLERRM );
END log_data_error;
/*-------------------------------------------------------------------------------------------------
Procedure 	: log_std_error
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE log_std_error( ip_excel_id 	IN  VARCHAR2,
					 	 ip_group_id	IN  VARCHAR2)IS
BEGIN
	ROLLBACK;
	log_data_error(ip_excel_id,ip_group_id);	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		Stbms_Err.disp_err( 100034, SQLERRM );
END log_std_error;
/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_prior_single_grp --SS
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_prior_single_grp(ip_grp_id IN VARCHAR2,ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	prt_det_cur IS
SELECT
	cmud_id id,
	cmud_data_col1	Grp_id,
	cmud_data_col2  seq_no,
	cmud_data_col5  priority
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
AND 
	--cmud_id = ip_grp_id
	CMUD_DATA_COL1 = ip_grp_id
ORDER BY
	to_number(cmud_id);
	
CURSOR
	prior_det_cur IS
SELECT
	cmud_id id,
	cmud_data_col1	Grp_id,
	cmud_data_col2  seq_no,
	cmud_data_col5  priority
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
AND 
	--cmud_id = ip_grp_id
	CMUD_DATA_COL1 IS NULL
ORDER BY
	to_number(cmud_id);
		
	
TYPE det_arr IS TABLE OF prt_det_cur%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE prio_det_arr IS TABLE OF prior_det_cur%ROWTYPE INDEX BY BINARY_INTEGER;

m_det_tab 	det_arr;
m_det_prio_tab	prio_det_arr;
m_err_flag 	BOOLEAN := FALSE;
m_indx 		NUMBER := 0;
m_prior_flag 	BOOLEAN := FALSE; -- PMS 61725

BEGIN	

	g_err_tab.DELETE;
	g_cmud_id_tab_type.DELETE;
	
	IF ip_grp_id IS NOT NULL THEN 
	
	OPEN prt_det_cur;
	LOOP
	
		m_det_tab.DELETE;		
		
		FETCH prt_det_cur BULK COLLECT INTO m_det_tab LIMIT 500;	
	
		EXIT WHEN m_det_tab.COUNT = 0;
		

		FOR i IN 1 .. m_det_tab.COUNT LOOP
		
			m_indx := g_cmud_id_tab_type.COUNT + 1;
			
			g_cmud_id_tab_type(m_indx) := m_det_tab(i).id;
		
			IF m_det_tab(i).seq_no <> TO_CHAR(i) THEN														
				--load_err(ip_xl_id,m_det_tab(i).id,'V10014','Sequence should be in order  and should not be duplicated for the same functional Id / Functional ID -'||m_det_tab(i).Grp_id ,'V');
				load_err(ip_xl_id,m_det_tab(i).id,'V10015','Sequence Id for a group must be continuous sequence starting from 1','V');
			END IF;
			
				/*** PMS 61725 ***/
			IF m_det_tab(i).priority IS NOT NULL THEN		
				m_prior_flag := is_number(m_det_tab(i).priority);
				IF m_prior_flag THEN
					IF m_det_tab(i).priority  < 0 THEN 
						load_err(ip_xl_id,m_det_tab(i).id,'V10016','Invalid value for Priority','V');
					END IF;
					
					IF m_det_tab(i).priority  >= 0 THEN 
						IF m_det_tab(i).priority <> TO_CHAR(i) THEN
						
							load_err(ip_xl_id,m_det_tab(i).id,'V10015','Priority for a group must be continuous sequence starting from 1','V');
						END IF;
					END IF;
				END IF;
			END IF;
			
				/*** PMS 61725 ***/
			
				/*IF m_det_tab(i).priority <> TO_CHAR(i) THEN	
			
					load_err(ip_xl_id,m_det_tab(i).id,'V10015','Priority for a group must be continuous sequence starting from 1','V');
				END IF;*/ -- PMS 61725
			
		END LOOP;
			
	END LOOP;
	
	ELSE
	
	
	OPEN prior_det_cur;
		LOOP
		
			m_det_prio_tab.DELETE;		
			
			FETCH prior_det_cur BULK COLLECT INTO m_det_prio_tab LIMIT 500;	
		
			EXIT WHEN m_det_prio_tab.COUNT = 0;
			
	
			FOR i IN 1 .. m_det_prio_tab.COUNT LOOP
			
				m_indx := g_cmud_id_tab_type.COUNT + 1;
				
				g_cmud_id_tab_type(m_indx) := m_det_prio_tab(i).id;
			
				IF m_det_prio_tab(i).seq_no <> TO_CHAR(i) THEN														
					--load_err(ip_xl_id,m_det_prio_tab(i).id,'V10014','Sequence should be in order  and should not be duplicated for the same functional Id / Functional ID -'||m_det_prio_tab(i).Grp_id ,'V');
					load_err(ip_xl_id,m_det_prio_tab(i).id,'V10015','Sequence Id for a group must be continuous sequence starting from 1','V');
				END IF;
				
					/*** PMS 61725 ***/
				IF m_det_prio_tab(i).priority IS NOT NULL THEN		
					m_prior_flag := is_number(m_det_prio_tab(i).priority);
					IF m_prior_flag THEN
						IF m_det_prio_tab(i).priority  < 0 THEN 
							load_err(ip_xl_id,m_det_prio_tab(i).id,'V10016','Invalid value for Priority','V');
						END IF;
						
						IF m_det_prio_tab(i).priority  >= 0 THEN 
							IF m_det_prio_tab(i).priority <> TO_CHAR(i) THEN	
								load_err(ip_xl_id,m_det_prio_tab(i).id,'V10015','Priority for a group must be continuous sequence starting from 1','V');
							END IF;
						END IF;
					END IF;
				END IF;
				
					/*** PMS 61725 ***/
				
					/*IF m_det_tab(i).priority <> TO_CHAR(i) THEN	
				
						load_err(ip_xl_id,m_det_tab(i).id,'V10015','Priority for a group must be continuous sequence starting from 1','V');
					END IF;*/ -- PMS 61725
				
			END LOOP;
				
	END LOOP;
	
	END IF;
			
	IF g_err_tab.COUNT > 0 THEN
	
		m_err_flag := TRUE;				
		
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
	
	END IF;	

	IF m_err_flag THEN
	
		g_err_tab.DELETE;
		check_err_table(ip_xl_id,ip_grp_id,'V');
		
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
		
		UPDATE 
			CSTM_MEGA_UPLOAD_DET
		SET
			CMUD_STATUS = 'E',
			CMUD_ERROR_TYPE = 'V'
		WHERE
			CMUD_CMU_ID = ip_xl_id
		AND
			--CMUD_ID = ip_grp_id;	
			CMUD_DATA_COL1 = ip_grp_id;
			
	END IF;	
	
	COMMIT;

	IF prt_det_cur%ISOPEN THEN CLOSE prt_det_cur; END IF; 
	IF prior_det_cur%ISOPEN THEN CLOSE prior_det_cur; END IF;
	
	
EXCEPTION
	WHEN OTHERS THEN
		IF prt_det_cur%ISOPEN THEN CLOSE prt_det_cur; END IF;		
		IF prior_det_cur%ISOPEN THEN CLOSE prior_det_cur; END IF;
		Stbms_Err.disp_err (100075,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );
		
END validate_prior_single_grp;		
/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_priority_data -- SS
 Purpose	: File Level Validation 
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_priority_data(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	det_grp_id_cur IS
SELECT
	--distinct cmud_id grp_id 
	DISTINCT CMUD_DATA_COL1 grp_id
	--cmud_id
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
ORDER BY
	--cmud_id;
	grp_id;
	--to_number(cmud_id);
	
TYPE det_grp_id_arr IS TABLE OF det_grp_id_cur%ROWTYPE INDEX BY binary_integer;

m_det_grp_id_tab det_grp_id_arr;
	
	
BEGIN	

	OPEN det_grp_id_cur;	
	LOOP
		m_det_grp_id_tab.DELETE;
		FETCH det_grp_id_cur BULK COLLECT INTO m_det_grp_id_tab LIMIT g_rows;
		EXIT WHEN m_det_grp_id_tab.COUNT = 0;
		
		FOR i IN 1..m_det_grp_id_tab.COUNT LOOP		
		
			validate_prior_single_grp(m_det_grp_id_tab(i).grp_id,ip_xl_id,ip_template_id);		
		END LOOP;	
	END LOOP;	
	IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;	
EXCEPTION
	WHEN OTHERS THEN
		IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;
		Stbms_Err.disp_err (100076,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END validate_priority_data;	

/*-------------------------------------------------------------------------------------------------
 Procedure 	: validate_priority_definition  
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/
 
PROCEDURE validate_priority_definition(ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS

CURSOR market_cur IS
	select off_off_code from offices WHERE off_off_code = ip_priority_def_tab(ip_index).market;
		
CURSOR division_cur IS
	select cm_cust_id from customer_master where cm_cc_code = 'DIV' and cm_cust_id = ip_priority_def_tab(ip_index).division and cm_status = 'A';

CURSOR term_code_cur IS
	SELECT tcm_charge_code FROM TRANSACTION_CODES_MAPPING WHERE TCM_USER20 = 'Y' and tcm_charge_code = ip_priority_def_tab(ip_index).term_code;
	
market_rec		market_cur%ROWTYPE;
division_rec		division_cur%ROWTYPE;
term_code_rec		term_code_cur%ROWTYPE;
		
BEGIN


	IF ip_priority_def_tab(ip_index).market IS NOT NULL THEN  		
	  	
		OPEN market_cur;	
		
			FETCH market_cur INTO market_rec;
			
			IF market_cur%NOTFOUND THEN	   
				
				load_err(ip_priority_def_tab(ip_index).cmud_cmu_id,ip_priority_def_tab(ip_index).cmud_id,'P10002','Invalid Market ID','P');
				
				IF market_cur%ISOPEN THEN CLOSE market_cur; END IF;					  	
			 
			END IF;
			
			IF market_cur%ISOPEN THEN CLOSE market_cur; END IF;		
		
	END IF;

	IF ip_priority_def_tab(ip_index).division IS NOT NULL THEN	
		  	
		OPEN division_cur;	

			FETCH division_cur INTO division_rec;

			IF division_cur%NOTFOUND THEN	   
				
				load_err(ip_priority_def_tab(ip_index).cmud_cmu_id,ip_priority_def_tab(ip_index).cmud_id,'P10003','Division does not exist','P');

				IF division_cur%ISOPEN THEN CLOSE division_cur; END IF;					  	

			END IF;

		IF division_cur%ISOPEN THEN CLOSE division_cur; END IF;	
	
	END IF;
	
	
	IF ip_priority_def_tab(ip_index).term_code IS NOT NULL THEN  		

		OPEN term_code_cur;	

			FETCH term_code_cur INTO term_code_rec;

			IF term_code_cur%NOTFOUND THEN	   
					
				load_err(ip_priority_def_tab(ip_index).cmud_cmu_id,ip_priority_def_tab(ip_index).cmud_id,'P10004','Term Code does not exist','P');

				IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;					  	

			END IF;

		IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;
	END IF;
		
EXCEPTION 	
	WHEN OTHERS THEN
		 IF market_cur%ISOPEN THEN CLOSE market_cur; END IF;	
		 IF division_cur%ISOPEN THEN CLOSE division_cur; END IF;			
		 IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;
	 stbms_err.disp_err( 100079, SQLERRM );
END validate_priority_definition;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: validate_standard_record  
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/
 
PROCEDURE validate_standard_record(ip_std_def_rec IN std_def_rec) AS

CURSOR tcg_cur IS
	select tcg_code from tariff_call_group WHERE tcg_code = ip_std_def_rec.tv_tcg_code;
		
CURSOR term_code_cur IS
	SELECT bdd_bd_code FROM f_bill_det_des WHERE bdd_bd_code = ip_std_def_rec.tv_tarif_band;

CURSOR meth_cur IS
	SELECT ts_ts_code FROM tariff_scheme WHERE ts_pricing_template = ip_std_def_rec.tv_pricing_template and ts_template_type is null;
	
CURSOR currency_cur IS
	SELECT cur_code FROM currency_codes WHERE cur_code = ip_std_def_rec.tv_trans_currency;

CURSOR qos_cur IS
	SELECT qos_code FROM quality_of_service WHERE qos_code = ip_std_def_rec.tv_qos_code;
/*
CURSOR tf_cur IS
	select  tuf_user_field_code from  tariff_user_fields where tuf_ind='E' and tuf_user_field_code = ip_std_def_rec.tv_tariff_class;
*/

m_tcg 		tariff_call_group.tcg_code%type;
m_term_code 	TRANSACTION_CODES_MAPPING.tcm_charge_code%type;
m_meth 		tariff_scheme.ts_ts_code%type;
m_cur_code	currency_codes.cur_code%type;
m_qos		quality_of_service.qos_code%type;
m_tf_code	tariff_user_fields.tuf_user_field_code%type;

		
BEGIN

	--Validate PriceList
	IF(ip_std_def_rec.tv_tcg_code IS NOT NULL) THEN
	
		OPEN tcg_cur;	
		FETCH tcg_cur INTO m_tcg;

		IF tcg_cur%NOTFOUND THEN	   

			load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20005','Invalid Price List','V');

			IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;					  	

		END IF;

		IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;	
	END IF;

	--Validate TermCode
	
	OPEN term_code_cur;		

	FETCH term_code_cur INTO m_term_code;

	IF term_code_cur%NOTFOUND THEN	   

		load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20006','Invalid Term Code','V');

		IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;					  	

	END IF;

	IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;	
	
	--Validate Methododlogy
	
	OPEN meth_cur;	
	
	FETCH meth_cur INTO m_term_code;

	IF meth_cur%NOTFOUND THEN	   

		load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20007','Invalid Methodology','V');

		IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;					  	

	END IF;

	IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;	
	
	--Validate Currency
	IF ip_std_def_rec.tv_trans_currency IS NOT NULL THEN
	
		OPEN currency_cur;		

		FETCH currency_cur INTO m_cur_code;

		IF currency_cur%NOTFOUND THEN	   

			load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20008','Invalid Currency','V');

			IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;					  	

		END IF;

		IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;	
	END IF;

	--Validate QOS
	IF ip_std_def_rec.tv_qos_code IS NOT NULL THEN
		OPEN qos_cur;	

			FETCH qos_cur INTO m_qos;

		IF qos_cur%NOTFOUND THEN	   

			load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20009','Invalid Function Code','V');

			IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;					  	

		END IF;

		IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;
	END IF;
	
   
	IF(ip_std_def_rec.tc_cum_type NOT IN ('Flat Computation - Rate Type','Flat Computation - Absolute','Tiered Computation - Rate Type','Tiered Computation - Absolute')) THEN
	   
		load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20011','Invalid Computation Type','V');
	
	END IF;
	
	--Validate Date
	
	IF(trunc(to_date(ip_std_def_rec.tv_from_date,g_date_format)) < stbms_std.low_date OR trunc(to_date(ip_std_def_rec.tv_from_date,g_date_format)) > stbms_std.high_date) THEN
		load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20012','From Date should be within TBMS Low Date and high Date','V');
	END IF;
	
	IF(ip_std_def_rec.tv_to_date IS NOT NULL) THEN
		IF(trunc(to_date(ip_std_def_rec.tv_to_date,g_date_format)) < stbms_std.low_date OR trunc(to_date(ip_std_def_rec.tv_to_date,g_date_format)) > stbms_std.high_date) THEN
			load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20013','To Date should be within TBMS Low Date and high Date','V');
		END IF;
	END IF;
		
EXCEPTION 	
	WHEN OTHERS THEN
		IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;		
		IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;	
		IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;	
		IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;	
		IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;
		--IF tf_cur%ISOPEN THEN CLOSE tf_cur; END IF;
	 	stbms_err.disp_err( 100179, SQLERRM );
	 	
END validate_standard_record;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: duplicate_check  
 Purpose	: Duplicate Check for Standard Upload
-------------------------------------------------------------------------------------------------*/

PROCEDURE duplicate_check_sequence(ip_std_def_rec IN std_def_rec) AS


CURSOR duplicate_cur IS	
	 select *  from
	    (select    cmud_id,
	    cmud_cmu_id,
	    cmud_data_col1,
	    cmud_data_col2,
	    row_number() over (partition by cmud_data_col1||cmud_data_col2    
	    order by  cmud_data_col1||cmud_data_col2 ) as duplicate_rec
	    from      cstm_mega_upload_det where cmud_cmu_id = ip_std_def_rec.CMUD_CMU_ID ) dup_tab
	    where     duplicate_rec > 1  and cmud_cmu_id = ip_std_def_rec.CMUD_CMU_ID
	    and  cmud_data_col1 = ip_std_def_rec.group_id;    


duplicate_rec		duplicate_cur%ROWTYPE;
		
BEGIN		
		
	OPEN duplicate_cur;	

	FETCH duplicate_cur INTO duplicate_rec;

	IF duplicate_cur%FOUND THEN	

		load_up_err(ip_std_def_rec.cmud_cmu_id,ip_std_def_rec.cmud_id,ip_std_def_rec.group_id,ip_std_def_rec.grp_seq_id,'V20014','Duplicate Sequence Number - '||duplicate_rec.cmud_data_col2,'V');

	END IF;

	IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;     
			
EXCEPTION 	
	WHEN OTHERS THEN
		 IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;	
	 stbms_err.disp_err( 100080, SQLERRM );
END duplicate_check_sequence; 

/*-------------------------------------------------------------------------------------------------
 Procedure 	: subrec_data_validation
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE std_subrec_data_validation(ip_first_cmud_data_tab IN std_def_rec, ip_cmud_data_tab IN std_def_rec) AS
BEGIN

	IF	ip_first_cmud_data_tab.country 		<> ip_cmud_data_tab.country OR  
		ip_first_cmud_data_tab.tv_tcg_code 	<> ip_cmud_data_tab.tv_tcg_code OR
		ip_first_cmud_data_tab.tv_des 		<> ip_cmud_data_tab.tv_des OR
		ip_first_cmud_data_tab.tv_tarif_band 	<> ip_cmud_data_tab.tv_tarif_band OR 
		ip_first_cmud_data_tab.gbt_des 		<> ip_cmud_data_tab.gbt_des OR
		ip_first_cmud_data_tab.tv_qos_code 	<> ip_cmud_data_tab.tv_qos_code OR
		ip_first_cmud_data_tab.tv_tf_code 	<> ip_cmud_data_tab.tv_tf_code OR
		ip_first_cmud_data_tab.tv_tariff_class 	<> ip_cmud_data_tab.tv_tariff_class OR
		ip_first_cmud_data_tab.tv_pricing_template <> ip_cmud_data_tab.tv_pricing_template OR
		ip_first_cmud_data_tab.tv_from_date 	<> ip_cmud_data_tab.tv_from_date OR
		ip_first_cmud_data_tab.tv_to_date 	<> ip_cmud_data_tab.tv_to_date OR
		ip_first_cmud_data_tab.tv_trans_currency <> ip_cmud_data_tab.tv_trans_currency OR
		ip_first_cmud_data_tab.tc_cum_type 	<> ip_cmud_data_tab.tc_cum_type OR
		ip_first_cmud_data_tab.tc_rate_type 	<> ip_cmud_data_tab.tc_rate_type OR
		ip_first_cmud_data_tab.tcr_upper_limit <> ip_cmud_data_tab.tcr_upper_limit OR
		ip_first_cmud_data_tab.cmud_data_col22 <> ip_cmud_data_tab.cmud_data_col22 OR
		ip_first_cmud_data_tab.cmud_data_col23 <> ip_cmud_data_tab.cmud_data_col23 OR
		ip_first_cmud_data_tab.cmud_data_col24 <> ip_cmud_data_tab.cmud_data_col24 OR
		ip_first_cmud_data_tab.cmud_data_col25 <> ip_cmud_data_tab.cmud_data_col25 OR
		ip_first_cmud_data_tab.cmud_data_col26 <> ip_cmud_data_tab.cmud_data_col26 OR
		ip_first_cmud_data_tab.cmud_data_col27 <> ip_cmud_data_tab.cmud_data_col27 OR
		ip_first_cmud_data_tab.cmud_data_col28 <> ip_cmud_data_tab.cmud_data_col28 OR
		ip_first_cmud_data_tab.cmud_data_col29 <> ip_cmud_data_tab.cmud_data_col29 OR
		ip_first_cmud_data_tab.cmud_data_col30 <> ip_cmud_data_tab.cmud_data_col30 OR
		ip_first_cmud_data_tab.cmud_data_col31 <> ip_cmud_data_tab.cmud_data_col31 OR
		ip_first_cmud_data_tab.cmud_data_col32 <> ip_cmud_data_tab.cmud_data_col32 OR
		ip_first_cmud_data_tab.cmud_data_col33 <> ip_cmud_data_tab.cmud_data_col33 OR
		ip_first_cmud_data_tab.cmud_data_col34 <> ip_cmud_data_tab.cmud_data_col34 OR
		ip_first_cmud_data_tab.cmud_data_col35 <> ip_cmud_data_tab.cmud_data_col35 OR
		ip_first_cmud_data_tab.cmud_data_col36 <> ip_cmud_data_tab.cmud_data_col36 OR
		ip_first_cmud_data_tab.cmud_data_col37 <> ip_cmud_data_tab.cmud_data_col37 OR
		ip_first_cmud_data_tab.cmud_data_col38 <> ip_cmud_data_tab.cmud_data_col38 OR
		ip_first_cmud_data_tab.cmud_data_col39 <> ip_cmud_data_tab.cmud_data_col39 OR
		ip_first_cmud_data_tab.cmud_data_col40 <> ip_cmud_data_tab.cmud_data_col40 OR
		ip_first_cmud_data_tab.cmud_data_col41 <> ip_cmud_data_tab.cmud_data_col41 OR
		ip_first_cmud_data_tab.cmud_data_col42 <> ip_cmud_data_tab.cmud_data_col42 OR
		ip_first_cmud_data_tab.cmud_data_col43 <> ip_cmud_data_tab.cmud_data_col43 OR
		ip_first_cmud_data_tab.cmud_data_col44 <> ip_cmud_data_tab.cmud_data_col44 OR
		ip_first_cmud_data_tab.cmud_data_col45 <> ip_cmud_data_tab.cmud_data_col45 OR
		ip_first_cmud_data_tab.cmud_data_col47 <> ip_cmud_data_tab.cmud_data_col47 OR
		ip_first_cmud_data_tab.cmud_data_col46 <> ip_cmud_data_tab.cmud_data_col46 THEN

		load_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,'V20002','In case of tiered definition, all records should have same values for all fields except Tier From, Tier To, Rate');
	
	END IF;	
EXCEPTION 	
	WHEN OTHERS THEN
		 stbms_err.disp_err( 100023, SQLERRM );
END std_subrec_data_validation;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_std_tier 
 Purpose	:
-------------------------------------------------------------------------------------------------*/
PROCEDURE validate_std_tier( ip_tier IN VARCHAR2,ip_cmud_data_tab IN std_def_tab ,ip_index IN NUMBER) IS
	m_num		NUMBER(28,8);
BEGIN

	BEGIN
		m_num := to_number(ip_tier);
	EXCEPTION
		WHEN OTHERS THEN
		
		load_up_err(ip_cmud_data_tab(ip_index).cmud_cmu_id,ip_cmud_data_tab(ip_index).cmud_id,ip_cmud_data_tab(ip_index).group_id,ip_cmud_data_tab(ip_index).grp_seq_id,'V20003','Special/Non Numeric Characters Not Expected for Tier From/Tier To','V');
	END;

	/*IF ip_tier <0 THEN
	
	load_err(ip_cmud_data_tab(ip_index).cmud_cmu_id,ip_cmud_data_tab(ip_index).cmud_id,'V20004','Negative values not Expected for Tier','V');
	
	END IF;*/

EXCEPTION
	--WHEN ORATERMINATE THEN
	--	RAISE ORATERMINATE;
	WHEN OTHERS THEN
		stbms_err.disp_err( 100022, SQLERRM );
END validate_std_tier;

/*-------------------------------------------------------------------------------------------------
Procedure    : check_std_mode
Purpose      :									
/*-------------------------------------------------------------------------------------------------*/


FUNCTION check_std_mode(  ip_cmud_data_tab IN  std_def_tab ) RETURN VARCHAR2 IS


	CURSOR update_cur IS
	SELECT
		tv_uid,
		tv_tarif_sch,
		tv_cwt_code,
		tv_personalised_yn,
		tv_status
	FROM
		TARIFF_VARIATION
	WHERE
		NVL(tv_tarif_band ,'$$') = NVL(ip_cmud_data_tab(1).TV_TARIF_BAND,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).TV_TCG_CODE,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		NVL(tv_qos_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_qos_code,'$$')
	AND
		NVL(tv_tf_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_tf_code,'$$')
	--AND
	--	NVL(tv_pricing_template ,0) = NVL(ip_cmud_data_tab(1).tv_pricing_template,0)
	AND
		NVL(tv_crp_code ,'$$') = 'REG'
	AND
		NVL(tv_msc_code ,'$$') = 'DEF'
	AND
		NVL(tv_chc_code ,'$$') = 'DEF'
	AND
		TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_FROM_DATE,g_date_format)) = trunc(tv_from_date);
  		
  		
	m_upd_rec  update_cur%rowtype;
	
	m_operation VARCHAR2(1):= null;

	BEGIN
	

		OPEN update_cur;
		FETCH update_cur INTO m_upd_rec;
		
		IF update_cur%FOUND then		
			m_operation := 'U';
		ELSE
			m_operation := 'I';
		END IF;
			
		IF update_cur%ISOPEN THEN CLOSE update_cur; END IF;
		
		return m_operation;
		
	EXCEPTION

	WHEN OTHERS THEN
		IF update_cur%ISOPEN THEN CLOSE update_cur; END IF;
		return null;

END check_std_mode;

/*-------------------------------------------------------------------------------------------------
Procedure    : check_std_duplication
Purpose      :									
/*-------------------------------------------------------------------------------------------------*/


PROCEDURE check_std_duplication(  ip_cmud_data_tab IN  std_def_tab ) AS


	CURSOR
		tv_up_cur IS
	SELECT
		tv_uid
	FROM
		TARIFF_VARIATION
	WHERE
		NVL(tv_tarif_band ,'$$') = NVL(ip_cmud_data_tab(1).TV_TARIF_BAND,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).TV_TCG_CODE,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		NVL(tv_qos_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_qos_code,'$$')
	AND
		NVL(tv_tf_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_tf_code,'$$')
	--AND
	--	NVL(tv_pricing_template ,0) = NVL(ip_cmud_data_tab(1).tv_pricing_template,0)
	AND
		NVL(tv_crp_code ,'$$') = 'REG'
	AND
		NVL(tv_msc_code ,'$$') = 'DEF'
	AND
		NVL(tv_chc_code ,'$$') = 'DEF'
	--AND
	--	NVL(tv_trans_currency,'$') = NVL(ip_cmud_data_tab(1).currency,'$$')
	AND
		tv_status IN ('A', 'N')
	AND ( 
       		(trunc(to_date(ip_cmud_data_tab(1).tv_from_date,g_date_format)) > tv_from_date AND 
       		 trunc(to_date(ip_cmud_data_tab(1).tv_from_date,g_date_format)) <= NVL (tv_to_date, stbms_std.high_date)
                 )
                 OR
                 --(trunc(to_date(NVL(ip_cmud_data_tab(1).tv_to_date,stbms_std.high_date),g_date_format)) > tv_from_date AND
                 (trunc(to_date(ip_cmud_data_tab(1).tv_from_date,g_date_format)) <> TRUNC(tv_from_date) AND
                 trunc(NVL(to_date(ip_cmud_data_tab(1).tv_to_date,g_date_format),stbms_std.high_date)) >= trunc(tv_from_date) AND 
                  --trunc(to_date(NVL(ip_cmud_data_tab(1).tv_to_date,stbms_std.high_date),g_date_format)) < NVL (tv_to_date, stbms_std.high_date)
                  trunc(NVL(to_date(ip_cmud_data_tab(1).tv_to_date,g_date_format),stbms_std.high_date)) <= trunc(NVL (tv_to_date, stbms_std.high_date))
                  )
                 OR
                 (trunc(to_date(ip_cmud_data_tab(1).tv_from_date,g_date_format)) < trunc(tv_from_date) AND
                 trunc(NVL(to_date(ip_cmud_data_tab(1).tv_to_date,g_date_format),stbms_std.high_date)) > trunc(NVL (tv_to_date, stbms_std.high_date))
                  )
             );             
  
  /*	AND
  		trunc(NVL(to_date(ip_cmud_data_tab(1).tv_to_date,g_date_format),stbms_std.high_date)) < trunc(NVL (tv_to_date, stbms_std.high_date))
  	AND
  		trunc(to_date(ip_cmud_data_tab(1).tv_from_date,g_date_format)) <> TRUNC(tv_from_date);
  		OR
  		(TRUNC(tv_to_date) IS NOT NULL AND 
  		trunc(to_date(ip_cmud_data_tab(1).tv_to_date,g_date_format)) <> TRUNC(tv_to_date)));*/
  		
  		
	
	m_tv_uid 		TARIFF_VARIATION.TV_UID%TYPE;

             
	BEGIN
	

	OPEN tv_up_cur;
	FETCH tv_up_cur INTO m_tv_uid;
	
	IF tv_up_cur%FOUND  THEN

		load_up_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,ip_cmud_data_tab(1).group_id,ip_cmud_data_tab(1).grp_seq_id,'V20016','Standard Price Defintion already exists with the given variation factors for the given period','V');

	end if;
	IF tv_up_cur%ISOPEN THEN CLOSE tv_up_cur; END IF;


	EXCEPTION

	--WHEN ORATERMINATE THEN
	--	RAISE ORATERMINATE;

	WHEN OTHERS THEN
		IF tv_up_cur%ISOPEN THEN CLOSE tv_up_cur; END IF;
		STBMS_ERR.DISP_ERR( 100032, SQLERRM || 'line <' || dbms_utility.format_error_backtrace || '>' );

END check_std_duplication;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_std_single_grp
 Purpose	: Record level Validation of Standard Upload
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_std_single_grp(ip_grp_id IN VARCHAR2,ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	std_det_cur IS
SELECT
	cmud_cmu_id,
	cmud_id,
	cmud_data_col1 	 group_id,
	cmud_data_col2 	 grp_seq_id,
	cmud_data_col3	 country,	     	 
	cmud_data_col4	 tv_tcg_code,		 
	nvl(cmud_data_col5,'-')	 tv_des,	 
	cmud_data_col6	 tv_tarif_band,		 	      
	cmud_data_col7	 gbt_des,		 	      
	cmud_data_col8	 tv_qos_code,	 
	cmud_data_col9	 tv_tf_code,	 
	cmud_data_col10	 tv_pricing_template,		 
	cmud_data_col11	 tv_tariff_class,		 
	cmud_data_col12	 tv_from_date,		 
	cmud_data_col13	 tv_to_date,	 
	cmud_data_col14	 tv_trans_currency,		 
	--cmud_data_col15	 ts_usage_data,		 
	cmud_data_col15	 tc_cum_type,		 
	cmud_data_col16	 tc_rate_type,		 
	cmud_data_col17	 tier_from,		 
	cmud_data_col18	 tier_to,		 	 
	cmud_data_col19	 rate,		 
	cmud_data_col20	 tcr_upper_limit,
	cmud_data_col21	,	 
	cmud_data_col22	,	 
	cmud_data_col23	,	 
	cmud_data_col24	,	 
	cmud_data_col25	,	 
	cmud_data_col26	,	         
	cmud_data_col27	,	 	 
	cmud_data_col28	,		 
	cmud_data_col29	,	 	 
	cmud_data_col30	,	 
	cmud_data_col31	,	
	cmud_data_col32	,
	cmud_data_col33	,
	cmud_data_col34	,
	cmud_data_col35	,
	cmud_data_col36	,
	cmud_data_col37	, 
	cmud_data_col38	,
	cmud_data_col39	,
	cmud_data_col40	,
	cmud_data_col41	,
	cmud_data_col42	,
	cmud_data_col43	,
	cmud_data_col44	,
	cmud_data_col45	,
	cmud_data_col46	,
	cmud_data_col47	,
	cmud_status status
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
AND 
	cmud_data_col1 = ip_grp_id
ORDER BY
	to_number(cmud_data_col2);
	
TYPE std_arr IS TABLE OF std_det_cur%ROWTYPE INDEX BY BINARY_INTEGER;

m_std_tab 	std_def_tab;
m_err_flag 	BOOLEAN := FALSE;
m_indx 		NUMBER := 0;
m_Tier_From	 VARCHAR2(25);
m_Tier_To	 VARCHAR2(25);
m_operation VARCHAR2(1):= null;

BEGIN	

	g_err_tab.DELETE;
	g_cmud_id_tab_type.DELETE;
	g_grp_seq_tab_type.DELETE;
	
	OPEN std_det_cur;
	LOOP
	
		m_std_tab.DELETE;		
		
		FETCH std_det_cur BULK COLLECT INTO m_std_tab LIMIT 500;	
	
		EXIT WHEN m_std_tab.COUNT = 0;
		

		FOR i IN 1 .. m_std_tab.COUNT LOOP
		

			m_Tier_From := TRIM(UPPER(m_std_tab(i).tier_from));
			m_Tier_To   := TRIM(UPPER(m_std_tab(i).tier_to));
			
			m_indx := g_cmud_id_tab_type.COUNT + 1;
			
			g_cmud_id_tab_type(m_indx) := m_std_tab(i).cmud_id;
			
			IF m_std_tab(i).grp_seq_id <> TO_CHAR(i-1) THEN														
				load_up_err(ip_xl_id,m_std_tab(i).cmud_id,m_std_tab(i).group_id,m_std_tab(i).grp_seq_id,'V20001','Sequence Number for a group must be continuous sequence starting from 0','V');
			END IF;
			
			/*IF i > 1 THEN
				std_subrec_data_validation( m_std_tab(1), m_std_tab(m_indx) );
			END IF;
			*/

			IF m_Tier_From = 'MIN' THEN
				m_Tier_From := '0';			
			END IF;

			IF m_Tier_To = 'MAX' THEN
				m_Tier_To := '999999999999999';
			END IF;			

			IF i<> m_std_tab.COUNT THEN
				IF (m_std_tab(i).tier_to <> m_std_tab(i+1).tier_from)THEN
					--load_err(m_std_tab(1).cmud_cmu_id,m_std_tab(i+1).cmud_id,m_std_tab(i).grp_seq_id,'V20015','Missing/Overlapping Tier Range','V');
					load_up_err(m_std_tab(1).cmud_cmu_id,m_std_tab(i+1).cmud_id,m_std_tab(i+1).group_id,m_std_tab(i+1).grp_seq_id,'V20015','Tier-From of Tier Group '||i+1||'should be same as Tier-To of Tier Group '||i,'V');
				END IF;
			END IF;

			validate_std_tier(m_Tier_From,m_std_tab,m_indx);

			validate_std_tier(m_Tier_To,m_std_tab,m_indx);

			--Data Level Validation
			IF (i = 1) THEN
				validate_standard_record(m_std_tab(i));
				duplicate_check_sequence(m_std_tab(i));
				--m_operation := check_std_mode(m_std_tab);
				check_std_duplication(m_std_tab);
			END IF;
			
			
		END LOOP;
	END LOOP;
	
	m_err_flag := FALSE;
	
	IF g_err_tab.COUNT > 0 THEN
	
		m_err_flag := TRUE;				
		
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
	
	END IF;	

	IF m_err_flag THEN
	
		g_err_tab.DELETE;
		check_group_err(ip_xl_id,ip_grp_id,'V');
		
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
		
		UPDATE 
			CSTM_MEGA_UPLOAD_DET
		SET
			CMUD_STATUS = 'E',
			CMUD_ERROR_TYPE = 'V'
		WHERE
			CMUD_CMU_ID = ip_xl_id
		AND
			CMUD_DATA_COL1 = ip_grp_id;	
			
	END IF;	
	
	COMMIT;

	IF std_det_cur%ISOPEN THEN CLOSE std_det_cur; END IF; 	
	
EXCEPTION
	WHEN OTHERS THEN
		IF std_det_cur%ISOPEN THEN CLOSE std_det_cur; END IF; 
		Stbms_Err.disp_err (100075,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );
		
END validate_std_single_grp;	

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_standard 
 Purpose	: File Level Validation of Standard Upload
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_standard(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	det_grp_id_cur IS
SELECT
	DISTINCT CMUD_DATA_COL1 grp_id
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
ORDER BY
	to_number(grp_id);
	
TYPE det_grp_id_arr IS TABLE OF det_grp_id_cur%ROWTYPE INDEX BY binary_integer;

m_det_grp_id_tab det_grp_id_arr;
	
	
BEGIN	

	OPEN det_grp_id_cur;	
	LOOP
		m_det_grp_id_tab.DELETE;
		FETCH det_grp_id_cur BULK COLLECT INTO m_det_grp_id_tab LIMIT g_rows;
		EXIT WHEN m_det_grp_id_tab.COUNT = 0;
		
		FOR i IN 1..m_det_grp_id_tab.COUNT LOOP		
		
			validate_std_single_grp(m_det_grp_id_tab(i).grp_id,ip_xl_id,ip_template_id);		
		END LOOP;	
	END LOOP;	
	IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;	
EXCEPTION
	WHEN OTHERS THEN
		IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;
		Stbms_Err.disp_err (100076,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END validate_standard;


/*-------------------------------------------------------------------------------------------------
 Procedure 	: subrec_data_validation 
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE neg_subrec_data_validation(ip_first_cmud_data_tab IN neg_def_rec, ip_cmud_data_tab IN neg_def_rec) AS
BEGIN
	IF	ip_first_cmud_data_tab.country 		<> ip_cmud_data_tab.country OR  
		ip_first_cmud_data_tab.tv_tcg_code 	<> ip_cmud_data_tab.tv_tcg_code OR  
		ip_first_cmud_data_tab.cust_no 		<> ip_cmud_data_tab.cust_no OR
		ip_first_cmud_data_tab.tv_tarif_band 	<> ip_cmud_data_tab.tv_tarif_band OR
		ip_first_cmud_data_tab.gbt_des 		<> ip_cmud_data_tab.gbt_des OR 
		ip_first_cmud_data_tab.tc_rate_type 	<> ip_cmud_data_tab.tc_rate_type OR
		ip_first_cmud_data_tab.tv_pricing_template <> ip_cmud_data_tab.tv_pricing_template OR
		ip_first_cmud_data_tab.ts_des  		<> ip_cmud_data_tab.ts_des  OR
		ip_first_cmud_data_tab.tv_tariff_class 	<> ip_cmud_data_tab.tv_tariff_class OR
		ip_first_cmud_data_tab.tv_qos_code 	<> ip_cmud_data_tab.tv_qos_code OR
		ip_first_cmud_data_tab.tv_trans_currency <> ip_cmud_data_tab.tv_trans_currency OR
		ip_first_cmud_data_tab.stv_from_date 	<> ip_cmud_data_tab.stv_from_date OR
		ip_first_cmud_data_tab.stv_to_date 	<> ip_cmud_data_tab.stv_to_date OR
		ip_first_cmud_data_tab.cmud_data_col19 	<> ip_cmud_data_tab.cmud_data_col19 OR
		ip_first_cmud_data_tab.cmud_data_col20 	<> ip_cmud_data_tab.cmud_data_col20 OR
		ip_first_cmud_data_tab.cmud_data_col21 	<> ip_cmud_data_tab.cmud_data_col21 OR
		ip_first_cmud_data_tab.cmud_data_col22 	<> ip_cmud_data_tab.cmud_data_col22 OR
		ip_first_cmud_data_tab.cmud_data_col23 	<> ip_cmud_data_tab.cmud_data_col23 OR
		ip_first_cmud_data_tab.cmud_data_col24 	<> ip_cmud_data_tab.cmud_data_col24 OR
		ip_first_cmud_data_tab.cmud_data_col25 	<> ip_cmud_data_tab.cmud_data_col25 OR
		ip_first_cmud_data_tab.cmud_data_col26 	<> ip_cmud_data_tab.cmud_data_col26 OR
		ip_first_cmud_data_tab.cmud_data_col27 	<> ip_cmud_data_tab.cmud_data_col27 OR
		ip_first_cmud_data_tab.cmud_data_col28 	<> ip_cmud_data_tab.cmud_data_col28 OR
		ip_first_cmud_data_tab.cmud_data_col29 	<> ip_cmud_data_tab.cmud_data_col29 OR
		ip_first_cmud_data_tab.cmud_data_col30 	<> ip_cmud_data_tab.cmud_data_col30 OR
		ip_first_cmud_data_tab.cmud_data_col31 	<> ip_cmud_data_tab.cmud_data_col31 OR
		ip_first_cmud_data_tab.cmud_data_col32 	<> ip_cmud_data_tab.cmud_data_col32 OR
		ip_first_cmud_data_tab.cmud_data_col33 	<> ip_cmud_data_tab.cmud_data_col33 OR
		ip_first_cmud_data_tab.cmud_data_col34 	<> ip_cmud_data_tab.cmud_data_col34 OR
		ip_first_cmud_data_tab.cmud_data_col35 	<> ip_cmud_data_tab.cmud_data_col35 OR
		ip_first_cmud_data_tab.cmud_data_col36 	<> ip_cmud_data_tab.cmud_data_col36 OR
		ip_first_cmud_data_tab.cmud_data_col37 	<> ip_cmud_data_tab.cmud_data_col37 OR
		ip_first_cmud_data_tab.cmud_data_col38 	<> ip_cmud_data_tab.cmud_data_col38 OR
		ip_first_cmud_data_tab.cmud_data_col39 	<> ip_cmud_data_tab.cmud_data_col39 OR
		ip_first_cmud_data_tab.cmud_data_col40 	<> ip_cmud_data_tab.cmud_data_col40 OR
		ip_first_cmud_data_tab.cmud_data_col41 	<> ip_cmud_data_tab.cmud_data_col41 OR
		ip_first_cmud_data_tab.cmud_data_col42 	<> ip_cmud_data_tab.cmud_data_col42 OR
		ip_first_cmud_data_tab.cmud_data_col43	<> ip_cmud_data_tab.cmud_data_col43 OR
		ip_first_cmud_data_tab.cmud_data_col44 	<> ip_cmud_data_tab.cmud_data_col44 OR
		ip_first_cmud_data_tab.cmud_data_col45 	<> ip_cmud_data_tab.cmud_data_col45 OR
		ip_first_cmud_data_tab.cmud_data_col46 	<> ip_cmud_data_tab.cmud_data_col46 OR
		ip_first_cmud_data_tab.cmud_data_col47 	<> ip_cmud_data_tab.cmud_data_col47 THEN

		load_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,'V30002','In case of tiered rate exception definition, all records should have same values for all fields except Tier From, Tier To, Rate','V');
	END IF;	
EXCEPTION 	
	WHEN OTHERS THEN
		 stbms_err.disp_err( 100016, SQLERRM );
END neg_subrec_data_validation;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_neg_tier
 Purpose	:
-------------------------------------------------------------------------------------------------*/
PROCEDURE validate_neg_tier( ip_tier IN VARCHAR2,
			     ip_cmud_cmu_id IN VARCHAR2 ,
			     ip_cmud_id IN VARCHAR2,
			     ip_group_id IN VARCHAR2,
			     ip_seq_id IN VARCHAR2) IS
	
	m_num		NUMBER(28,8);
	m_prec		VARCHAR2(100);
	m_temp		VARCHAR2(500);
	m_Tier		 VARCHAR2(25);
	/*
	CURSOR tier_prec_cur(m_num IN NUMBER) IS
		SELECT   TO_NUMBER (SUBSTR (m_num, INSTR (m_num, '.', 1, 1) + 1)) tier_prec_part  FROM   DUAL;
		*/
BEGIN
	
	m_Tier := TRIM(UPPER(ip_tier));
	IF m_Tier = 'MIN' THEN
		m_temp := '0';			
	ELSIF m_Tier = 'MAX' THEN	
	 	m_temp := '999999999999999';
	ELSE	
		m_temp := m_Tier;
	END IF;
					
	BEGIN
		m_num := to_number(m_temp);
	EXCEPTION
		WHEN OTHERS THEN
		
		load_up_err(ip_cmud_cmu_id,ip_cmud_id,ip_group_id,ip_seq_id,'V30003','Special/Non Numeric Characters Not Expected for Tier','V');
	END;	
	
	/*IF m_temp <0 THEN	
		load_err(ip_cmud_cmu_id,ip_cmud_id,'V30004','Negative values not Expected for Tier','V');	
	END IF;	*/
	
	/*
	OPEN tier_prec_cur(m_num);	
	FETCH tier_prec_cur INTO m_prec;	
	IF tier_prec_cur%ISOPEN THEN CLOSE tier_prec_cur; END IF;
		
	IF m_prec <> m_num AND length(m_prec) > 5 THEN
		load_err(ip_cmud_cmu_id,ip_cmud_id,'V30005','Precision exceeded for tier.Maximum precision 5.','V');
	END IF;
	*/
	
	
EXCEPTION
	--WHEN ORATERMINATE THEN
	--	RAISE ORATERMINATE;
	WHEN OTHERS THEN
		--IF tier_prec_cur%ISOPEN THEN CLOSE tier_prec_cur; END IF;
		stbms_err.disp_err( 100022, SQLERRM );
		
END validate_neg_tier;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: check_neg_sequence_duplication -- PMS 58712
 Purpose	: For checking the records in same group
-------------------------------------------------------------------------------------------------*/

PROCEDURE check_neg_sequence_duplication(ip_Fun_Grp_Id IN VARCHAR2 ,ip_Fun_Grp_seq IN VARCHAR2,ip_xl_id IN NUMBER ,ip_cmud_id IN NUMBER) AS

Cursor dup_cur(ip_Fun_Grp_Id IN VARCHAR,ip_xl_id IN NUMBER) IS
	SELECT 
		cmud_data_col2,count(*) seq_count
	FROM 
		cstm_mega_upload_det
	WHERE 
		cmud_data_col1 = ip_Fun_Grp_Id      
	AND 
		cmud_cmu_id  = ip_xl_id
	GROUP BY 
		cmud_data_col2
	having 
		count(*) >1;
    	
 dup_rec dup_cur%ROWTYPE;
 
 m_flag	BOOLEAN	:= TRUE;
	
BEGIN
	OPEN dup_cur(ip_Fun_Grp_Id,ip_xl_id);		
	
		FETCH dup_cur INTO dup_rec;			
		IF dup_cur%FOUND THEN		

		    load_up_err(ip_xl_id,ip_cmud_id,ip_Fun_Grp_Id,ip_Fun_Grp_seq,'V30005','Duplicate Sequence Number -'||dup_rec.cmud_data_col2,'V');

			IF dup_cur%ISOPEN THEN CLOSE dup_cur; END IF;
			
		END IF;
		
		IF dup_cur%ISOPEN THEN CLOSE dup_cur; END IF;	
	
EXCEPTION
	WHEN OTHERS THEN		
		stbms_err.disp_err( 100017, SQLERRM );
END check_neg_sequence_duplication;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: validate_neg_record 
 Purpose	: For data level validation of exception records
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_neg_record(ip_cmud_data_tab IN neg_def_rec) IS

m_from_date     DATE;

CURSOR cust_cur (ip_cust_id IN VARCHAR2) IS
	select cm_cust_no from customer_master where cm_cust_id= ip_cust_id and	cm_status='A';

--CURSOR act_cur (ip_act_id) IS
--	select pm_phone_no from	subscriber_master where	pm_phone_no= ip_act_id	and pm_status='A';	

CURSOR tcg_cur IS
	select tcg_code from tariff_call_group WHERE tcg_code = ip_cmud_data_tab.tv_tcg_code;
		
CURSOR term_code_cur IS
	SELECT bdd_bd_code FROM f_bill_det_des WHERE bdd_bd_code = ip_cmud_data_tab.tv_tarif_band;

CURSOR meth_cur IS
	SELECT ts_ts_code FROM tariff_scheme WHERE ts_pricing_template = ip_cmud_data_tab.tv_pricing_template and ts_template_type is null;
	
CURSOR currency_cur IS
	SELECT cur_code FROM currency_codes WHERE cur_code = ip_cmud_data_tab.tv_trans_currency;

CURSOR qos_cur IS
	SELECT qos_code FROM quality_of_service WHERE qos_code = ip_cmud_data_tab.tv_qos_code;

--CURSOR tf_cur IS
--	select  tuf_user_field_code from  tariff_user_fields where tuf_ind='E' and tuf_user_field_code = ip_cmud_data_tab.qualifier_id;

--PMS 63141
cursor cm_cur (ip_cust_id IN VARCHAR2)is select cm_cust_no
	from customer_master
	where cm_cust_id=ip_cust_id and
	m_from_date between TRUNC(CM_OPEN_DATE) AND NVL(TRUNC(CM_CLOSING_DATE), Stbms_Std.high_date);


m_tcg 		tariff_call_group.tcg_code%type;
m_term_code 	f_bill_det_des.bdd_bd_code%type;
m_meth 		tariff_scheme.ts_ts_code%type;
m_cur_code	currency_codes.cur_code%type;
m_qos		quality_of_service.qos_code%type;
--m_tf_code	tariff_user_fields.tuf_user_field_code%type;
m_cust		customer_master.cm_cust_no%type;
--m_act		subscriber_master.pm_phone_no%type;
		
BEGIN

	--Validate PriceList
	IF(ip_cmud_data_tab.tv_tcg_code IS NOT NULL) THEN
	
		OPEN tcg_cur;
		
		FETCH tcg_cur INTO m_tcg;

		IF tcg_cur%NOTFOUND THEN	   

			load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30006','Invalid Price List','V');

			IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;					  	

		END IF;

		IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;	
	END IF;

	--Validate TermCode
	
	OPEN term_code_cur;
	
	FETCH term_code_cur INTO m_term_code;

	IF term_code_cur%NOTFOUND THEN	   

		load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30007','Invalid Term Code','V');

		IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;					  	

	END IF;

	IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;	
	
	--Validate Methododlogy
	
	OPEN meth_cur;	
	
	FETCH meth_cur INTO m_term_code;

	IF meth_cur%NOTFOUND THEN	   

		load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30008','Invalid Methodology','V');

		IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;					  	

	END IF;

	IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;	
	
	--Validate Currency
	IF ip_cmud_data_tab.tv_trans_currency IS NOT NULL THEN
		OPEN currency_cur;
		
		FETCH currency_cur INTO m_cur_code;

		IF currency_cur%NOTFOUND THEN	   

			load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30009','Invalid Currency','V');

			IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;					  	

		END IF;
	END IF;

	IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;	

	--Validate QOS
	IF ip_cmud_data_tab.tv_qos_code IS NOT NULL THEN

		OPEN qos_cur;	
		
		FETCH qos_cur INTO m_qos;

		IF qos_cur%NOTFOUND THEN	   

			load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30010','Invalid Function Code','V');

			IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;					  	

		END IF;
	END IF;

	IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;
	
	--Validate tf_code
	/*
	OPEN tf_cur;	

	FETCH tf_cur INTO m_tf_code;

	IF tf_cur%NOTFOUND THEN	   

		load_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,'V30011','Invalid ChannelCode/Qualifier ID','V');

		IF tf_cur%ISOPEN THEN CLOSE tf_cur; END IF;					  	

	END IF;

	IF tf_cur%ISOPEN THEN CLOSE tf_cur; END IF;
	*/
	
	
	open cust_cur(ip_cmud_data_tab.cust_no);
	fetch cust_cur into m_cust;
	
	IF cust_cur%NOTFOUND THEN
		load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30013','Invalid Client ID','V');
		IF cust_cur%ISOPEN THEN CLOSE cust_cur; END IF;	
	END IF;
	IF cust_cur%ISOPEN THEN CLOSE cust_cur; END IF;		
	
	m_from_date := TRUNC(TO_DATE(ip_cmud_data_tab.STV_FROM_DATE,g_date_format));
	
	open cm_cur(ip_cmud_data_tab.cust_no);
	fetch cm_cur into m_cust;
	
	IF cm_cur%NOTFOUND THEN
		load_up_err(ip_cmud_data_tab.cmud_cmu_id,ip_cmud_data_tab.cmud_id,ip_cmud_data_tab.group_id,ip_cmud_data_tab.grp_seq_id,'V30016','Customer is not active for the period','V');
		IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF;	
	END IF;
	IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF;		

EXCEPTION
	WHEN OTHERS THEN		
		IF tcg_cur%ISOPEN THEN CLOSE tcg_cur; END IF;					  	
		IF term_code_cur%ISOPEN THEN CLOSE term_code_cur; END IF;					  	
		IF meth_cur%ISOPEN THEN CLOSE meth_cur; END IF;					  	
		IF currency_cur%ISOPEN THEN CLOSE currency_cur; END IF;					  	
		IF qos_cur%ISOPEN THEN CLOSE qos_cur; END IF;
		--IF tf_cur%ISOPEN THEN CLOSE tf_cur; END IF;					  	
		IF cust_cur%ISOPEN THEN CLOSE cust_cur; END IF;		
		--IF act_cur%ISOPEN THEN CLOSE act_cur; END IF;		
		IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF;		
		stbms_err.disp_err( 100021, SQLERRM );
END validate_neg_record;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_neg_single_grp --PMS 58712
 Purpose	: 
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_neg_single_grp(ip_grp_id IN VARCHAR2,ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	ng_det_cur IS
SELECT
	cmud_cmu_id,
	cmud_id,
	cmud_data_col1 fun_grp_id,
	cmud_data_col2 fun_grp_seq,
	cmud_data_col3 country,
	cmud_data_col4 tv_tcg_code,
	cmud_data_col5 cust_no,
	cmud_data_col6 TV_TARIF_BAND,
	cmud_data_col7 gbt_des,
	cmud_data_col8 tc_rate_type,
	cmud_data_col9 tier_from,	
	cmud_data_col10 tier_to,
	cmud_data_col11 rate,
	cmud_data_col12	tv_pricing_template,
	cmud_data_col13	ts_des ,
	cmud_data_col14	tv_tariff_class,
	cmud_data_col15	tv_qos_code,
	cmud_data_col16 tv_trans_currency,
	cmud_data_col17 stv_from_date,
	cmud_data_col18 stv_to_date,
	cmud_data_col19 ,
	cmud_data_col20 ,
	cmud_data_col21 ,
	cmud_data_col22 ,
	cmud_data_col23 ,
	cmud_data_col24 ,
	cmud_data_col25 ,
	cmud_data_col26 ,
	cmud_data_col27 ,
	cmud_data_col28 ,
	cmud_data_col29 ,
	cmud_data_col30 ,
	cmud_data_col31	,	
	cmud_data_col32	,
	cmud_data_col33	,
	cmud_data_col34	,
	cmud_data_col35	,
	cmud_data_col36	,
	cmud_data_col37	, 
	cmud_data_col38	,
	cmud_data_col39	,
	cmud_data_col40	,
	cmud_data_col41	,
	cmud_data_col42	,
	cmud_data_col43	,
	cmud_data_col44	,
	cmud_data_col45	,
	cmud_data_col46 ,
	cmud_data_col47 ,
	CMUD_STATUS status
FROM
	CSTM_MEGA_UPLOAD_DET
WHERE
	CMUD_CMU_ID = ip_xl_id
AND
	cmud_data_col1 = ip_grp_id
ORDER BY
	TO_NUMBER(cmud_data_col2);

CURSOR
	count_cur IS
SELECT
	count(*) as COUNT
FROM
	CSTM_MEGA_UPLOAD_DET
WHERE
	CMUD_CMU_ID = ip_xl_id
AND
	cmud_data_col1 = ip_grp_id
Group By
	cmud_data_col2 ,
	cmud_data_col3 ,
	cmud_data_col4 ,
	cmud_data_col5 ,
	cmud_data_col6 ,
	cmud_data_col7 ,
	cmud_data_col8 ,
	cmud_data_col9 ,	
	cmud_data_col10 ,
	cmud_data_col11 ,
	cmud_data_col12	,
	cmud_data_col13	 ,
	cmud_data_col14	,
	cmud_data_col15	,
	cmud_data_col16 ,
	cmud_data_col17 ,
	cmud_data_col18 ,
	cmud_data_col19 ,
	cmud_data_col20 ,
	cmud_data_col21 ,
	cmud_data_col22 ,
	cmud_data_col23 ,
	cmud_data_col24 ,
	cmud_data_col25 ,
	cmud_data_col26 ,
	cmud_data_col27 ,
	cmud_data_col28 ,
	cmud_data_col29 ,
	cmud_data_col30 ,
	cmud_data_col31	,	
	cmud_data_col32	,
	cmud_data_col33	,
	cmud_data_col34	,
	cmud_data_col35	,
	cmud_data_col36	,
	cmud_data_col37	, 
	cmud_data_col38	,
	cmud_data_col39	,
	cmud_data_col40	,
	cmud_data_col41	,
	cmud_data_col42	,
	cmud_data_col43	,
	cmud_data_col44	,
	cmud_data_col45	,
	cmud_data_col46 ,
	cmud_data_col47 ;
	
m_err_flag BOOLEAN := FALSE;
m_indx NUMBER := 0;
m_cmud_rec	 		neg_def_tab;
m_neg_det_tab 			neg_def_tab;
m_staff_id			cstm_mega_upload.cmu_checker_staff_id%type;
m_off_code			staff_profile.sp_off_code%type;			   	
m_count NUMBER := 0;
BEGIN

	g_err_tab.DELETE;
	g_cmud_id_tab_type.DELETE;
	g_grp_seq_tab_type.DELETE;
	
		OPEN ng_det_cur;
		LOOP
			m_neg_det_tab.DELETE;	
			FETCH ng_det_cur BULK COLLECT INTO m_neg_det_tab LIMIT g_rows;
			EXIT WHEN m_neg_det_tab.COUNT = 0;
			
			FOR i IN 1 .. m_neg_det_tab.COUNT LOOP
				m_indx := g_cmud_id_tab_type.COUNT + 1;
				
				g_cmud_id_tab_type(m_indx) := m_neg_det_tab(i).cmud_id;	

				IF m_neg_det_tab(i).grp_seq_id <> TO_CHAR(i-1) THEN														
					load_up_err(ip_xl_id,m_neg_det_tab(i).cmud_id,m_neg_det_tab(i).group_id,m_neg_det_tab(i).grp_seq_id,'V30001','Sequence Number for a group must be continuous sequence starting from 0','V');
				END IF;

				/*IF i > 1 THEN
					neg_subrec_data_validation( m_neg_det_tab(1), m_neg_det_tab(m_indx) );
				END IF;
				*/
				
				validate_neg_tier( m_neg_det_tab(i).Tier_From ,m_neg_det_tab(i).cmud_cmu_id ,m_neg_det_tab(i).cmud_id, m_neg_det_tab(i).group_id,m_neg_det_tab(i).grp_seq_id);
				validate_neg_tier( m_neg_det_tab(i).Tier_To ,m_neg_det_tab(i).cmud_cmu_id ,m_neg_det_tab(i).cmud_id,m_neg_det_tab(i).group_id,m_neg_det_tab(i).grp_seq_id );
				
				if (i = 1) THEN
				
					check_neg_sequence_duplication(m_neg_det_tab(i).group_id	,
									m_neg_det_tab(i).grp_seq_id    ,
									m_neg_det_tab(i).CMUD_CMU_ID	,
									m_neg_det_tab(i).CMUD_ID	);

					validate_neg_record(m_neg_det_tab(i));
				END IF;
				

				IF i <> m_neg_det_tab.COUNT THEN
			       		IF (m_neg_det_tab(i).Tier_To <> m_neg_det_tab(i+1).Tier_From) THEN
						--load_up_err(m_neg_det_tab(1).cmud_cmu_id,m_neg_det_tab(i+1).cmud_id,m_neg_det_tab(i+1).fun_grp_id,m_neg_det_tab(i+1).fun_grp_seq,'V30014','Missing/Overlapping Tier Range','V');
						load_up_err(m_neg_det_tab(1).cmud_cmu_id,m_neg_det_tab(i+1).cmud_id,m_neg_det_tab(i+1).group_id,m_neg_det_tab(i+1).grp_seq_id,'V30014','Tier-From of Tier Group '||i+1||'should be same as Tier-To of Tier Group '||i,'V');
						
			     		END IF;
			     	END IF;

				
				/*IF m_neg_det_tab(i).status = 'E' THEN
					m_err_flag := TRUE;
				END IF;*/
				
				m_cmud_rec := m_neg_det_tab;
				
			END LOOP;
		END LOOP;
		IF ng_det_cur%ISOPEN THEN CLOSE ng_det_cur; END IF;
		
	m_err_flag := FALSE;		
	IF g_err_tab.COUNT > 0 THEN	
		m_err_flag := TRUE;				
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
			
		UPDATE 
			CSTM_MEGA_UPLOAD_DET
		SET
			CMUD_STATUS = 'E',
			CMUD_ERROR_TYPE = 'V'
		WHERE
			CMUD_CMU_ID = ip_xl_id
		AND
			--CMUD_ID = ip_grp_id;	
			cmud_data_col1 = ip_grp_id;	
		commit;
	END IF;	
	

	IF m_err_flag THEN
	
		g_err_tab.DELETE;
		check_group_err(ip_xl_id,ip_grp_id,'V');
		
		FORALL i IN 1 .. g_err_tab.COUNT
			INSERT INTO CSTM_MEGA_UPLOAD_ERROR_MSG VALUES g_err_tab(i);
	
	END IF;		
	COMMIT;

	IF ng_det_cur%ISOPEN THEN CLOSE ng_det_cur; END IF;
	
EXCEPTION
	WHEN OTHERS THEN
		IF ng_det_cur%ISOPEN THEN CLOSE ng_det_cur; END IF;
		Stbms_Err.disp_err (100001,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END validate_neg_single_grp;
/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_neg_data -- PMS 58712
 Purpose	: File Level Validation 
-------------------------------------------------------------------------------------------------*/

PROCEDURE validate_neg_data(ip_xl_id IN VARCHAR2, ip_template_id IN VARCHAR2) IS

CURSOR
	det_grp_id_cur IS
SELECT
	DISTINCT cmud_data_col1 grp_id 
FROM
	CSTM_MEGA_UPLOAD_DET
WHERE
	CMUD_CMU_ID = ip_xl_id
ORDER BY
	to_number(grp_id);
	
TYPE det_grp_id_arr IS TABLE OF det_grp_id_cur%ROWTYPE INDEX BY BINARY_INTEGER;

m_det_grp_id_tab det_grp_id_arr;
	
BEGIN	

	OPEN det_grp_id_cur;	
	LOOP
		m_det_grp_id_tab.DELETE;
		FETCH det_grp_id_cur BULK COLLECT INTO m_det_grp_id_tab LIMIT g_rows;
		EXIT WHEN m_det_grp_id_tab.COUNT = 0;
		
		FOR i IN 1..m_det_grp_id_tab.COUNT LOOP	
		
			validate_neg_single_grp(m_det_grp_id_tab(i).grp_id,ip_xl_id,ip_template_id);		
		END LOOP;	
	END LOOP;	
	IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;	
EXCEPTION
	WHEN OTHERS THEN
		IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;
		Stbms_Err.disp_err (100020,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END validate_neg_data;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: duplicate_check  
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/

PROCEDURE duplicate_check(ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS


/*CURSOR duplicate_cur IS	
	 select *  from
	    (select    cmud_id,
	    cmud_cmu_id,
	    cmud_data_col3,
	    nvl(cmud_data_col4,'$$') cmud_data_col4,                   
	    cmud_data_col6,
	    row_number() over (partition by   cmud_data_col3||  nvl(cmud_data_col4,'$$')||cmud_data_col6     
	    order by  cmud_data_col3||  nvl(cmud_data_col4,'$$')||cmud_data_col6 ) as duplicate_rec
	    from      cstm_mega_upload_det where cmud_cmu_id = ip_priority_def_tab(ip_index).CMUD_CMU_ID ) dup_tab
	    where     duplicate_rec > 1  and cmud_cmu_id = ip_priority_def_tab(ip_index).CMUD_CMU_ID;   */  
	    
CURSOR duplicate_cur IS
	select * from 
		AMEX_TERM_PRIORITY_MAPPING
	where
		ATPM_OFF_CODE = ip_priority_def_tab(ip_index).Market
	and
		nvl(ATPM_CUST_ID,'$$') = nvl(ip_priority_def_tab(ip_index).Division,'$$')  
	and
		ATPM_TERM_CODE = ip_priority_def_tab(ip_index).Term_Code;

duplicate_rec		duplicate_cur%ROWTYPE;
		
BEGIN		
		
	OPEN duplicate_cur;	

	FETCH duplicate_cur INTO duplicate_rec;

	IF duplicate_cur%FOUND THEN	

		load_err(ip_priority_def_tab(ip_index).cmud_cmu_id,ip_priority_def_tab(ip_index).cmud_id,'P10005','Duplicate Record','P');

	END IF;

	IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;     
			
EXCEPTION 	
	WHEN OTHERS THEN
		 IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;	
	 stbms_err.disp_err( 100080, SQLERRM );
END duplicate_check;  


/*-------------------------------------------------------------------------------------------------
	Procedure    : clearTariff
	Purpose      :
*-------------------------------------------------------------------------------------------------*/
	
PROCEDURE clearTariff AS

BEGIN

	tariff_call_scheme_array.DELETE;
	
	subs_tariff_var_obj 		 := subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	subs_tariff_var  		 := subs_tariff_var_api_obj_array(subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)) ;--dc
	tariff_var_obj 			 := tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_variation_array   	 := tariff_variation_api_obj_array(tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC
	tariff_call_rates_obj		 := call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_call_rates_array		 := call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC

	tariff_call_scheme_obj		 := call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)));--DC
	tariff_call_scheme_array	 := call_scheme_api_obj_array(call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null));--DC

	charge_code_user_attr		 := ccua_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*
	subs_tariff_var_obj 		:= subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	subs_tariff_var  		 := subs_tariff_var_api_obj_array(subs_tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)) ;--DC
	tariff_var_obj 			 := tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_call_rates_obj		:= call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	tariff_call_rates_array		:= call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC

	tariff_call_scheme_obj		:= call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,call_rates_api_obj_array(call_rates_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)));--DC
	tariff_call_scheme_array	:= call_scheme_api_obj_array(call_scheme_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));
	ccua_api_obj			:= ccua_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
*/
EXCEPTION
	WHEN OTHERS THEN
	STBMS_ERR.DISP_ERR( 100012, SQLERRM );
	
END clearTariff;

/*-------------------------------------------------------------------------------------------------
Procedure    : check_neg_duplication
Purpose      :									
/*-------------------------------------------------------------------------------------------------*/
/*

PROCEDURE check_neg_duplication(  ip_cmud_data_tab IN  neg_def_tab ) AS


	CURSOR
		tv_up_cur IS
	SELECT
		stv_rec_id
	FROM
		SUBS_TARIFF_VARIATION
	WHERE
		NVL(stv_status,'N') <> 'C'
	AND
		NVL (stv_subs_act_no, -1) = NVL (m_cust_no,NVL (stv_subs_act_no, -1))
    	AND 	
    		NVL (stv_cust_no, -1) = NVL (m_subs_no,NVL (stv_cust_no, -1))
	AND	
		NVL(stv_tg_id ,'$$') = NVL(ip_cmud_data_tab(1).stv_tg_id,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).tv_tcg_code,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		NVL(tv_qos_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_qos_code,'$$')
	AND
		NVL(tv_crp_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_crp_code,'$$')
	AND
		NVL(tv_msc_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_msc_code,'$$')
	AND
		NVL(tv_chc_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_chc_code,'$$')
	AND
		NVL(tv_trans_currency,'$') = NVL(ip_cmud_data_tab(1).tv_trans_currency,'$$')
	AND
		tv_status IN ('A', 'N')
        AND ( 
       		(ip_cmud_data_tab(1).from_date > tv_from_date AND 
       		 ip_cmud_data_tab(1).from_date <= NVL (tv_to_date, stbms_std.high_date)
                 )
                 OR
                 (NVL (ip_cmud_data_tab(1).to_date,stbms_std.high_date) >= tv_from_date AND 
                  NVL (ip_cmud_data_tab(1).to_date,stbms_std.high_date) <= NVL (tv_to_date, stbms_std.high_date)
                  )
                 OR
                 (ip_cmud_data_tab(1).from_date <= tv_from_date AND
                 NVL (ip_cmud_data_tab(1).to_date,stbms_std.high_date) >= NVL (tv_to_date, stbms_std.high_date)
                  )
             );
	
	CURSOR cust_cur IS
	select
		cm_cust_no
	from
		customer_master
	where
		cm_cust_id = ip_cmud_data_tab(1).cust_no;

	CURSOR act_cur IS
	select
		pm_subs_act_no
	from
		subscriber_master
	where
		pm_phone_no = ip_cmud_data_tab(1).cust_no;
			
	m_tv_uid 		TARIFF_VARIATION.TV_UID%TYPE;
	m_cust_no 		customer_master.cm_cust_no%TYPE := null;
	m_subs_no 		subscriber_master.pm_subs_act_no%TYPE := null;

	BEGIN
	
	IF(ip_cmud_data_tab(1).defn_type == 'Client') then
		open cust_cur;
		fetch cust_cur into m_cust_no;
		IF cust_cur%ISOPEN THEN CLOSE cust_cur; END IF;
	ELSE
		open act_cur;
		fetch act_cur into m_subs_no;
		IF act_cur%ISOPEN THEN CLOSE act_cur; END IF;
		
		
	
	IF ip_cmud_data_tab(1).change_ind != 'UPD' THEN

		OPEN tv_up_cur;

		FETCH tv_up_cur INTO m_tv_uid;

		IF tv_up_cur%FOUND  THEN

			load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P20007','Standard Price Defintion already exists with the given variation factors');

			IF tv_up_cur%ISOPEN THEN CLOSE tv_up_cur; END IF;
		END IF;

	END IF;

	EXCEPTION

	--WHEN ORATERMINATE THEN
	--	RAISE ORATERMINATE;

	WHEN OTHERS THEN
		IF tv_up_cur%ISOPEN THEN CLOSE tv_up_cur; END IF;
		IF cust_cur%ISOPEN THEN CLOSE cust_cur; END IF;
		IF act_cur%ISOPEN THEN CLOSE act_cur; END IF;
		STBMS_ERR.DISP_ERR( 100032, SQLERRM || 'line <' || dbms_utility.format_error_backtrace || '>' );

END check_neg_duplication;
*/
/*-------------------------------------------------------------------------------------------------
Procedure    : create_standard_pricng
Purpose      :									
/*-------------------------------------------------------------------------------------------------*/


PROCEDURE create_standard_pricng(  ip_cmud_data_tab IN  std_def_tab,
				   op_tv_uid        OUT VARCHAR2) AS

	m_tv_rec_id		TARIFF_VARIATION.TV_REC_ID%TYPE		:= NULL;
	m_tv_tarif_sch		TARIFF_VARIATION.tv_tarif_sch%TYPE 	:= NULL;
	m_tcg_code		SUBSCRIBER_MASTER.PM_TCG_CODE%TYPE;
	m_template		TARIFF_SCHEME.TS_TS_CODE%type;

	CURSOR tcr_cur(ip_tv_cwt_code IN NUMBER) IS
		SELECT
			tcr_cwt_code,           
			tcr_seq_no,           
			tcr_nop_lower,
			tcr_nop,
			tcr_rate,              
			tcr_applied_field,
			tcr_upper_limit,
			tcr_lower_limit,        
			tcr_Rate_Type,        
			tcr_ign_yn,        
			tcr_tc_rec_id,        		
			tcr_rel_Rate_Type,
			tcr_rel_rate,
			tcr_rel_rate_inc_dec,
			tcr_disc_Rate_Type,
			tcr_disc_rate
		FROM
			TARIFF_CALL_RATES
		WHERE
			tcr_cwt_code = ip_tv_cwt_code;

	m_tcr	tcr_cur%ROWTYPE;

	CURSOR tc_cur(ip_tv_cwt_code IN NUMBER) IS 
		SELECT		
			tc_cwt_code,
			tc_des,
			tc_Min_Charge,
			tc_Max_Charge,
			tc_setup_charge,
			tc_cum_type,
			tc_ann_tar_rate,
			tc_cur,
			tc_rec_id,
			tc_tc_type,
			tc_interest_type,
			tc_interest_period_type,
			tc_interest_based_on,
			tc_limit_based_on,
			tc_from_date,
			tc_to_date,
			tc_status,
			tc_Rate_Type,
			tc_rvw_date,
			tc_pricing_template,
			tc_interest_comp_basis,
			tc_rate_id,
			tc_Comp_Type,
			tc_template_type,
			tc_template_instance,
			tc_free_limit_usage,
			tc_free_limit_method,
			tc_free_limit_factor,
			tc_constant_free_limit,
			tc_free_limit_comp_method,
			tc_personalised,
			tc_incl_excl_slabs		
		FROM		
			tariff_call_scheme
		WHERE		
			tc_cwt_code = ip_tv_cwt_code;
	
	scheme	tc_cur%ROWTYPE;	

	CURSOR ts_cur(ip_methodology IN VARCHAR2) IS 
		SELECT		
			tc_cwt_code,
			tc_des,
			tc_Min_Charge,
			tc_Max_Charge,
			tc_setup_charge,
			tc_cum_type,
			tc_ann_tar_rate,
			tc_cur,
			tc_rec_id,
			tc_tc_type,
			tc_interest_type,
			tc_interest_period_type,
			tc_interest_based_on,
			tc_limit_based_on,
			tc_from_date,
			tc_to_date,
			tc_status,
			tc_Rate_Type,
			tc_rvw_date,
			tc_pricing_template,
			tc_interest_comp_basis,
			tc_rate_id,
			tc_Comp_Type,
			tc_template_type,
			tc_template_instance,
			tc_free_limit_usage,
			tc_free_limit_method,
			tc_free_limit_factor,
			tc_constant_free_limit,
			tc_free_limit_comp_method,
			tc_personalised,
			tc_incl_excl_slabs		
		FROM		
			tariff_call_scheme,
			tariff_scheme
		WHERE		
			tc_cwt_code = ts_cwt_code
		AND
			ts_pricing_template = ip_methodology
		AND
			ts_template_type IS NULL;
	
	scheme_ts	ts_cur%ROWTYPE;	
	
	m_err_msg err_return_api := err_return_api(NULL,NULL);


	CURSOR template_cur(ip_methodology VARCHAR2) IS
	SELECT
		MAX(TS_TS_CODE) TS_TS_CODE,
		MAX(TS_CUR_CODE) TS_CUR_CODE
		
	FROM
		TARIFF_SCHEME
	WHERE
		TS_PRICING_TEMPLATE = ip_methodology
	AND
		TS_TEMPLATE_TYPE IS NULL;

	CURSOR tv_id_cur(ip_cwt_code IN VARCHAR2)IS

	SELECT
		tv_uid
	FROM
		TARIFF_VARIATION
	WHERE
		TV_CWT_CODE = ip_cwt_code
	AND
		TV_TARIF_BAND = ip_cmud_data_tab(1).TV_TARIF_BAND;
	--AND
		--TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_FROM_DATE,g_date_format)) BETWEEN tv_from_date AND NVL(tv_to_date, STBMS_STD.HIGH_DATE);
	
	CURSOR update_cur IS
	SELECT
		tv_uid,
		tv_tarif_sch,
		tv_cwt_code,
		tv_personalised_yn,
		tv_status
	FROM
		TARIFF_VARIATION
	WHERE
		NVL(tv_tarif_band ,'$$') = NVL(ip_cmud_data_tab(1).TV_TARIF_BAND,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).TV_TCG_CODE,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		NVL(tv_qos_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_qos_code,'$$')
	AND
		NVL(tv_tf_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_tf_code,'$$')
	--AND
	--	NVL(tv_pricing_template ,0) = NVL(ip_cmud_data_tab(1).tv_pricing_template,0)
	AND
		NVL(tv_crp_code ,'$$') = 'REG'
	AND
		NVL(tv_msc_code ,'$$') = 'DEF'
	AND
		NVL(tv_chc_code ,'$$') = 'DEF'
	AND
		TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_FROM_DATE,g_date_format)) = trunc(tv_from_date);
	/*AND
		--TRUNC(TO_DATE(nvl(ip_cmud_data_tab(1).TV_TO_DATE,STBMS_STD.HIGH_DATE),g_date_format)) = TRUNC(TO_DATE(nvl(TV_TO_DATE,STBMS_STD.HIGH_DATE),g_date_format));
		--TRUNC(nvl(TO_DATE(ip_cmud_data_tab(1).TV_TO_DATE,g_date_format),STBMS_STD.HIGH_DATE)) = TRUNC(TO_DATE(nvl(TV_TO_DATE,STBMS_STD.HIGH_DATE),g_date_format));
		TRUNC(nvl(TO_DATE(ip_cmud_data_tab(1).TV_TO_DATE,g_date_format),STBMS_STD.HIGH_DATE)) = TRUNC(nvl(TV_TO_DATE,STBMS_STD.HIGH_DATE));
	*/
	CURSOR CCUA_CUR (IP_TV_UID IN NUMBER)IS

         SELECT ccua_id,ccua_bd_code,ccua_tv_uid,ccua_cust_no,ccua_subs_act_no,ccua_stv_id,
		ccua_user1,ccua_user2,ccua_user3,ccua_user4,ccua_user5,ccua_user6,ccua_user7,
		ccua_user8,ccua_user9,ccua_user10,ccua_user11,ccua_user12,ccua_user13,
		ccua_user14,ccua_user15,ccua_user_num1,ccua_user_num2,ccua_user_num3,
		ccua_user_num4,ccua_user_num5,ccua_user_date1,ccua_user_date2,ccua_user_date3
           FROM 
           	charge_code_user_attribs
          WHERE 	
          	ccua_bd_code = ip_cmud_data_tab(1).tv_tarif_band
          AND
          	ccua_tv_uid  = IP_TV_UID
          AND
          	ccua_cust_no is null
          AND
          	ccua_subs_act_no IS NULL
          AND
          	ccua_stv_id is null;
          	
	m_operation 		VARCHAR2(2)	:= 'I' ;
	m_tcr_count		NUMBER(5)	:= 0;
	m_count			NUMBER(5)	:= 0;
	m_tv_id			SUBS_TARIFF_VARIATION.STV_ID%TYPE;
	m_tv_cwt_code		TARIFF_VARIATION.TV_CWT_CODE%TYPE:=null;
	m_ts_cwt_code		TARIFF_SCHEME.TS_CWT_CODE%TYPE;
	m_ts_cur_code		TARIFF_SCHEME.TS_CUR_CODE%TYPE;
	m_tc_cwt_code		TARIFF_CALL_SCHEME.TC_CWT_CODE%TYPE;
	m_office_code   	STAFF_PROFILE.SP_OFF_CODE%TYPE;
	m_tv_uid 		TARIFF_VARIATION.TV_UID%TYPE;
	m_tv_tariff_sch 	TARIFF_VARIATION.TV_TARIF_SCH%TYPE;
	m_personlised_yn        TARIFF_VARIATION.TV_PERSONALISED_YN%TYPE;
	m_rec_id		TARIFF_CALL_SCHEME.TC_REC_ID%TYPE;
	m_comp_type	    	VARCHAR2(20);
	m_tariff_var_obj 			tariff_variation_api_obj 		:= tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);--DC
	m_tariff_variation_array   	tariff_variation_api_obj_array  	:= tariff_variation_api_obj_array(tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));--DC
	m_ccua  CCUA_CUR%rowtype;
	m_charge_code_user_attr	 ccua_api_obj := ccua_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	m_upd_rec  update_cur%rowtype;

	BEGIN

		m_template := null;
	
		IF ip_cmud_data_tab(1).tv_pricing_template IS NOT NULL THEN
			OPEN template_cur(ip_cmud_data_tab(1).tv_pricing_template);				
			FETCH template_cur INTO m_template,m_ts_cur_code;
			
			IF template_cur%ISOPEN THEN CLOSE template_cur; END IF;
		
		END IF;

		clearTariff;


		OPEN update_cur;
		--FETCH update_cur INTO m_tv_uid,m_tv_tariff_sch,m_tv_cwt_code,m_personlised_yn;
		FETCH update_cur INTO m_upd_rec;
		
		IF update_cur%FOUND then		
			m_tv_uid 	:= m_upd_rec.tv_uid;
			m_tv_tariff_sch := m_upd_rec.tv_tarif_sch;
			m_tv_cwt_code 	:= m_upd_rec.tv_cwt_code;			
		END IF;
			
		if(m_tv_uid IS NOT NULL) THEN
			m_operation := 'U';
		end if;
		IF update_cur%ISOPEN THEN CLOSE update_cur; END IF;
		
		tariff_var_obj.TV_CRP_CODE	     := 'REG';
		tariff_var_obj.TV_MSC_CODE	     := 'DEF'; 
		tariff_var_obj.TV_CHC_CODE           := 'DEF'; 
		tariff_var_obj.TV_QOS_CODE           := ip_cmud_data_tab(1).TV_QOS_CODE;
		tariff_var_obj.TV_TF_CODE            := ip_cmud_data_tab(1).TV_TF_CODE;
		tariff_var_obj.TV_TCG_CODE           := ip_cmud_data_tab(1).TV_TCG_CODE;
		tariff_var_obj.TV_TARIFF_CLASS       := ip_cmud_data_tab(1).TV_TARIFF_CLASS;
		tariff_var_obj.TV_TARIF_BAND         := ip_cmud_data_tab(1).TV_TARIF_BAND;
		tariff_var_obj.TV_TG_ID              := ip_cmud_data_tab(1).TV_TARIF_BAND;
		tariff_var_obj.TV_FROM_DATE          := TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_FROM_DATE,g_date_format));
		tariff_var_obj.TV_TO_DATE            := TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_TO_DATE,g_date_format));
		tariff_var_obj.TV_DES                := ip_cmud_data_tab(1).TV_DES;
		tariff_var_obj.TV_TRANS_CURRENCY     := ip_cmud_data_tab(1).TV_TRANS_CURRENCY;
		tariff_var_obj.TV_PRICING_TEMPLATE   := ip_cmud_data_tab(1).TV_PRICING_TEMPLATE;
		tariff_var_obj.TV_TARIF_SCH  	     := m_template;
		--tariff_var_obj.TV_RVW_DATE           := TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_RVW_DATE,g_date_format));
		
		IF m_operation = 'U' THEN
			tariff_var_obj.TV_UID        		:= m_tv_uid;
			tariff_var_obj.TV_PERSONALISED_YN	:= m_upd_rec.tv_personalised_yn;
			tariff_var_obj.TV_STATUS             	:= m_upd_rec.tv_status;
		ELSE
			tariff_var_obj.TV_UID        		:= '';
			tariff_var_obj.TV_PERSONALISED_YN	:= 'N';
			tariff_var_obj.TV_STATUS             	:= 'A';
		END IF;


		OPEN tc_cur(m_tv_cwt_code); 
		
		FETCH tc_cur INTO scheme;
		IF scheme.tc_cwt_code IS NOT NULL THEN

		
			m_tc_cwt_code	:= stbms_cmn.sun_seq_no ('TC_CWT_CODE');
			
			tariff_call_scheme_array(1).tc_cwt_code  		:= m_tc_cwt_code;
			tariff_call_scheme_array(1).tc_des              	:= scheme.tc_des;
			tariff_call_scheme_array(1).tc_min_charge 		:= scheme.tc_min_charge;
			tariff_call_scheme_array(1).tc_max_charge 		:= scheme.tc_max_charge;
			tariff_call_scheme_array(1).tc_setup_charge 		:= scheme.tc_setup_charge;
			tariff_call_scheme_array(1).tc_ann_tar_rate 		:= scheme.tc_ann_tar_rate;
			tariff_call_scheme_array(1).tc_tc_type 			:= scheme.tc_tc_type;
			tariff_call_scheme_array(1).tc_interest_comp_basis 	:= scheme.tc_interest_comp_basis;
			tariff_call_scheme_array(1).tc_interest_type 		:= scheme.tc_interest_type;
			tariff_call_scheme_array(1).tc_interest_period_type 	:= scheme.tc_interest_period_type;
			tariff_call_scheme_array(1).tc_interest_based_on 	:= scheme.tc_interest_based_on;
			tariff_call_scheme_array(1).tc_limit_based_on 		:= scheme.tc_limit_based_on;
			tariff_call_scheme_array(1).tc_personalised 		:= scheme.tc_personalised;
			tariff_call_scheme_array(1).tc_rate_id           	:= scheme.tc_rate_id;
			tariff_call_scheme_array(1).tc_cur               	:= scheme.tc_cur;		

			m_rec_id := stbms_cmn.sun_seq_no ('TC_REC_ID');
			
			tariff_call_scheme_array(1).tc_rec_id 			:= m_rec_id;

			tariff_call_scheme_array(1).tc_from_date            	:= TO_DATE(ip_cmud_data_tab(1).tv_from_date,g_date_format);
			tariff_call_scheme_array(1).tc_to_date              	:= TO_DATE(ip_cmud_data_tab(1).tv_to_date,g_date_format);
			tariff_call_scheme_array(1).tc_status               	:= scheme.tc_status;
			tariff_call_scheme_array(1).tc_rvw_date             	:= '';
			tariff_call_scheme_array(1).tc_cum_type 		:= ip_cmud_data_tab(1).tc_cum_type;
			tariff_call_scheme_array(1).tc_rate_type		:= ip_cmud_data_tab(1).tc_rate_type;		
			tariff_call_scheme_array(1).tc_pricing_template 	:= ip_cmud_data_tab(1).tv_pricing_template;
			

		ELSE
			open ts_cur(ip_cmud_data_tab(1).tv_pricing_template);
			fetch ts_cur INTO scheme_ts;
			
			IF ts_cur%FOUND THEN

				m_tv_cwt_code 	:= scheme_ts.tc_cwt_code;
				m_tc_cwt_code	:= stbms_cmn.sun_seq_no ('TC_CWT_CODE');

				tariff_call_scheme_array(1).tc_cwt_code  		:= m_tc_cwt_code;
				tariff_call_scheme_array(1).tc_des              	:= ip_cmud_data_tab(1).tv_des;
				tariff_call_scheme_array(1).tc_min_charge 		:= '0';
				tariff_call_scheme_array(1).tc_max_charge 		:= '999999999.999999999';
				tariff_call_scheme_array(1).tc_setup_charge 		:= '0';
				tariff_call_scheme_array(1).tc_cur               	:= m_ts_cur_code;		
				
				m_rec_id := stbms_cmn.sun_seq_no ('TC_REC_ID');

				tariff_call_scheme_array(1).tc_rec_id 			:= m_rec_id;

				tariff_call_scheme_array(1).tc_from_date            	:= TO_DATE(ip_cmud_data_tab(1).tv_from_date,g_date_format);
				tariff_call_scheme_array(1).tc_to_date              	:= TO_DATE(ip_cmud_data_tab(1).tv_to_date,g_date_format);
				tariff_call_scheme_array(1).tc_status               	:= 'A';
				tariff_call_scheme_array(1).tc_rvw_date             	:= '';
				tariff_call_scheme_array(1).tc_cum_type 		:= ip_cmud_data_tab(1).tc_cum_type;
				tariff_call_scheme_array(1).tc_rate_type		:= ip_cmud_data_tab(1).tc_rate_type;		
				tariff_call_scheme_array(1).tc_pricing_template 	:= ip_cmud_data_tab(1).tv_pricing_template;
				

			END IF;
			IF ts_cur%ISOPEN THEN CLOSE ts_cur; END IF;

		END IF;
		
		IF tc_cur%ISOPEN THEN CLOSE tc_cur; END IF;

		OPEN tcr_cur(m_tv_cwt_code);

		FETCH tcr_cur INTO m_tcr;
		
		IF tcr_cur%FOUND THEN

			FOR i IN 1..ip_cmud_data_tab.COUNT LOOP

				m_count := m_count+1;
				tariff_call_rates_obj.tcr_seq_no 		:= m_tcr_count;
				tariff_call_rates_obj.tcr_cwt_code 		:= tariff_call_scheme_array(1).TC_CWT_CODE;
				tariff_call_rates_obj.tcr_tc_rec_id 		:= tariff_call_scheme_array(1).TC_REC_ID;
				tariff_call_rates_obj.tcr_nop 			:= ip_cmud_data_tab(i).tier_to;
				tariff_call_rates_obj.tcr_nop_lower 		:= ip_cmud_data_tab(i).tier_from;
				tariff_call_rates_obj.tcr_rate			:= ip_cmud_data_tab(i).rate;
				tariff_call_rates_obj.tcr_applied_field		:= m_tcr.tcr_applied_field;
				tariff_call_rates_obj.tcr_upper_limit		:= ip_cmud_data_tab(i).tcr_upper_limit;
				tariff_call_rates_obj.tcr_lower_limit		:= m_tcr.tcr_lower_limit;
				tariff_call_rates_obj.tcr_rate_type		:= 'R'; 

				IF i<>1 THEN
					tariff_call_rates_array.EXTEND;
				END IF;

				tariff_call_rates_array(m_count) := tariff_call_rates_obj;

				tariff_call_scheme_array(1).rates_array := tariff_call_rates_array; 

				m_tcr_count := m_tcr_count+1;

			END LOOP;
			
		ELSE
			FOR i IN 1..ip_cmud_data_tab.COUNT LOOP

				m_count := m_count+1;
				tariff_call_rates_obj.tcr_seq_no 		:= m_tcr_count;
				tariff_call_rates_obj.tcr_cwt_code 		:= tariff_call_scheme_array(1).TC_CWT_CODE;
				tariff_call_rates_obj.tcr_tc_rec_id 		:= tariff_call_scheme_array(1).TC_REC_ID;
				tariff_call_rates_obj.tcr_nop 			:= ip_cmud_data_tab(i).tier_to;
				tariff_call_rates_obj.tcr_nop_lower 		:= ip_cmud_data_tab(i).tier_from;
				tariff_call_rates_obj.tcr_rate			:= ip_cmud_data_tab(i).rate;
				tariff_call_rates_obj.tcr_upper_limit		:= ip_cmud_data_tab(i).tcr_upper_limit;
				tariff_call_rates_obj.tcr_rate_type		:= 'R'; 

				IF i<>1 THEN
					tariff_call_rates_array.EXTEND;
				END IF;

				tariff_call_rates_array(m_count) := tariff_call_rates_obj;

				tariff_call_scheme_array(1).rates_array := tariff_call_rates_array; 

				m_tcr_count := m_tcr_count+1;

			END LOOP;
		
		END IF;
		
		IF tcr_cur%ISOPEN THEN CLOSE tcr_cur; END IF;

		FOR i IN 1..ip_cmud_data_tab.COUNT LOOP

			IF i<> ip_cmud_data_tab.COUNT THEN

				IF (ip_cmud_data_tab(i).Tier_To <> ip_cmud_data_tab(i+1).Tier_From)THEN


					load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(i+1).cmud_id,'P20001','Tier-From of Tier Group '||i+1||'should be same as Tier-To of Tier Group '||i);

					RETURN;
				END IF;

			END IF;

		END LOOP;

		tariff_variation_array := Price_List_Api.ProcessTariffVariation(tariff_var_obj,tariff_call_scheme_array,m_operation,NULL,NULL,m_err_msg);



		IF m_err_msg.err_code IS NOT NULL THEN

		  load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P20002-'||m_err_msg.err_code,m_err_msg.err_msg);

		RETURN;

		END IF;

		OPEN tv_id_cur(m_tc_cwt_code);
		FETCH tv_id_cur INTO m_tv_id;

		--IF tv_id_cur%FOUND THEN
		IF tariff_variation_array.COUNT >0 THEN

			op_tv_uid := tariff_variation_array(1).tv_uid;
			m_tv_id   := tariff_variation_array(1).tv_uid;
				/*Loading Charge Code user Attributes*/

			OPEN ccua_cur(m_tv_id);
			FETCH ccua_cur INTO m_ccua;
			IF ccua_cur%FOUND THEN

				m_operation :='U';

				charge_code_user_attr.ccua_id		:= m_ccua.ccua_id;
				charge_code_user_attr.ccua_bd_code	:= m_ccua.ccua_bd_code;
				charge_code_user_attr.ccua_tv_uid	:= m_ccua.ccua_tv_uid;
				charge_code_user_attr.ccua_cust_no	:= m_ccua.ccua_cust_no;
				charge_code_user_attr.ccua_subs_act_no	:= m_ccua.ccua_subs_act_no;
				charge_code_user_attr.ccua_stv_id	:= null;
				charge_code_user_attr.ccua_user1	:= m_ccua.ccua_user1;
				charge_code_user_attr.ccua_user2	:= m_ccua.ccua_user2;
				charge_code_user_attr.ccua_user3	:= m_ccua.ccua_user3;
				charge_code_user_attr.ccua_user4	:= ip_cmud_data_tab(1).cmud_data_col25;
				charge_code_user_attr.ccua_user5	:= m_ccua.ccua_user5; 
				charge_code_user_attr.ccua_user6	:= m_ccua.ccua_user6; 
				charge_code_user_attr.ccua_user7	:= m_ccua.ccua_user7; 
				charge_code_user_attr.ccua_user8	:= m_ccua.ccua_user8; 
				charge_code_user_attr.ccua_user9	:= m_ccua.ccua_user9; 
				charge_code_user_attr.ccua_user10	:= m_ccua.ccua_user10; 
				charge_code_user_attr.ccua_user11	:= ip_cmud_data_tab(1).cmud_data_col22;
				charge_code_user_attr.ccua_user12	:= ip_cmud_data_tab(1).cmud_data_col21;
				charge_code_user_attr.ccua_user13	:= ip_cmud_data_tab(1).cmud_data_col23;
				charge_code_user_attr.ccua_user14	:= m_ccua.ccua_user14; 
				charge_code_user_attr.ccua_user15	:= m_ccua.ccua_user15; 
				charge_code_user_attr.ccua_user_num1	:= m_ccua.ccua_user_num1;
				charge_code_user_attr.ccua_user_num2	:= m_ccua.ccua_user_num2;
				charge_code_user_attr.ccua_user_num3	:= m_ccua.ccua_user_num3; 
				charge_code_user_attr.ccua_user_num4	:= m_ccua.ccua_user_num4; 
				charge_code_user_attr.ccua_user_num5	:= ip_cmud_data_tab(1).cmud_data_col24; 
				charge_code_user_attr.ccua_user_date1	:= m_ccua.ccua_user_date1; 
				charge_code_user_attr.ccua_user_date2	:= m_ccua.ccua_user_date2; 
				charge_code_user_attr.ccua_user_date3	:= m_ccua.ccua_user_date3; 

			ELSE

				m_operation :='I';
				charge_code_user_attr.ccua_id		:= stbms_cmn.sun_seq_no ('CCUA_ID');
				charge_code_user_attr.ccua_bd_code	:= ip_cmud_data_tab(1).tv_tarif_band;
				charge_code_user_attr.ccua_tv_uid	:= m_tv_id;
				charge_code_user_attr.ccua_cust_no	:= '';
				charge_code_user_attr.ccua_subs_act_no	:= '';
				charge_code_user_attr.ccua_stv_id	:= '';
				charge_code_user_attr.ccua_user1	:=''; 
				charge_code_user_attr.ccua_user2	:=''; 
				charge_code_user_attr.ccua_user3	:=''; 
				charge_code_user_attr.ccua_user4	:= ip_cmud_data_tab(1).cmud_data_col25;
				charge_code_user_attr.ccua_user5	:=''; 
				charge_code_user_attr.ccua_user6	:=''; 
				charge_code_user_attr.ccua_user7	:=''; 
				charge_code_user_attr.ccua_user8	:=''; 
				charge_code_user_attr.ccua_user9	:=''; 
				charge_code_user_attr.ccua_user10	:=''; 
				charge_code_user_attr.ccua_user11	:= ip_cmud_data_tab(1).cmud_data_col22;
				charge_code_user_attr.ccua_user12	:= ip_cmud_data_tab(1).cmud_data_col21;
				charge_code_user_attr.ccua_user13	:= ip_cmud_data_tab(1).cmud_data_col23;
				charge_code_user_attr.ccua_user14	:=''; 
				charge_code_user_attr.ccua_user15	:=''; 
				charge_code_user_attr.ccua_user_num1	:= null; 
				charge_code_user_attr.ccua_user_num2	:= null;
				charge_code_user_attr.ccua_user_num3	:= null; 
				charge_code_user_attr.ccua_user_num4	:= null; 
				charge_code_user_attr.ccua_user_num5	:= ip_cmud_data_tab(1).cmud_data_col24; 
				charge_code_user_attr.ccua_user_date1	:= null; 
				charge_code_user_attr.ccua_user_date2	:= null; 
				charge_code_user_attr.ccua_user_date3	:= null; 
			END IF;
			IF ccua_cur%ISOPEN THEN CLOSE ccua_cur; END IF;

			m_charge_code_user_attr	:= Price_List_Api.processchargecodeuserattr(charge_code_user_attr,m_operation,'N',null,m_err_msg);

			IF m_err_msg.err_code IS NOT NULL THEN
			    load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P20005-'||m_err_msg.err_code,m_err_msg.err_msg);
				RETURN;					
			END IF;
		ELSE
		  IF tv_id_cur%ISOPEN THEN CLOSE tv_id_cur; END IF;

		  load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P20003','Error while calling Price_List_Api');

		RETURN;		
			
		END IF;

		IF tv_id_cur%ISOPEN THEN
			CLOSE tv_id_cur;
		END IF;


	EXCEPTION

	--WHEN ORATERMINATE THEN
	--	RAISE ORATERMINATE;

	WHEN OTHERS THEN
		IF template_cur%ISOPEN THEN CLOSE template_cur; END IF;
		IF update_cur%ISOPEN THEN CLOSE update_cur; END IF;
		IF tc_cur%ISOPEN THEN CLOSE tc_cur; END IF;
		IF ts_cur%ISOPEN THEN CLOSE ts_cur; END IF;
		IF tcr_cur%ISOPEN THEN CLOSE tcr_cur; END IF;
		IF ccua_cur%ISOPEN THEN CLOSE ccua_cur; END IF;
		IF tv_id_cur%ISOPEN THEN CLOSE tv_id_cur; END IF;

		STBMS_ERR.DISP_ERR( 100031, SQLERRM || 'line <' || dbms_utility.format_error_backtrace || '>' );

END create_standard_pricng;
/*-------------------------------------------------------------------------------------------------
	Procedure	: standard_pricelist_single_grp
	Purpose		:
-------------------------------------------------------------------------------------------------*/

PROCEDURE standard_pricelist_single_grp(ip_group_id			IN  VARCHAR2,
				     ip_excel_id 			IN  VARCHAR2,
				     op_tv_uid 				OUT VARCHAR2, 
				     op_eff_from_date			OUT VARCHAR2,
				     op_eff_to_date			OUT VARCHAR2,
				     op_err_code			OUT VARCHAR2,
				     op_err_msg				OUT VARCHAR2) IS
					      	 
	m_cmud_rec 		 std_def_tab;
		
	CURSOR detail_cur IS
		SELECT
			cmud_cmu_id,
			cmud_id,
			cmud_data_col1 	 group_id,
			cmud_data_col2 	 grp_seq_id,
			cmud_data_col3	 country,	     	 
			cmud_data_col4	 tv_tcg_code,		 
			nvl(cmud_data_col5,'-')	 tv_des,	 
			cmud_data_col6	 tv_tarif_band,		 	      
			cmud_data_col7	 gbt_des,		 	      
			cmud_data_col8	 tv_qos_code,	 
			cmud_data_col9	 tv_tf_code,	 
			cmud_data_col10	 tv_pricing_template,		 
			cmud_data_col11	 tv_tariff_class,		 
			cmud_data_col12	 tv_from_date,		 
			cmud_data_col13	 tv_to_date,	 
			cmud_data_col14	 tv_trans_currency,		 
			--cmud_data_col15	 ts_usage_data,		 
			cmud_data_col15	 tc_cum_type,		 
			cmud_data_col16	 tc_rate_type,		 
			cmud_data_col17	 tier_from,		 
			cmud_data_col18	 tier_to,		 	 
			cmud_data_col19	 rate,		 
			cmud_data_col20	 tcr_upper_limit,
			cmud_data_col21	,	 
			cmud_data_col22	,	 
			cmud_data_col23	,	 
			cmud_data_col24	,	 
			cmud_data_col25	,	 
			cmud_data_col26	,	         
			cmud_data_col27	,	 	 
			cmud_data_col28	,		 
			cmud_data_col29	,	 	 
			cmud_data_col30	,	 
			cmud_data_col31	,	
			cmud_data_col32	,
			cmud_data_col33	,
			cmud_data_col34	,
			cmud_data_col35	,
			cmud_data_col36	,
			cmud_data_col37	, 
			cmud_data_col38	,
			cmud_data_col39	,
			cmud_data_col40	,
			cmud_data_col41	,
			cmud_data_col42	,
			cmud_data_col43	,
			cmud_data_col44	,
			cmud_data_col45	,
			cmud_data_col46	,
			cmud_data_col47	,
			cmud_status status
		FROM
			cstm_mega_upload_det	
		WHERE	
			CMUD_CMU_ID = ip_excel_id
		AND
			cmud_data_col1	= ip_group_id--For getting multiple tiers
		ORDER BY 
			to_number(cmud_cmu_id),
			to_number(cmud_data_col1),
			to_number(cmud_data_col2);
				 	     
		TYPE detail_arr	IS TABLE of detail_cur%ROWTYPE INDEX BY BINARY_INTEGER;
	
		detail_tab	 detail_arr;
	
		m_index		 NUMBER(10) := 0;
		m_indx		 NUMBER(10) := 0; 
		
		m_Tier_From	 VARCHAR2(25);
		m_Tier_To	 VARCHAR2(25);
		m_rate		 NUMBER(18,10) := 0;
		m_rate_type	 VARCHAR2(1);
		
	BEGIN	
		
		g_err_tab.DELETE;
		g_cmud_id_tab_type.DELETE;
		g_grp_seq_tab_type.DELETE;
		
		OPEN detail_cur;
		LOOP
			
			detail_tab.DELETE;

			FETCH detail_cur BULK COLLECT INTO detail_tab;
			EXIT WHEN detail_tab.COUNT=0;

			--IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;

			FOR i IN 1..detail_tab.COUNT LOOP

				m_index := m_index+1;
				m_indx  := g_cmud_id_tab_type.COUNT + 1;

				g_cmud_id_tab_type(m_indx) 	:= detail_tab(i).CMUD_ID;

				m_Tier_From := TRIM(UPPER(detail_tab(i).tier_from));
				m_Tier_To   := TRIM(UPPER(detail_tab(i).tier_to));

				m_cmud_rec(m_index).cmud_cmu_id		:= detail_tab(i).cmud_cmu_id;
				m_cmud_rec(m_index).cmud_id		:= detail_tab(i).cmud_id;
				m_cmud_rec(m_index).group_id		:= detail_tab(i).group_id;
				m_cmud_rec(m_index).grp_seq_id		:= detail_tab(i).grp_seq_id;
				m_cmud_rec(m_index).country		:= detail_tab(i).country;
				m_cmud_rec(m_index).tv_tcg_code		:= detail_tab(i).tv_tcg_code;
				m_cmud_rec(m_index).tv_des		:= detail_tab(i).tv_des;
				m_cmud_rec(m_index).tv_tarif_band		:= detail_tab(i).tv_tarif_band;
				m_cmud_rec(m_index).gbt_des		:= detail_tab(i).gbt_des;
				m_cmud_rec(m_index).tv_qos_code		:= detail_tab(i).tv_qos_code;
				m_cmud_rec(m_index).tv_tf_code		:= detail_tab(i).tv_tf_code;
				m_cmud_rec(m_index).tv_tariff_class	:= detail_tab(i).tv_tariff_class;
				m_cmud_rec(m_index).tv_pricing_template		:= detail_tab(i).tv_pricing_template;
				m_cmud_rec(m_index).tv_from_date		:= detail_tab(i).tv_from_date;
				m_cmud_rec(m_index).tv_to_date		:= detail_tab(i).tv_to_date;
				m_cmud_rec(m_index).tv_trans_currency	:= detail_tab(i).tv_trans_currency;
				--m_cmud_rec(m_index).ts_usage_data		:= detail_tab(i).ts_usage_data;
				--m_cmud_rec(m_index).tc_cum_type		:= detail_tab(i).tc_cum_type;
				m_cmud_rec(m_index).tc_cum_type		:= CASE
										WHEN detail_tab(i).tc_cum_type = 'Flat Computation - Rate Type' 	THEN 'FR'
										WHEN detail_tab(i).tc_cum_type = 'Flat Computation - Absolute'  	THEN 'FA'
										WHEN detail_tab(i).tc_cum_type = 'Tiered Computation - Rate Type' THEN 'TR'
										WHEN detail_tab(i).tc_cum_type = 'Tiered Computation - Absolute'  THEN 'TA'
										ELSE detail_tab(i).tc_cum_type
									   END;

				--m_cmud_rec(m_index).tc_rate_type	:= detail_tab(i).tc_rate_type;
				m_cmud_rec(m_index).tc_rate_type	:= CASE WHEN detail_tab(i).tc_rate_type = 'Rate' THEN 'R' WHEN detail_tab(i).tc_rate_type = 'Percentage' THEN 'P' ELSE detail_tab(i).tc_rate_type END;

				m_rate_type	:= m_cmud_rec(1).tc_rate_type;

				m_cmud_rec(m_index).tier_from		:= detail_tab(i).tier_from;
				m_cmud_rec(m_index).tier_to		:= detail_tab(i).tier_to;

				m_rate := detail_tab(i).rate;

				IF(m_rate_type = 'P') THEN
					m_cmud_rec(m_index).rate		:= m_rate/100;
				ELSE
					m_cmud_rec(m_index).rate		:= detail_tab(i).rate;
				END IF;

				m_cmud_rec(m_index).tcr_upper_limit	:= detail_tab(i).tcr_upper_limit;
				m_cmud_rec(m_index).cmud_data_col21	:= detail_tab(i).cmud_data_col21;
				m_cmud_rec(m_index).cmud_data_col22	:= detail_tab(i).cmud_data_col22;
				m_cmud_rec(m_index).cmud_data_col23	:= detail_tab(i).cmud_data_col23;
				m_cmud_rec(m_index).cmud_data_col24	:= detail_tab(i).cmud_data_col24;
				m_cmud_rec(m_index).cmud_data_col25	:= detail_tab(i).cmud_data_col25;
				m_cmud_rec(m_index).cmud_data_col26	:= detail_tab(i).cmud_data_col26;
				m_cmud_rec(m_index).cmud_data_col27	:= detail_tab(i).cmud_data_col27;
				m_cmud_rec(m_index).cmud_data_col28	:= detail_tab(i).cmud_data_col28;
				m_cmud_rec(m_index).cmud_data_col29	:= detail_tab(i).cmud_data_col29;
				m_cmud_rec(m_index).cmud_data_col30	:= detail_tab(i).cmud_data_col30;
				m_cmud_rec(m_index).cmud_data_col31	:= detail_tab(i).cmud_data_col31;
				m_cmud_rec(m_index).cmud_data_col32	:= detail_tab(i).cmud_data_col32;
				m_cmud_rec(m_index).cmud_data_col33	:= detail_tab(i).cmud_data_col33;
				m_cmud_rec(m_index).cmud_data_col34	:= detail_tab(i).cmud_data_col34;
				m_cmud_rec(m_index).cmud_data_col35	:= detail_tab(i).cmud_data_col35;
				m_cmud_rec(m_index).cmud_data_col36	:= detail_tab(i).cmud_data_col36;
				m_cmud_rec(m_index).cmud_data_col37	:= detail_tab(i).cmud_data_col37;
				m_cmud_rec(m_index).cmud_data_col38	:= detail_tab(i).cmud_data_col38;
				m_cmud_rec(m_index).cmud_data_col39	:= detail_tab(i).cmud_data_col39;
				m_cmud_rec(m_index).cmud_data_col40	:= detail_tab(i).cmud_data_col40;
				m_cmud_rec(m_index).cmud_data_col41	:= detail_tab(i).cmud_data_col41;
				m_cmud_rec(m_index).cmud_data_col42	:= detail_tab(i).cmud_data_col42;
				m_cmud_rec(m_index).cmud_data_col43	:= detail_tab(i).cmud_data_col43;
				m_cmud_rec(m_index).cmud_data_col44	:= detail_tab(i).cmud_data_col44;
				m_cmud_rec(m_index).cmud_data_col45	:= detail_tab(i).cmud_data_col45;
				m_cmud_rec(m_index).cmud_data_col46	:= detail_tab(i).cmud_data_col46;
				m_cmud_rec(m_index).cmud_data_col47	:= detail_tab(i).cmud_data_col47;
				m_cmud_rec(m_index).status		:= detail_tab(i).status;

				IF m_Tier_From = 'MIN' THEN
					m_Tier_From := '0';			
				END IF;

				IF m_Tier_To = 'MAX' THEN
					m_Tier_To := '999999999999999';
				END IF;

				m_cmud_rec(m_index).tier_from	:= m_Tier_From;
				m_cmud_rec(m_index).tier_to	:= m_Tier_To;

			END LOOP;

			op_eff_from_date 	:= m_cmud_rec(1).tv_from_date;
			op_eff_to_date 		:= m_cmud_rec(1).tv_to_date;


			IF (g_err_tab.COUNT = 0) THEN

				create_standard_pricng(m_cmud_rec,op_tv_uid);

				IF g_err_tab.COUNT = 0 THEN

					op_err_code :='0';
					op_err_msg	:='No Error';
					UPDATE 
					CSTM_MEGA_UPLOAD_DET 
					SET
					CMUD_STATUS = 'P'
					WHERE
					CMUD_CMU_ID = ip_excel_id
					AND
					CMUD_DATA_COL1 = ip_group_id;
				ELSE
					op_err_code := '1';
					op_err_msg	:= 'Error while Creating Standard Defintion';
					--log_std_error( ip_excel_id,ip_group_id);
					log_prcs_error( ip_excel_id,ip_group_id);
				END IF;
			ELSE 
				--log_std_error( ip_excel_id,ip_group_id);
				log_prcs_error( ip_excel_id,ip_group_id);
				op_err_code := '1';
				op_err_msg	:= 'Error while Validating';
			END IF;	

		END LOOP;

		IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;
			
		COMMIT;
		
		
	EXCEPTION
		WHEN OTHERS THEN
		ROLLBACK;
		IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;
	Stbms_Err.disp_err (100025,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );
					      	 
END standard_pricelist_single_grp;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_standard 
 Purpose	: File Level Validation of Standard Upload
-------------------------------------------------------------------------------------------------*/

PROCEDURE standard_pricelist(ip_xl_id IN VARCHAR2,
			ip_template_id IN VARCHAR2,
			op_tv_uid 	OUT VARCHAR2, 
			op_eff_from_date OUT VARCHAR2,
			op_eff_to_date	OUT VARCHAR2,
			op_err_code	OUT VARCHAR2,
			op_err_msg	OUT VARCHAR2) IS

CURSOR
	det_grp_id_cur IS
SELECT
	DISTINCT CMUD_DATA_COL1 grp_id
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
ORDER BY
	to_number(grp_id);
	
TYPE det_grp_id_arr IS TABLE OF det_grp_id_cur%ROWTYPE INDEX BY binary_integer;

m_det_grp_id_tab det_grp_id_arr;
	
	
BEGIN	

	OPEN det_grp_id_cur;	
	LOOP
		m_det_grp_id_tab.DELETE;
		FETCH det_grp_id_cur BULK COLLECT INTO m_det_grp_id_tab LIMIT g_rows;
		EXIT WHEN m_det_grp_id_tab.COUNT = 0;
		
		FOR i IN 1..m_det_grp_id_tab.COUNT LOOP		
		
			standard_pricelist_single_grp(m_det_grp_id_tab(i).grp_id,ip_xl_id,op_tv_uid,op_eff_from_date,op_eff_to_date,op_err_code,op_err_msg);		
		END LOOP;	
	END LOOP;	
	IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;	
EXCEPTION
	WHEN OTHERS THEN
		IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;
		Stbms_Err.disp_err (100076,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END standard_pricelist;
/*-------------------------------------------------------------------------------------------------
 Procedure 	: Check_Priority  -- PMS 58712
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/

/*Check_Priority(ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS

CURSOR
	prt_det_cur IS
SELECT
	cmud_id id,
	cmud_data_col1	Grp_id,
	cmud_data_col2  seq_no,
	cmud_data_col5  priority
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
AND 
	CMUD_DATA_COL1 = ip_grp_id
ORDER BY
	to_number(cmud_id);
	
CURSOR
	prior_det_cur IS
SELECT
	cmud_id id,
	cmud_data_col1	Grp_id,
	cmud_data_col2  seq_no,
	cmud_data_col5  priority
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
AND 
	CMUD_DATA_COL1 IS NULL
ORDER BY
	to_number(cmud_id);

END Check_Priority*/

/*-------------------------------------------------------------------------------------------------
 Procedure 	: load_archives  -- PMS 58712
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/

PROCEDURE load_archives(ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS

CURSOR duplicate_cur IS	
	select * from AMEX_TERM_PRIORITY_MAPPING
	where atpm_off_code = ip_priority_def_tab(ip_index).market
	and nvl(atpm_cust_no,0) = nvl(ip_priority_def_tab(ip_index).cust_no,0)
	and atpm_xl_id <> ip_priority_def_tab(ip_index).cmud_cmu_id
	order by atpm_xl_id;
	
TYPE duplicate_arr IS TABLE OF duplicate_cur%ROWTYPE INDEX BY BINARY_INTEGER;
duplicate_tab duplicate_arr;

BEGIN

	OPEN duplicate_cur;	
	LOOP
		duplicate_tab.DELETE;
		--FETCH duplicate_cur INTO duplicate_rec;
		FETCH duplicate_cur BULK COLLECT INTO duplicate_tab LIMIT g_rows;
		EXIT WHEN duplicate_tab.COUNT = 0;
		
		FOR i IN 1 .. duplicate_tab.COUNT LOOP	
	
		--IF duplicate_cur%FOUND THEN		
			INSERT INTO AMEX_TERM_PRIORITY_MAPPING_ARC (ATPMA_REC_ID,
								ATPMA_OFF_CODE,
								ATPMA_CUST_NO,
								ATPMA_PRIORITY,
								ATPMA_TERM_CODE,
								ATPMA_GRP_ID,
								ATPMA_CUST_ID,
								ATPMA_XL_ID)
			VALUES (duplicate_tab(i).ATPM_REC_ID,
				duplicate_tab(i).ATPM_OFF_CODE,
				duplicate_tab(i).ATPM_CUST_NO,
				duplicate_tab(i).ATPM_PRIORITY,
				duplicate_tab(i).ATPM_TERM_CODE,
				duplicate_tab(i).ATPM_GRP_ID,
				duplicate_tab(i).ATPM_CUST_ID,
				duplicate_tab(i).ATPM_XL_ID);
				
			
				--delete from AMEX_TERM_PRIORITY_MAPPING where atpm_off_code = ip_priority_def_tab(ip_index).market and nvl(atpm_cust_no,0) = nvl(ip_priority_def_tab(ip_index).cust_no,0) and atpm_xl_id <> ip_priority_def_tab(ip_index).cmud_cmu_id;
			
			
			commit;
		--END IF;
		END LOOP;
	END LOOP;

	IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;
				
EXCEPTION 	
	WHEN OTHERS THEN
	 IF duplicate_cur%ISOPEN THEN CLOSE duplicate_cur; END IF;
	 stbms_err.disp_err( 100081, SQLERRM );
END load_archives;   
   
/*-------------------------------------------------------------------------------------------------
Procedure 	: get_cust_no  -- PMS 58712
Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/

FUNCTION get_cust_no(ip_cust_id IN VARCHAR2) RETURN NUMBER AS

CURSOR cust_no_cur IS	
select CM_CUST_NO FROM CUSTOMER_MASTER WHERE CM_CUST_ID = ip_cust_id;

m_cust_no CUSTOMER_MASTER.CM_CUST_NO%type;

BEGIN
	OPEN cust_no_cur;	
	FETCH cust_no_cur INTO m_cust_no;
	IF cust_no_cur%ISOPEN THEN CLOSE cust_no_cur; END IF;

	RETURN m_cust_no;

EXCEPTION 	
WHEN OTHERS THEN
 IF cust_no_cur%ISOPEN THEN CLOSE cust_no_cur; END IF;
 stbms_err.disp_err( 100082, SQLERRM );
END get_cust_no;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: load_data  -- PMS 58712
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/
    
PROCEDURE load_data(ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS

CURSOR
	record_exist_cur IS
SELECT 
	ATPM_REC_ID
FROM
	AMEX_TERM_PRIORITY_MAPPING
WHERE
	ATPM_OFF_CODE = ip_priority_def_tab(ip_index).market
AND 
	NVL(ATPM_CUST_NO,0) = NVL(IP_PRIORITY_DEF_TAB(IP_INDEX).CUST_NO,0)
AND
	ATPM_PRIORITY = ip_priority_def_tab(ip_index).priority;
	
	
TYPE record_exist_arr IS TABLE OF record_exist_cur%ROWTYPE INDEX BY BINARY_INTEGER;
record_exist_tab  record_exist_arr;

BEGIN
	
	OPEN record_exist_cur;	
		record_exist_tab.DELETE;
		FETCH record_exist_cur BULK COLLECT INTO record_exist_tab LIMIT g_rows;
		
	
	        IF record_exist_cur%ISOPEN THEN CLOSE record_exist_cur; END IF;
	        
	IF record_exist_tab.COUNT = 0 THEN
		
		INSERT INTO AMEX_TERM_PRIORITY_MAPPING(
				ATPM_REC_ID,
				ATPM_OFF_CODE,
				ATPM_CUST_NO,
				ATPM_PRIORITY,
				ATPM_TERM_CODE,
				ATPM_GRP_ID,
				ATPM_CUST_ID,
				ATPM_XL_ID)
		VALUES 		(ATPM_REC_ID.NEXTVAL,
				ip_priority_def_tab(ip_index).market,
				ip_priority_def_tab(ip_index).cust_no,
				ip_priority_def_tab(ip_index).priority,
				ip_priority_def_tab(ip_index).term_code,
				ip_priority_def_tab(ip_index).group_id,
				ip_priority_def_tab(ip_index).division,
				ip_priority_def_tab(ip_index).cmud_cmu_id);
	ELSE
		UPDATE AMEX_TERM_PRIORITY_MAPPING 
		SET 
		  ATPM_TERM_CODE = ip_priority_def_tab(ip_index).term_code 
		WHERE 
		  ATPM_OFF_CODE = ip_priority_def_tab(ip_index).market
		AND
		  NVL(ATPM_CUST_NO,0) = NVL(IP_PRIORITY_DEF_TAB(IP_INDEX).CUST_NO,0)
		AND
		  ATPM_PRIORITY = ip_priority_def_tab(ip_index).priority;
		  
	END IF;
	
						
EXCEPTION 	
	WHEN OTHERS THEN
	IF record_exist_cur%ISOPEN THEN CLOSE record_exist_cur; END IF;
	stbms_err.disp_err( 100083, SQLERRM );
END load_data;

/*-------------------------------------------------------------------------------------------------
 Procedure 	: update_priority_table  -- PMS 58712
 Purpose	: For data validation
-------------------------------------------------------------------------------------------------*/

PROCEDURE update_priority_table (ip_priority_def_tab IN priority_def_tab,ip_index IN NUMBER) AS

BEGIN

UPDATE AMEX_TERM_PRIORITY_MAPPING 
		SET 
		  ATPM_GRP_ID = ip_priority_def_tab(ip_index).Group_Id 
		WHERE 
		  ATPM_OFF_CODE = ip_priority_def_tab(ip_index).market
		AND
		  NVL(ATPM_CUST_NO,0) = NVL(IP_PRIORITY_DEF_TAB(IP_INDEX).CUST_NO,0);
	COMMIT;
	
EXCEPTION 	
	WHEN OTHERS THEN
	
	stbms_err.disp_err( 100085, SQLERRM );
		  
END update_priority_table;

/*-------------------------------------------------------------------------------------------------
	Procedure	: priority_definition  
	Purpose		:
-------------------------------------------------------------------------------------------------*/
PROCEDURE priority_definition(ip_det_id		IN  VARCHAR2,
				ip_excel_id 	IN  VARCHAR2,
				op_err_code		OUT VARCHAR2,
				op_err_msg		OUT VARCHAR2) IS 
  		
m_cmud_rec 		 priority_def_tab;

CURSOR detail_cur IS
		SELECT
			cmud_cmu_id		cmud_cmu_id, 
			cmud_id			cmud_id, 		
			cmud_data_col1		Group_Id,
			cmud_data_col2 		Grp_Seq_Id,			
			cmud_data_col3 		Market,		
			cmud_data_col4 		Division,		
			cmud_data_col5 		Priority,		
			cmud_data_col6	 	Term_Code,
			get_cust_no(cmud_data_col4)  cust_no
		FROM
			CSTM_MEGA_UPLOAD_DET		
		WHERE	
			CMUD_CMU_ID = ip_excel_id
		AND
			CMUD_ID = ip_det_id;

	detail_rec	detail_cur%ROWTYPE;

	m_index		NUMBER(10) := 1;
	--m_indx		 NUMBER(10) := 0;

BEGIN	
	
	m_cmud_rec.delete;
	clear;

	OPEN detail_cur;

		FETCH detail_cur INTO detail_rec;
		IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;

		m_cmud_rec(m_index).cmud_cmu_id			:= detail_rec.CMUD_CMU_ID;
		m_cmud_rec(m_index).cmud_id			:= detail_rec.CMUD_ID;
		m_cmud_rec(m_index).Group_Id			:= detail_rec.Group_Id;
		m_cmud_rec(m_index).Grp_Seq_Id			:= detail_rec.Grp_Seq_Id;
		m_cmud_rec(m_index).Market			:= detail_rec.Market;	
		m_cmud_rec(m_index).Division			:= detail_rec.Division;	
		m_cmud_rec(m_index).Priority		        := detail_rec.Priority;
		m_cmud_rec(m_index).Term_Code			:= detail_rec.Term_Code;
		m_cmud_rec(m_index).cust_no			:= detail_rec.cust_no;

		validate_priority_definition(m_cmud_rec,m_index);

		duplicate_check(m_cmud_rec,m_index);

		update_priority_table(m_cmud_rec,m_index);

	IF (g_err_tab.COUNT = 0) THEN	

		load_archives(m_cmud_rec,m_index);

		load_data(m_cmud_rec,m_index);	

		op_err_code := '0';
		op_err_msg  := 'Success';

		UPDATE CSTM_MEGA_UPLOAD_DET SET CMUD_STATUS = 'P'
					WHERE CMUD_CMU_ID = ip_excel_id
					AND CMUD_ID =ip_det_id;

		commit;
	ELSE 

		log_error( ip_excel_id,ip_det_id);
		op_err_code := '1';
		op_err_msg  := 'Error while Processing Priority Definition';

	END IF;			

	IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;
	      
EXCEPTION
	WHEN OTHERS THEN
	ROLLBACK;
	IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;
	Stbms_Err.disp_err (100084,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );

END priority_definition;

/*-------------------------------------------------------------------------------------------------
Procedure    : Create_Exception
Purpose      :
*-------------------------------------------------------------------------------------------------*/

PROCEDURE Create_Exception( ip_cmud_data_tab IN neg_def_tab,op_tv_uid OUT VARCHAR2,op_stv_id OUT VARCHAR2,op_stv_inh_ind OUT VARCHAR2) AS

	m_cwt_code TARIFF_VARIATION.TV_CWT_CODE%TYPE := NULL;
	
	m_tcg_code	VARCHAR2(20);
	m_template	TARIFF_SCHEME.TS_TS_CODE%type;
	m_tv_rec_id		TARIFF_VARIATION.TV_REC_ID%TYPE	:= NULL;
	m_tv_uid		TARIFF_VARIATION.TV_UID%TYPE;
	m_tv_cwt_code 		tariff_variation.TV_CWT_CODE%type;

	CURSOR 
		std_cur IS
	SELECT  
		tv_crp_code, 
		tv_msc_code, 
		tv_chc_code, 
		tv_tcg_code, 
		tv_tariff_class,
		tv_qos_code, 
		tv_tf_code, 
		tv_des, 
		tv_tg_id, 							
		tv_tarif_sch, 						
		tv_From_Date,						
		tv_To_Date, 
		tv_status, 
		tv_cwt_code, 
		tv_dwt_code, 
		tv_twt_code, 
		tv_rec_id,
		tv_personalised_yn, 
		tv_uid, 
		tv_trans_currency, 
		tv_rvw_date,
		tv_pricing_template, 
		tv_tarif_band,
		tv_rel_type,
		tv_base_uid,
		tv_rel_disc,
		tv_rel_tarif_band,
		tv_base_rec_id		
	FROM 
		TARIFF_VARIATION
	WHERE
		TV_UID = m_tv_uid
 	AND
 		TV_CWT_CODE=m_tv_cwt_code;
 		
	CURSOR 
		tc_cur IS 
	SELECT		
		tc_cwt_code,
		tc_des,
		tc_min_charge,
		tc_max_charge,
		tc_cum_type,
		tc_ann_tar_rate,
		tc_setup_charge,
		tc_cur,
		tc_rec_id,
		tc_tc_type,
		tc_interest_type,
		tc_interest_period_type,
		tc_interest_based_on,
		tc_limit_based_on,
		tc_from_date,
		tc_to_date,
		tc_status,
		tc_Rate_Type,
		tc_rvw_date,
		tc_pricing_template,
		tc_interest_comp_basis,
		tc_rate_id,
		tc_Comp_Type,
		tc_template_type,
		tc_template_instance,
		tc_free_limit_usage,
		tc_free_limit_method,
		tc_free_limit_factor,
		tc_constant_free_limit,
		tc_free_limit_comp_method,
		tc_personalised,
		tc_incl_excl_slabs
		
	FROM		
		tariff_call_scheme
	WHERE		
		tc_cwt_code = m_cwt_code;
	
	CURSOR 	tcr_cur IS
	SELECT
		tcr_cwt_code,           
		tcr_seq_no,           
		tcr_nop_lower,
		tcr_nop,
		tcr_rate,              
		tcr_applied_field,
		tcr_upper_limit,
		tcr_lower_limit,        
		tcr_Rate_Type,        
		tcr_ign_yn,        
		tcr_tc_rec_id,        		
		tcr_rel_Rate_Type,
		tcr_rel_rate,
		tcr_rel_rate_inc_dec,
		tcr_disc_Rate_Type,
		tcr_disc_rate
	FROM
		TARIFF_CALL_RATES
	WHERE
		tcr_cwt_code = m_cwt_code;
		
	CURSOR template_cur(ip_methodology VARCHAR2) IS
	SELECT
		MAX(TS_TS_CODE) TS_TS_CODE,
		MAX(TS_CUR_CODE)  TS_CUR_CODE
	FROM
		TARIFF_SCHEME
	WHERE
		TS_PRICING_TEMPLATE = ip_methodology
	AND
		TS_TEMPLATE_TYPE IS NULL;
	
	m_subs_act_no	SUBSCRIBER_MASTER.PM_SUBS_ACT_NO%TYPE;
	m_cust_no		CUSTOMER_MASTER.CM_CUST_NO%TYPE; 
	m_ts_cur_code		TARIFF_SCHEME.TS_CUR_CODE%TYPE:= NULL;
	
	CURSOR stv_id_cur(ip_rec_id IN VARCHAR2,ip_cust_no in NUMBER)IS
		SELECT 
			stv_id,stv_inh_ind,stv_uid
		FROM 
			SUBS_TARIFF_VARIATION
		WHERE 
			STV_REC_ID = ip_rec_id
		AND
			STV_CUST_NO= ip_cust_no
		AND
			STV_TG_ID = ip_cmud_data_tab(1).tv_tarif_band
		AND
		TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_from_date,g_date_format)) BETWEEN stv_from_date AND NVL(stv_to_date, STBMS_STD.HIGH_DATE);	
		
	
	CURSOR cm_cur IS
	SELECT
		cm_cust_no
	FROM
		CUSTOMER_MASTER
	WHERE
		CM_CUST_ID = ip_cmud_data_tab(1).cust_no
	AND
		CM_STATUS='A';
		
	
	CURSOR stv_up_cust_cur IS 
	SELECT 
		STV_ID,
		STV_UID,
		STV_INH_LEVEL,
		STV_INH_IND		
	FROM 
		SUBS_TARIFF_VARIATION
	WHERE 
		STV_REC_ID = m_tv_rec_id
	AND
		stv_cust_no = m_cust_no
	AND
		STV_TG_ID = ip_cmud_data_tab(1).tv_tarif_band
	AND
		STV_From_Date = TRUNC(TO_DATE(ip_cmud_data_tab(1).STV_FROM_DATE,g_date_format));	
		
	std_rec 	std_cur%ROWTYPE := NULL;
	
	tc_rec		tc_cur%ROWTYPE  := NULL;
	
	TYPE tcr_arr IS TABLE OF tcr_cur%ROWTYPE INDEX BY BINARY_INTEGER;	

	CURSOR CCUA_CUR (IP_TV_UID IN NUMBER,IP_STV_ID IN NUMBER)IS

         SELECT ccua_id,ccua_bd_code,ccua_tv_uid,ccua_cust_no,ccua_subs_act_no,ccua_stv_id,
		ccua_user1,ccua_user2,ccua_user3,ccua_user4,ccua_user5,ccua_user6,ccua_user7,
		ccua_user8,ccua_user9,ccua_user10,ccua_user11,ccua_user12,ccua_user13,
		ccua_user14,ccua_user15,ccua_user_num1,ccua_user_num2,ccua_user_num3,
		ccua_user_num4,ccua_user_num5,ccua_user_date1,ccua_user_date2,ccua_user_date3
           FROM 
           	charge_code_user_attribs
          WHERE 	
          	ccua_bd_code = ip_cmud_data_tab(1).tv_tarif_band
          AND
          	ccua_tv_uid  = IP_TV_UID
          AND
          	ccua_cust_no = m_cust_no
          AND
          	ccua_subs_act_no IS NULL
          AND
          	ccua_stv_id = IP_STV_ID;
          	
	CURSOR stv_tv_cur IS
	SELECT
		to_number(tv_uid) tv_uid,
		to_number(tv_tarif_sch) tv_tarif_sch,
		to_number(tv_cwt_code) 	tv_cwt_code	
	FROM
		TARIFF_VARIATION
	WHERE
		NVL(tv_tarif_band ,'$$') = NVL(ip_cmud_data_tab(1).TV_TARIF_BAND,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).TV_TCG_CODE,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		NVL(tv_qos_code ,'$$') = NVL(ip_cmud_data_tab(1).tv_qos_code,'$$')
	--AND
	--	NVL(tv_pricing_template ,0) = NVL(ip_cmud_data_tab(1).tv_pricing_template,0)
	AND
		NVL(tv_crp_code ,'$$') = 'REG'
	AND
		NVL(tv_msc_code ,'$$') = 'DEF'
	AND
		NVL(tv_chc_code ,'$$') = 'DEF'
	AND
		--TRUNC(TO_DATE(ip_cmud_data_tab(1).TV_FROM_DATE,g_date_format)) BETWEEN tv_from_date AND NVL(tv_to_date, STBMS_STD.HIGH_DATE);
		TRUNC(TO_DATE(ip_cmud_data_tab(1).STV_FROM_DATE,g_date_format)) >= trunc(tv_from_date)
	AND
		--TRUNC(TO_DATE(nvl(ip_cmud_data_tab(1).STV_TO_DATE,STBMS_STD.HIGH_DATE),g_date_format)) <= NVL(tv_to_date, STBMS_STD.HIGH_DATE) ;
		TRUNC(NVL(TO_DATE(ip_cmud_data_tab(1).STV_TO_DATE,g_date_format),STBMS_STD.HIGH_DATE)) <= trunc(NVL(tv_to_date, STBMS_STD.HIGH_DATE)) ;

	CURSOR stv_tv_cur_dummy IS
	SELECT
		to_number(tv_uid) tv_uid,
		to_number(tv_tarif_sch) tv_tarif_sch,
		to_number(tv_cwt_code) 	tv_cwt_code	
	FROM
		TARIFF_VARIATION
	WHERE
		NVL(tv_tarif_band ,'$$') = NVL(ip_cmud_data_tab(1).TV_TARIF_BAND,'$$')
	AND
		NVL(tv_tcg_code,'$$') = NVL(ip_cmud_data_tab(1).TV_TCG_CODE,'$$')
	AND
		NVL(tv_tariff_class ,'$$') = NVL(ip_cmud_data_tab(1).tv_tariff_class,'$$')
	AND
		tv_qos_code IS NULL
	AND
		tv_tf_code IS NULL
	AND
		NVL(tv_crp_code ,'$$') = 'REG'
	AND
		NVL(tv_msc_code ,'$$') = 'DEF'
	AND
		NVL(tv_chc_code ,'$$') = 'DEF'
	AND
		TRUNC(TO_DATE(ip_cmud_data_tab(1).STV_FROM_DATE,g_date_format)) >= trunc(tv_from_date)
	AND
		TRUNC(NVL(TO_DATE(ip_cmud_data_tab(1).STV_TO_DATE,g_date_format),STBMS_STD.HIGH_DATE)) <= trunc(NVL(tv_to_date, STBMS_STD.HIGH_DATE)) ;

	
	m_ccua 	CCUA_CUR%ROWTYPE;	
	tcr_tab				tcr_arr;
	m_count				NUMBER(5)	:= 0;
	m_operation 		VARCHAR2(2)	:= 'I' ;
	m_err_msg			err_return_api;
	m_tc_cwt_code 		TARIFF_CALL_SCHEME.TC_CWT_CODE%TYPE;
	m_tcr_count			NUMBER(5)	:= 0;
	m_stv_up_count	NUMBER(5)	:= 0;
	m_tcr				tcr_cur%ROWTYPE;
	m_stv_upd			stv_up_cust_cur%ROWTYPE;
	m_stv				stv_id_cur%ROWTYPE;
	m_comp_type		VARCHAR2(20);
	m_stv_id		subs_tariff_variation.stv_id%TYPE;
	m_stv_rec_id		subs_tariff_variation.stv_rec_id%TYPE;
	m_tariff_var_obj 		tariff_variation_api_obj 		:= tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	m_tariff_variation_array   	tariff_variation_api_obj_array  	:= tariff_variation_api_obj_array(tariff_variation_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));

	m_tv_tariff_sch tariff_variation.TV_TARIF_SCH%type;
	m_charge_code_user_attr	 ccua_api_obj := ccua_api_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	m_dummy_flag VARCHAR2(1) := 'N';

	
BEGIN

	m_template := null;
	IF ip_cmud_data_tab(1).tv_pricing_template IS NOT NULL THEN
		
		OPEN template_cur(ip_cmud_data_tab(1).tv_pricing_template);
			FETCH template_cur INTO m_template,m_ts_cur_code;
		IF template_cur%ISOPEN THEN CLOSE template_cur; END IF;
	END IF;
	
	open cm_cur;
	fetch cm_cur into m_cust_no;
	IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF;	
	clearTariff;
	

	OPEN stv_tv_cur;
		FETCH stv_tv_cur INTO m_tv_uid,m_tv_tariff_sch,m_tv_cwt_code;
	
	--PMS 63141
	IF stv_tv_cur%NOTFOUND THEN
		
		m_dummy_flag := 'Y';
		
		OPEN stv_tv_cur_dummy;
			FETCH stv_tv_cur_dummy INTO m_tv_uid,m_tv_tariff_sch,m_tv_cwt_code;
		IF stv_tv_cur_dummy%ISOPEN THEN CLOSE stv_tv_cur_dummy; END IF;
	
	END IF;
	IF stv_tv_cur%ISOPEN THEN CLOSE stv_tv_cur; END IF;
	
	IF m_tv_uid IS NULL THEN
		load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P30003','Standard Definition is not available for the Term Code '||ip_cmud_data_tab(1).TV_TARIF_BAND||', Function Code '||ip_cmud_data_tab(1).tv_tariff_class||', Client Fee/Traveller fee '||ip_cmud_data_tab(1).tv_qos_code,'P');
		RETURN;
	END IF;				

	
	OPEN std_cur;

	FETCH std_cur INTO std_rec;

	IF std_cur%FOUND THEN

		m_cwt_code := std_rec.tv_cwt_code;

		tariff_var_obj.TV_CRP_CODE	     := std_rec.TV_CRP_CODE;
		tariff_var_obj.TV_MSC_CODE	     := std_rec.TV_MSC_CODE;
		tariff_var_obj.TV_CHC_CODE           := std_rec.TV_CHC_CODE;
		tariff_var_obj.TV_TCG_CODE           := std_rec.TV_TCG_CODE;
		--tariff_var_obj.TV_TARIFF_CLASS       := std_rec.TV_TARIFF_CLASS;
		--tariff_var_obj.TV_QOS_CODE           := std_rec.TV_QOS_CODE;
		tariff_var_obj.TV_TARIFF_CLASS       := ip_cmud_data_tab(1).tv_tariff_class;
		tariff_var_obj.TV_QOS_CODE           := ip_cmud_data_tab(1).tv_qos_code;
		tariff_var_obj.TV_TF_CODE            := std_rec.TV_TF_CODE ;
		tariff_var_obj.TV_DES                := std_rec.TV_DES;
		tariff_var_obj.TV_TG_ID              := std_rec.TV_TG_ID;
		tariff_var_obj.TV_TARIF_SCH          := std_rec.TV_TARIF_SCH;
		tariff_var_obj.TV_FROM_DATE          := std_rec.TV_FROM_DATE;
		tariff_var_obj.TV_TO_DATE            := std_rec.TV_TO_DATE;
		tariff_var_obj.TV_STATUS             := std_rec.TV_STATUS;
		tariff_var_obj.TV_CWT_CODE           := std_rec.TV_CWT_CODE;
		tariff_var_obj.TV_DWT_CODE           := std_rec.TV_DWT_CODE;
		tariff_var_obj.TV_TWT_CODE           := std_rec.TV_TWT_CODE;
		tariff_var_obj.TV_TRANS_CURRENCY     := std_rec.TV_TRANS_CURRENCY;
		tariff_var_obj.TV_RVW_DATE           := std_rec.TV_RVW_DATE;
		tariff_var_obj.TV_PRICING_TEMPLATE   := std_rec.TV_PRICING_TEMPLATE;
		tariff_var_obj.tv_personalised_yn    := std_rec.tv_personalised_yn;
		tariff_var_obj.tv_tarif_band	     := std_rec.tv_tarif_band;			


		IF m_dummy_flag = 'Y' THEN
			tariff_var_obj.TV_REC_ID             := null;
			tariff_var_obj.TV_UID                := null;
			tariff_var_obj.TV_PRICING_TEMPLATE   := ip_cmud_data_tab(1).tv_pricing_template;
		ELSE
			tariff_var_obj.TV_REC_ID             := std_rec.TV_REC_ID;
			tariff_var_obj.TV_UID                := std_rec.TV_UID;
		END IF;

		op_tv_uid 	:= tariff_var_obj.TV_UID ;	
		m_tv_rec_id 	:= tariff_var_obj.TV_REC_ID;
		
	
	END IF;
	
		IF std_cur%ISOPEN THEN CLOSE std_cur; END IF;
	
		IF m_cwt_code IS NULL THEN
			load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P30003','Standard Definition is not available for the Term Code '||ip_cmud_data_tab(1).TV_TARIF_BAND||', Function Code '||ip_cmud_data_tab(1).tv_tariff_class||', Client Fee/Traveller fee '||ip_cmud_data_tab(1).tv_qos_code,'P');
			RETURN;
		ELSE

	
			OPEN tc_cur;
			FETCH tc_cur INTO tc_rec;
			
			IF tc_cur%ISOPEN THEN CLOSE tc_cur; END IF;
		
			tariff_call_scheme_array	:=  call_scheme_api_obj_array(tariff_call_scheme_obj);
			
			tariff_call_scheme_array.extend;
			
			m_tc_cwt_code := stbms_cmn.sun_seq_no ('TC_CWT_CODE');
			
			tariff_call_scheme_array(1).tc_cwt_code  		:= m_tc_cwt_code;
			tariff_call_scheme_array(1).tc_des              	:= tc_rec.tc_des;
			tariff_call_scheme_array(1).tc_min_charge 		:= tc_rec.tc_min_charge;
			tariff_call_scheme_array(1).tc_max_charge 		:= tc_rec.tc_max_charge;
			tariff_call_scheme_array(1).tc_setup_charge 		:= tc_rec.tc_setup_charge;
			tariff_call_scheme_array(1).tc_ann_tar_rate 		:= tc_rec.tc_ann_tar_rate;
			tariff_call_scheme_array(1).tc_tc_type 			:= tc_rec.tc_tc_type;
			tariff_call_scheme_array(1).tc_interest_comp_basis 	:= tc_rec.tc_interest_comp_basis;
			tariff_call_scheme_array(1).tc_interest_type 		:= tc_rec.tc_interest_type;
			tariff_call_scheme_array(1).tc_interest_period_type 	:= tc_rec.tc_interest_period_type;
			tariff_call_scheme_array(1).tc_interest_based_on 	:= tc_rec.tc_interest_based_on;
			tariff_call_scheme_array(1).tc_limit_based_on 		:= tc_rec.tc_limit_based_on;
			tariff_call_scheme_array(1).tc_personalised 		:= tc_rec.tc_personalised;
			tariff_call_scheme_array(1).tc_rate_id           	:= tc_rec.tc_rate_id;
			tariff_call_scheme_array(1).tc_cur               	:= nvl(m_ts_cur_code,tc_rec.tc_cur);
			tariff_call_scheme_array(1).tc_rec_id 			:= null;

			tariff_call_scheme_array(1).tc_from_date            	:= TO_DATE(ip_cmud_data_tab(1).stv_from_date,g_date_format);
			tariff_call_scheme_array(1).tc_to_date              	:= TO_DATE(ip_cmud_data_tab(1).stv_to_date,g_date_format);
			tariff_call_scheme_array(1).tc_status               	:= 'A';
			tariff_call_scheme_array(1).tc_rvw_date             	:= '';
			tariff_call_scheme_array(1).tc_cum_type             	:= tc_rec.tc_cum_type;
			tariff_call_scheme_array(1).tc_rate_type		:= ip_cmud_data_tab(1).tc_rate_type;		
			tariff_call_scheme_array(1).tc_pricing_template 	:= ip_cmud_data_tab(1).tv_pricing_template;
			
			OPEN tcr_cur;
			FETCH tcr_cur INTO m_tcr;		
			IF tcr_cur%ISOPEN THEN CLOSE tcr_cur; END IF;

			FOR i IN 1..ip_cmud_data_tab.COUNT LOOP				
			
				IF i<>1 THEN			
					tariff_call_scheme_array(1).rates_array.extend;	
				END IF;
				
				m_count := m_count+1;
				
				tariff_call_rates_obj.tcr_cwt_code		:= tariff_call_scheme_array(1).TC_CWT_CODE;
				tariff_call_rates_obj.tcr_seq_no 		:= m_tcr_count; 
				tariff_call_rates_obj.tcr_cwt_code 		:= tariff_call_scheme_array(1).TC_CWT_CODE;
				tariff_call_rates_obj.tcr_tc_rec_id 		:= tariff_call_scheme_array(1).TC_REC_ID;
				tariff_call_rates_obj.tcr_ign_yn 		:= m_tcr.tcr_ign_yn;	
				tariff_call_rates_obj.tcr_upper_limit 		:= m_tcr.tcr_upper_limit;
				tariff_call_rates_obj.tcr_lower_limit 		:= m_tcr.tcr_lower_limit;		
				tariff_call_rates_obj.tcr_rel_Rate_Type 	:= m_tcr.tcr_rel_Rate_Type;	
				tariff_call_rates_obj.tcr_rel_rate 		:= m_tcr.tcr_rel_rate;
				tariff_call_rates_obj.tcr_rel_rate_inc_dec  	:= m_tcr.tcr_rel_rate_inc_dec;
				tariff_call_rates_obj.tcr_disc_Rate_Type	:= m_tcr.tcr_disc_Rate_Type;
				tariff_call_rates_obj.tcr_disc_rate		:= m_tcr.tcr_disc_rate;
				tariff_call_rates_obj.tcr_nop 			:= ip_cmud_data_tab(i).Tier_To;
				tariff_call_rates_obj.tcr_nop_lower 		:= ip_cmud_data_tab(i).Tier_From;
				tariff_call_rates_obj.tcr_rate	 		:= ip_cmud_data_tab(i).rate;
				tariff_call_rates_obj.tcr_Rate_Type 		:= m_tcr.tcr_Rate_Type;
				m_tcr_count 					:= m_tcr_count+1;
				
				tariff_call_scheme_array(1).rates_array(m_count) := tariff_call_rates_obj;
				
			END LOOP;
			
		END IF;
		
	IF m_dummy_flag = 'N' THEN
	
		OPEN stv_up_cust_cur;
		FETCH stv_up_cust_cur INTO m_stv_upd;

		IF(stv_up_cust_cur%FOUND )THEN

			m_operation := 'U';

			subs_tariff_var_obj.STV_REC_ID    	:= std_rec.TV_REC_ID;
			subs_tariff_var_obj.STV_CUST_NO    	:= m_cust_no;
			subs_tariff_var_obj.STV_SUBS_ACT_NO  	:=  '';
			subs_tariff_var_obj.STV_TG_ID        	:= std_rec.TV_TG_ID;	
			subs_tariff_var_obj.STV_TARIF_SCH    	:= NVL(m_template,std_rec.TV_TARIF_SCH);
			subs_tariff_var_obj.STV_TV_CWT_CODE     := std_rec.TV_CWT_CODE;
			subs_tariff_var_obj.STV_CWT_CODE     	:= tariff_call_scheme_array(1).TC_CWT_CODE;
			--subs_tariff_var_obj.STV_DWT_CODE     	:= std_rec.TV_DWT_CODE;
			--subs_tariff_var_obj.STV_TWT_CODE     	:= std_rec.TV_TWT_CODE;
			subs_tariff_var_obj.STV_From_Date    	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_from_date,g_date_format));
			subs_tariff_var_obj.STV_To_Date     	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_to_date,g_date_format));
			subs_tariff_var_obj.STV_DES          	:= std_rec.TV_DES;
			subs_tariff_var_obj.STV_ID		:= m_stv_upd.STV_ID;
			subs_tariff_var_obj.STV_UID          	:= m_stv_upd.STV_UID;
			subs_tariff_var_obj.STV_TARIF_BAND   	:= tariff_var_obj.TV_TARIF_BAND;
			subs_tariff_var_obj.STV_INH_LEVEL    	:= m_stv_upd.STV_INH_LEVEL;
			subs_tariff_var_obj.STV_INH_IND      	:= m_stv_upd.STV_INH_IND;

		else
			m_operation := 'I';

			IF m_dummy_flag = 'Y' THEN
				subs_tariff_var_obj.STV_REC_ID    	:= null;
				subs_tariff_var_obj.STV_UID          	:= null;
			ELSE
				subs_tariff_var_obj.STV_REC_ID    	:= std_rec.TV_REC_ID;
				subs_tariff_var_obj.STV_UID          	:= std_rec.TV_UID;		
			END IF;

			subs_tariff_var_obj.STV_CUST_NO    	:= m_cust_no;
			subs_tariff_var_obj.STV_SUBS_ACT_NO  	:=  '';
			subs_tariff_var_obj.STV_TG_ID        	:= std_rec.TV_TG_ID;	
			subs_tariff_var_obj.STV_TARIF_SCH    	:= NVL(m_template,std_rec.TV_TARIF_SCH);
			subs_tariff_var_obj.STV_TV_CWT_CODE     := std_rec.TV_CWT_CODE;
			subs_tariff_var_obj.STV_CWT_CODE     	:= tariff_call_scheme_array(1).TC_CWT_CODE;
			subs_tariff_var_obj.STV_DWT_CODE     	:= std_rec.TV_DWT_CODE;
			subs_tariff_var_obj.STV_TWT_CODE     	:= std_rec.TV_TWT_CODE;
			subs_tariff_var_obj.STV_From_Date    	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_from_date,g_date_format));
			subs_tariff_var_obj.STV_To_Date     	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_to_date,g_date_format));
			subs_tariff_var_obj.STV_DES          	:= tariff_var_obj.TV_DES;
			subs_tariff_var_obj.STV_ID		:= NULL;
			subs_tariff_var_obj.STV_TARIF_BAND   	:= tariff_var_obj.TV_TARIF_BAND;
			subs_tariff_var_obj.STV_INH_LEVEL    	:= NULL;
			subs_tariff_var_obj.STV_INH_IND      	:= '';


		end if;

		IF stv_up_cust_cur%ISOPEN THEN CLOSE stv_up_cust_cur; END IF;
	ELSE
	
		m_operation := 'I';

		subs_tariff_var_obj.STV_REC_ID    	:= null;
		subs_tariff_var_obj.STV_UID          	:= null;

		subs_tariff_var_obj.STV_CUST_NO    	:= m_cust_no;
		subs_tariff_var_obj.STV_SUBS_ACT_NO  	:=  '';
		subs_tariff_var_obj.STV_TG_ID        	:= std_rec.TV_TG_ID;	
		subs_tariff_var_obj.STV_TARIF_SCH    	:= NVL(m_template,std_rec.TV_TARIF_SCH);
		subs_tariff_var_obj.STV_TV_CWT_CODE     := std_rec.TV_CWT_CODE;
		subs_tariff_var_obj.STV_CWT_CODE     	:= tariff_call_scheme_array(1).TC_CWT_CODE;
		subs_tariff_var_obj.STV_DWT_CODE     	:= std_rec.TV_DWT_CODE;
		subs_tariff_var_obj.STV_TWT_CODE     	:= std_rec.TV_TWT_CODE;
		subs_tariff_var_obj.STV_From_Date    	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_from_date,g_date_format));
		subs_tariff_var_obj.STV_To_Date     	:= TRUNC(TO_DATE(ip_cmud_data_tab(1).stv_to_date,g_date_format));
		subs_tariff_var_obj.STV_DES          	:= tariff_var_obj.TV_DES;
		subs_tariff_var_obj.STV_ID		:= NULL;
		subs_tariff_var_obj.STV_TARIF_BAND   	:= tariff_var_obj.TV_TARIF_BAND;
		subs_tariff_var_obj.STV_INH_LEVEL    	:= NULL;
		subs_tariff_var_obj.STV_INH_IND      	:= '';

	END IF;
		

	subs_tariff_var := Price_List_Api.ProcessSubsTariffVariation(subs_tariff_var_obj,
								 tariff_var_obj,
								 tariff_call_scheme_array,
								 m_operation,
								 'N',
								 --security.get_staff_id,
								 null,
								 m_err_msg);


	IF m_err_msg.err_code IS NOT NULL THEN
	    load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P30004-'||m_err_msg.err_code,m_err_msg.err_msg);
		RETURN;					
	END IF;
	
	if subs_tariff_var.COUNT > 0 THEN	

		m_stv_rec_id	:=  subs_tariff_var(1).stv_rec_id;
						
		OPEN stv_id_cur(m_stv_rec_id,m_cust_no);
		FETCH stv_id_cur INTO m_stv;

		m_stv_id  	:=  m_stv.stv_id;
		
		IF stv_id_cur%ISOPEN THEN CLOSE stv_id_cur; END IF;
		
		op_stv_id := m_stv_id;	
		op_stv_inh_ind := m_stv.stv_inh_ind;

		/*Loading Charge Code user Attributes*/
		OPEN ccua_cur(m_stv.STV_UID,m_stv_id);
		FETCH ccua_cur INTO m_ccua;
		IF ccua_cur%FOUND THEN

			m_operation :='U';

			charge_code_user_attr.ccua_id		:= m_ccua.ccua_id;
			charge_code_user_attr.ccua_bd_code	:= m_ccua.ccua_bd_code;
			charge_code_user_attr.ccua_tv_uid	:= m_ccua.ccua_tv_uid;
			charge_code_user_attr.ccua_cust_no	:= m_ccua.ccua_cust_no;
			charge_code_user_attr.ccua_subs_act_no	:= m_ccua.ccua_subs_act_no;
			charge_code_user_attr.ccua_stv_id	:= m_ccua.ccua_stv_id;
			charge_code_user_attr.ccua_user1		:= m_ccua.ccua_user1;
			charge_code_user_attr.ccua_user2		:= m_ccua.ccua_user2;
			charge_code_user_attr.ccua_user3		:= m_ccua.ccua_user3;
			charge_code_user_attr.ccua_user4		:= ip_cmud_data_tab(1).cmud_data_col23;
			charge_code_user_attr.ccua_user5		:= m_ccua.ccua_user5; 
			charge_code_user_attr.ccua_user6		:= m_ccua.ccua_user6; 
			charge_code_user_attr.ccua_user7		:= m_ccua.ccua_user7; 
			charge_code_user_attr.ccua_user8		:= m_ccua.ccua_user8; 
			charge_code_user_attr.ccua_user9		:= m_ccua.ccua_user9; 
			charge_code_user_attr.ccua_user10		:= m_ccua.ccua_user10; 
			charge_code_user_attr.ccua_user11		:= ip_cmud_data_tab(1).cmud_data_col20;
			charge_code_user_attr.ccua_user12		:= ip_cmud_data_tab(1).cmud_data_col19;
			charge_code_user_attr.ccua_user13		:= ip_cmud_data_tab(1).cmud_data_col21;
			charge_code_user_attr.ccua_user14		:= m_ccua.ccua_user14; 
			charge_code_user_attr.ccua_user15		:= m_ccua.ccua_user15; 
			charge_code_user_attr.ccua_user_num1		:= ip_cmud_data_tab(1).cmud_data_col24;
			charge_code_user_attr.ccua_user_num2		:= m_ccua.ccua_user_num2;
			charge_code_user_attr.ccua_user_num3		:= m_ccua.ccua_user_num3; 
			charge_code_user_attr.ccua_user_num4		:= m_ccua.ccua_user_num4; 
			charge_code_user_attr.ccua_user_num5		:= ip_cmud_data_tab(1).cmud_data_col22; 
			charge_code_user_attr.ccua_user_date1	:= m_ccua.ccua_user_date1; 
			charge_code_user_attr.ccua_user_date2	:= m_ccua.ccua_user_date2; 
			charge_code_user_attr.ccua_user_date3	:= m_ccua.ccua_user_date3; 

		ELSE

			m_operation :='I';
			charge_code_user_attr.ccua_id		:= stbms_cmn.sun_seq_no ('CCUA_ID');
			charge_code_user_attr.ccua_bd_code	:= ip_cmud_data_tab(1).tv_tarif_band;
			charge_code_user_attr.ccua_tv_uid	:= m_stv.STV_UID;
			charge_code_user_attr.ccua_cust_no	:= m_cust_no;
			charge_code_user_attr.ccua_subs_act_no	:= '';
			charge_code_user_attr.ccua_stv_id	:= m_stv.stv_id;
			charge_code_user_attr.ccua_user1		:=''; 
			charge_code_user_attr.ccua_user2		:=''; 
			charge_code_user_attr.ccua_user3		:=''; 
			charge_code_user_attr.ccua_user4		:= ip_cmud_data_tab(1).cmud_data_col23;
			charge_code_user_attr.ccua_user5		:=''; 
			charge_code_user_attr.ccua_user6		:=''; 
			charge_code_user_attr.ccua_user7		:=''; 
			charge_code_user_attr.ccua_user8		:=''; 
			charge_code_user_attr.ccua_user9		:=''; 
			charge_code_user_attr.ccua_user10		:=''; 
			charge_code_user_attr.ccua_user11		:= ip_cmud_data_tab(1).cmud_data_col20;
			charge_code_user_attr.ccua_user12		:= ip_cmud_data_tab(1).cmud_data_col19;
			charge_code_user_attr.ccua_user13		:= ip_cmud_data_tab(1).cmud_data_col21;
			charge_code_user_attr.ccua_user14		:=''; 
			charge_code_user_attr.ccua_user15		:=''; 
			charge_code_user_attr.ccua_user_num1		:= ip_cmud_data_tab(1).cmud_data_col24; 
			charge_code_user_attr.ccua_user_num2		:= null;
			charge_code_user_attr.ccua_user_num3		:= null; 
			charge_code_user_attr.ccua_user_num4		:= null; 
			charge_code_user_attr.ccua_user_num5		:= ip_cmud_data_tab(1).cmud_data_col22; 
			charge_code_user_attr.ccua_user_date1	:= null; 
			charge_code_user_attr.ccua_user_date2	:= null; 
			charge_code_user_attr.ccua_user_date3	:= null; 
		END IF;
		IF ccua_cur%ISOPEN THEN CLOSE ccua_cur; END IF;

		m_charge_code_user_attr	:= Price_List_Api.processchargecodeuserattr(charge_code_user_attr,m_operation,'N',null,m_err_msg);

		IF m_err_msg.err_code IS NOT NULL THEN
		    load_err(ip_cmud_data_tab(1).cmud_cmu_id,ip_cmud_data_tab(1).cmud_id,'P30005-'||m_err_msg.err_code,m_err_msg.err_msg);
			RETURN;					
		END IF;
			
					
	END IF;
	
	IF stv_id_cur%ISOPEN THEN CLOSE stv_id_cur; END IF;
 	IF std_cur%ISOPEN THEN CLOSE std_cur; END IF;
	IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF; 

EXCEPTION
	WHEN OTHERS THEN
		IF cm_cur%ISOPEN THEN CLOSE cm_cur; END IF; 
		IF std_cur%ISOPEN THEN CLOSE std_cur; END IF;
		IF stv_up_cust_cur%ISOPEN THEN CLOSE stv_up_cust_cur; END IF;		
		IF tc_cur%ISOPEN THEN CLOSE tc_cur; END IF;
		IF stv_id_cur%ISOPEN THEN CLOSE stv_id_cur; END IF;
		IF ccua_cur%ISOPEN THEN CLOSE ccua_cur; END IF;
		IF stv_tv_cur%ISOPEN THEN CLOSE stv_tv_cur; END IF;
		IF tcr_cur%ISOPEN THEN CLOSE tcr_cur; END IF;
		 IF template_cur%ISOPEN THEN CLOSE template_cur; END IF;
		 IF stv_tv_cur_dummy%ISOPEN THEN CLOSE stv_tv_cur_dummy; END IF;

		ROLLBACK;
			Stbms_Err.disp_err (100030,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );
END Create_Exception;

/*-------------------------------------------------------------------------------------------------
	Procedure	: negotiated_pricelist_grp  
	Purpose		:
-------------------------------------------------------------------------------------------------*/

PROCEDURE negotiated_pricelist_grp(ip_group_id			IN  VARCHAR2,
				ip_excel_id 			IN  VARCHAR2,
				op_tv_uid 			OUT VARCHAR2, 
				op_act_id 			OUT VARCHAR2,							  	 
				op_cust_id 			OUT VARCHAR2,
				op_eff_from_date		OUT VARCHAR2,
				op_eff_to_date			OUT VARCHAR2,
				op_stv_id			OUT VARCHAR2,
				op_stv_inh_ind			OUT VARCHAR2,
				op_err_code			OUT VARCHAR2,
				op_err_msg			OUT VARCHAR2) IS 
			
	m_cmud_rec 	neg_def_tab;
	m_cmud_curr_rec  neg_def_tab;

	CURSOR detail_cur IS
			SELECT
				cmud_cmu_id,
				cmud_id,
				cmud_data_col1 fun_grp_id,
				cmud_data_col2 fun_grp_seq,
				cmud_data_col3 country,
				cmud_data_col4 tv_tcg_code,
				cmud_data_col5 cust_no,
				cmud_data_col6 TV_TARIF_BAND,
				cmud_data_col7 gbt_des,
				cmud_data_col8 tc_rate_type,
				cmud_data_col9 tier_from,	
				cmud_data_col10 tier_to,
				cmud_data_col11 rate,
				cmud_data_col12	tv_pricing_template,
				cmud_data_col13	ts_des ,
				cmud_data_col14	tv_tariff_class,
				cmud_data_col15	tv_qos_code,
				cmud_data_col16 tv_trans_currency,
				cmud_data_col17 stv_from_date,
				cmud_data_col18 stv_to_date,
				cmud_data_col19 ,
				cmud_data_col20 ,
				cmud_data_col21 ,
				cmud_data_col22 ,
				cmud_data_col23 ,
				cmud_data_col24 ,
				cmud_data_col25 ,
				cmud_data_col26 ,
				cmud_data_col27 ,
				cmud_data_col28 ,
				cmud_data_col29 ,
				cmud_data_col30 ,
				cmud_data_col31	,	
				cmud_data_col32	,
				cmud_data_col33	,
				cmud_data_col34	,
				cmud_data_col35	,
				cmud_data_col36	,
				cmud_data_col37	, 
				cmud_data_col38	,
				cmud_data_col39	,
				cmud_data_col40	,
				cmud_data_col41	,
				cmud_data_col42	,
				cmud_data_col43	,
				cmud_data_col44	,
				cmud_data_col45	,
				cmud_data_col46 ,
				cmud_data_col47 ,
				CMUD_STATUS status
			FROM
				CSTM_MEGA_UPLOAD_DET		
			WHERE	
				CMUD_CMU_ID = ip_excel_id
			AND
				cmud_data_col1 = ip_group_id
			ORDER BY 
				to_number(cmud_data_col2);


	TYPE detail_arr	IS TABLE of detail_cur%ROWTYPE INDEX BY BINARY_INTEGER;

	detail_tab	 detail_arr;

	m_index		 NUMBER(10) := 0;
	m_indx		 NUMBER(10) := 0; 

	m_Tier_From	 VARCHAR2(25);
	m_Tier_To	 VARCHAR2(25);

	m_rate		 NUMBER(18,10) := 0;
	
	m_client_id	CUSTOMER_MASTER.CM_CUST_ID%TYPE;
	m_rate_type     varchar2(1);
BEGIN

	g_cmud_id_tab_type.DELETE;
	g_grp_seq_tab_type.DELETE;
	
	g_tcg_tab.DELETE;
	
	OPEN detail_cur;
	
	LOOP

		detail_tab.DELETE;

		FETCH detail_cur BULK COLLECT INTO detail_tab;
		EXIT WHEN detail_tab.COUNT=0;

		--IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;

		FOR i IN 1..detail_tab.COUNT LOOP

			m_index := m_index+1;
			m_indx  := g_cmud_id_tab_type.COUNT + 1;

			g_cmud_id_tab_type(m_indx) 	:= detail_tab(i).CMUD_ID;

			m_Tier_From := TRIM(UPPER(detail_tab(i).tier_from));
			m_Tier_To   := TRIM(UPPER(detail_tab(i).tier_to));

			m_cmud_rec(m_index).CMUD_CMU_ID		:= detail_tab(i).CMUD_CMU_ID;
			m_cmud_rec(m_index).CMUD_ID		:= detail_tab(i).CMUD_ID;
			m_cmud_rec(m_index).group_id		:= detail_tab(i).fun_grp_id;		
			m_cmud_rec(m_index).grp_seq_id		:= detail_tab(i).fun_grp_seq;
			m_cmud_rec(m_index).country		:= detail_tab(i).country;
			m_cmud_rec(m_index).tv_tcg_code		:= detail_tab(i).tv_tcg_code;
			m_cmud_rec(m_index).cust_no		:= detail_tab(i).cust_no;
			m_cmud_rec(m_index).tv_tarif_band	:= detail_tab(i).tv_tarif_band;
			m_cmud_rec(m_index).gbt_des		:= detail_tab(i).gbt_des;
			--m_cmud_rec(m_index).tc_rate_type	:= detail_tab(i).tc_rate_type;
			m_cmud_rec(m_index).tc_rate_type	:= CASE WHEN detail_tab(i).tc_rate_type = 'Rate' THEN 'R' WHEN detail_tab(i).tc_rate_type = 'Percentage' THEN 'P' ELSE detail_tab(i).tc_rate_type END;
			m_cmud_rec(m_index).tier_from		:= detail_tab(i).tier_from;
			m_cmud_rec(m_index).tier_to		:= detail_tab(i).tier_to;

			m_rate 		:= detail_tab(i).rate;
			m_rate_type	:= m_cmud_rec(1).tc_rate_type;

			IF(m_rate_type = 'P') THEN
				m_cmud_rec(m_index).rate		:= m_rate/100;
			ELSE
				m_cmud_rec(m_index).rate		:= detail_tab(i).rate;
			END IF;

			m_cmud_rec(m_index).tv_pricing_template	:= detail_tab(i).tv_pricing_template;
			m_cmud_rec(m_index).ts_des 		:= detail_tab(i).ts_des ;
			m_cmud_rec(m_index).tv_tariff_class	:= detail_tab(i).tv_tariff_class;
			m_cmud_rec(m_index).tv_qos_code		:= detail_tab(i).tv_qos_code;
			m_cmud_rec(m_index).tv_trans_currency	:= detail_tab(i).tv_trans_currency;
			m_cmud_rec(m_index).stv_from_date	:= detail_tab(i).stv_from_date;
			m_cmud_rec(m_index).stv_to_date		:= detail_tab(i).stv_to_date;
			m_cmud_rec(m_index).cmud_data_col19	:= detail_tab(i).cmud_data_col19;
			m_cmud_rec(m_index).cmud_data_col20	:= detail_tab(i).cmud_data_col20;
			m_cmud_rec(m_index).cmud_data_col21	:= detail_tab(i).cmud_data_col21;
			m_cmud_rec(m_index).cmud_data_col22	:= detail_tab(i).cmud_data_col22;
			m_cmud_rec(m_index).cmud_data_col23	:= detail_tab(i).cmud_data_col23;
			m_cmud_rec(m_index).cmud_data_col24	:= detail_tab(i).cmud_data_col24;
			m_cmud_rec(m_index).cmud_data_col25	:= detail_tab(i).cmud_data_col25;
			m_cmud_rec(m_index).cmud_data_col26	:= detail_tab(i).cmud_data_col26;
			m_cmud_rec(m_index).cmud_data_col27	:= detail_tab(i).cmud_data_col27;
			m_cmud_rec(m_index).cmud_data_col28	:= detail_tab(i).cmud_data_col28;
			m_cmud_rec(m_index).cmud_data_col29	:= detail_tab(i).cmud_data_col29;
			m_cmud_rec(m_index).cmud_data_col30	:= detail_tab(i).cmud_data_col30;
			m_cmud_rec(m_index).cmud_data_col31	:= detail_tab(i).cmud_data_col31;
			m_cmud_rec(m_index).cmud_data_col32	:= detail_tab(i).cmud_data_col32;
			m_cmud_rec(m_index).cmud_data_col33	:= detail_tab(i).cmud_data_col33;
			m_cmud_rec(m_index).cmud_data_col34	:= detail_tab(i).cmud_data_col34;
			m_cmud_rec(m_index).cmud_data_col35	:= detail_tab(i).cmud_data_col35;
			m_cmud_rec(m_index).cmud_data_col36	:= detail_tab(i).cmud_data_col36;
			m_cmud_rec(m_index).cmud_data_col37	:= detail_tab(i).cmud_data_col37;
			m_cmud_rec(m_index).cmud_data_col38	:= detail_tab(i).cmud_data_col38;
			m_cmud_rec(m_index).cmud_data_col39	:= detail_tab(i).cmud_data_col39;
			m_cmud_rec(m_index).cmud_data_col40	:= detail_tab(i).cmud_data_col40;
			m_cmud_rec(m_index).cmud_data_col41	:= detail_tab(i).cmud_data_col41;
			m_cmud_rec(m_index).cmud_data_col42	:= detail_tab(i).cmud_data_col42;
			m_cmud_rec(m_index).cmud_data_col43	:= detail_tab(i).cmud_data_col43;
			m_cmud_rec(m_index).cmud_data_col44	:= detail_tab(i).cmud_data_col44;
			m_cmud_rec(m_index).cmud_data_col45	:= detail_tab(i).cmud_data_col45;
			m_cmud_rec(m_index).cmud_data_col46	:= detail_tab(i).cmud_data_col46;
			m_cmud_rec(m_index).cmud_data_col47	:= detail_tab(i).cmud_data_col47;
			m_cmud_rec(m_index).status		:= detail_tab(i).status;

			IF m_Tier_From = 'MIN' THEN
				m_Tier_From := '0';			
			END IF;

			IF m_Tier_To = 'MAX' THEN
				m_Tier_To := '999999999999999';
			END IF;

			m_cmud_rec(m_index).tier_from	:= m_Tier_From;
			m_cmud_rec(m_index).tier_to	:= m_Tier_To;

		END LOOP;

		--op_act_id 		:= m_cmud_rec(1).Account_No;
		op_cust_id		:= m_cmud_rec(1).cust_no;
		op_eff_from_date 	:= m_cmud_rec(1).stv_from_date;
		op_eff_to_date 		:= m_cmud_rec(1).stv_to_date;

		IF (g_err_tab.COUNT = 0) THEN

			Create_Exception(m_cmud_rec,op_tv_uid,op_stv_id,op_stv_inh_ind);

			IF g_err_tab.COUNT = 0 THEN

				op_err_code :='0';
				op_err_msg	:='No Error';

				UPDATE 
				CSTM_MEGA_UPLOAD_DET -- PMS 61840
				SET
				CMUD_STATUS = 'P'
				WHERE
				CMUD_CMU_ID = ip_excel_id
				AND
				CMUD_DATA_COL1 = ip_group_id;
			ELSE

				op_err_code := '1';
				op_err_msg	:= 'Error while calling Price_List_Api';
				log_prcs_error( ip_excel_id,ip_group_id);
			END IF;

		ELSE 
			op_err_code := '1';
			op_err_msg	:= 'Error while Validating Arguments';
			log_prcs_error( ip_excel_id,ip_group_id);	
		END IF;

		END LOOP;
	
	IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
	ROLLBACK;
	IF detail_cur%ISOPEN THEN CLOSE detail_cur; END IF;
	Stbms_Err.disp_err (100015,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );
END negotiated_pricelist_grp;

/*-------------------------------------------------------------------------------------------------
 Procedure	: validate_standard 
 Purpose	: File Level Validation of Standard Upload
-------------------------------------------------------------------------------------------------*/

PROCEDURE negotiated_pricelist(ip_xl_id IN VARCHAR2,
				ip_template_id IN VARCHAR2,
				op_tv_uid 			OUT VARCHAR2, 
				op_act_id 			OUT VARCHAR2,							  	 
				op_cust_id 			OUT VARCHAR2,
				op_eff_from_date		OUT VARCHAR2,
				op_eff_to_date			OUT VARCHAR2,
				op_stv_id			OUT VARCHAR2,
				op_stv_inh_ind			OUT VARCHAR2,
				op_err_code			OUT VARCHAR2,
				op_err_msg			OUT VARCHAR2) IS 


CURSOR
	det_grp_id_cur IS
SELECT
	DISTINCT CMUD_DATA_COL1 grp_id
FROM
	cstm_mega_upload_det
WHERE
	cmud_cmu_id = ip_xl_id
ORDER BY
	to_number(grp_id);
	
TYPE det_grp_id_arr IS TABLE OF det_grp_id_cur%ROWTYPE INDEX BY binary_integer;

m_det_grp_id_tab det_grp_id_arr;
	
	
BEGIN	

	OPEN det_grp_id_cur;	
	LOOP
		m_det_grp_id_tab.DELETE;
		FETCH det_grp_id_cur BULK COLLECT INTO m_det_grp_id_tab LIMIT g_rows;
		EXIT WHEN m_det_grp_id_tab.COUNT = 0;
		
		FOR i IN 1..m_det_grp_id_tab.COUNT LOOP		
		
			negotiated_pricelist_grp(m_det_grp_id_tab(i).grp_id,ip_xl_id,op_tv_uid,op_act_id,op_cust_id,op_eff_from_date,op_eff_to_date,op_stv_id,op_stv_inh_ind,op_err_code,op_err_msg);		
		END LOOP;	
	END LOOP;	
	IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;	
EXCEPTION
	WHEN OTHERS THEN
		IF det_grp_id_cur%ISOPEN THEN CLOSE det_grp_id_cur; END IF;
		Stbms_Err.disp_err (100076,SQLERRM|| 'line <' || dbms_utility.format_error_backtrace || '>' );		
END negotiated_pricelist;

END mega_upload_api;
/
