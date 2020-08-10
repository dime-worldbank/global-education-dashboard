   * ******************************************************************** *
   *
   *       SET UP STANDARDIZATION GLOBALS AND OTHER CONSTANTS
   *
   *           - Set globals used all across the project
   *           - It is bad practice to define these at multiple locations
   *
   * ******************************************************************** *

   * ******************************************************************** *
   * Set all conversion rates used in unit standardization
   * ******************************************************************** *







   * ******************************************************************** *
   *  country list
   * ******************************************************************** *

        global countries        "PER JRD MOZ RWA"
		global countries3		PER JRD RWA	// this takes out MOZ as it's missing all sch vars

		global countrynames		Peru Jordan Mozambique Rwanda // make sure this order is the same!!
		*global

		* I need to create this now to standardize and minimize across all do-files
		foreach country of global countrynames {
			global pos_`country' : list posof "`country'" in countrynames
			}
		global pos_1 PER
		global pos_2 JRD
		global pos_3 MOZ
		global pos_4 RWA

		global c_n = 4		// : list sizeof countries does not work
		di "$c_n"










   * ******************************************************************** *
   *  country file shortcuts
   * ******************************************************************** *
		* master dataset
		gl 			sch0 					"A:/main/final_main_school_data.dta"
		gl 			po0 					"A:/main/final_main_po_data.dta"
		
		 *-_-_ Main Datasets _-_-*
		 * Raw Stata
		 global 	raw_po					"${jointencrypt}/Rwanda/Data/public_officials_survey_data_short.dta"
		 global 	raw_sch					"${jointencrypt}\Rwanda\Data\final_indicator_school_data.dta"
		 * Imported
		 global	A_po 					"${encryptFolder}/public-official/A_PO.dta"
		 global	A_sch					"${encryptFolder}/school/A_school.dta"
		 * clean
		 global  B_sch					"${encryptFolder}/school/B_school.dta"
		 global  B_po					"${encryptFolder}/public-official/B_PO.dta"
		 * construct
		 global  C_po 					"${encryptFolder}/public-official/C_PO.dta"
		 global  C_sch					"${encryptFolder}/school/C_school.dta"
		 * deidentified, merged with master
		 global	D_sch					"${baseline_dt}/Deidentified/D_sch.dta"
		 global	D_po					"${baseline_dt}/Deidentified/D_po.dta"
		 * Cleaned, master1
		 global 	E_po					"${publicofficial}/Dataset/E_po.dta"
		 global 	E_sch					"${school}/Dataset/E_sch.dta"
		 *+imp, z-, master2
		 global 	F_sch					"${school}/Dataset/F_sch.dta"
		 global	F_po					"${publicofficial}/Dataset/F_po.dta"
		 * Collapsed, master3-x
		 global  col_po_g0_all			"${publicofficial}/Dataset/col_po_g0_all.dta"
		 global  col_po_g1_all			"${publicofficial}/Dataset/col_po_g1_all.dta"
		 global  col_po_g2_all			"${publicofficial}/Dataset/col_po_g2_all.dta"
		 global  col_po_g3_all			"${publicofficial}/Dataset/col_po_g3_all.dta"
		 global  col_po_g0_minedu		"${publicofficial}/Dataset/col_po_g0_minedu.dta"
		 global  col_po_g1_minedu		"${publicofficial}/Dataset/col_po_g1_minedu.dta"
		 global  col_po_g2_minedu		"${publicofficial}/Dataset/col_po_g2_minedu.dta"
		 global  col_po_g3_minedu		"${publicofficial}/Dataset/col_po_g3_minedu.dta"
		 global  col_po_g0_region		"${publicofficial}/Dataset/col_po_g0_region.dta"
		 global  col_po_g1_region		"${publicofficial}/Dataset/col_po_g1_region.dta"
		 global  col_po_g2_region		"${publicofficial}/Dataset/col_po_g2_region.dta"
		 global  col_po_g3_region		"${publicofficial}/Dataset/col_po_g3_region.dta"
		 global  col_po_g0_district		"${publicofficial}/Dataset/col_po_g0_district.dta"
		 global  col_po_g1_district		"${publicofficial}/Dataset/col_po_g1_district.dta"
		 global  col_po_g2_district		"${publicofficial}/Dataset/col_po_g2_district.dta"
		 global  col_po_g3_district		"${publicofficial}/Dataset/col_po_g3_district.dta"
		 global  col_po_g0_reg_district	"${publicofficial}/Dataset/col_po_g0_reg_district.dta"
		 global  col_po_g1_reg_district	"${publicofficial}/Dataset/col_po_g1_reg_district.dta"
		 global  col_po_g2_reg_district	"${publicofficial}/Dataset/col_po_g2_reg_district.dta"
		 global  col_po_g3_reg_district	"${publicofficial}/Dataset/col_po_g3_reg_district.dta"

		 * merged
		 global  M_g1_all				"${baseline_dt}/Intermediate/merge_g1_all.dta"
		 global  M_g1_minedu				"${baseline_dt}/Intermediate/merge_g1_minedu.dta"
		 global  M_g1_region				"${baseline_dt}/Intermediate/merge_g1_region.dta"
		 global	 M_g1_district			"${baseline_dt}/Intermediate/merge_g1_district.dta"
		 global  M_g1_reg_district		"${baseline_dt}/Intermediate/merge_g1_reg_district.dta"
		 * dictionaries
		 global  GEO_school1 			"${geo_encrypt}/school_geodictionary.dta"
		 global  GEO_top					"${geo_encrypt}/top_geodictionary+gov.dta"
		 global  geo						"${geo_encrypt}/GEOdiciontary.dta"
		 global  sch_half				"${geo_encrypt}/sch_otherhalf.dta"
		 * Excel
		 global 	schoolsample 			"${encryptFolder}/Master school Encrypted/Sampling/school_sample_2019-10-11.xlsx"
		 global 	posample				"${encryptFolder}/Master publicofficial Encrypted/Sampling/district_sample_2019-11-05.csv"
		 global	linkkey					"${encryptFolder}/public_offical_link_key.xlsx"

		 * scripts
		 gl 	labscript 				`"C:/Users/WB551206/local/GitHub/Dashboard-META/scripts/other/edlabels.do"'










	* ******************************************************************** *
	*  output file folders and paths
	* ******************************************************************** *


   * ******************************************************************** *
   * Set global lists of variables
   * ******************************************************************** *


	* Bureaucracy Indicators
		global 		bi			`"bi national_learning_goals mandates_accountability quality_bureaucracy impartial_decision_making"'		// also used as "po dstatvars"
		global 		nlg			`"targeting monitoring incentives community_engagement"'
		global 		am			`"coherence transparency accountability"'
		global		qb			`"knowledge_skills work_environment merit motivation_attitudes"'
		global 		idm			`"polit_policy_imp polit_policy_mkng polit_prsnel_mangmnt unions_facil"'

		global 		secondary 	`" national_learning_goals quality_bureaucracy mandates_accountability impartial_decision_making "'
		global 		tertiary	`"${nlg} ${am} ${qb} ${idm}"'
		global 		biall 		`"${bi} ${nlg} ${am} ${qb} ${idm}"'

	* Schools
		gl 			schoutcome 	student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation ///
		 						content_knowledge pedagogical_knowledge operational_manage instr_leader ///
								principal_knowl_score principal_manage
		gl  		schoutcomez z_student_knowledge z_ecd_student_knowledge z_inputs z_infrastructure ///
								z_intrinsiz_motivation z_content_knowledge z_pedagogical_knowledge ///
								z_operational_manage z_instructional_leadership z_principal_knowl_score ///
								z_principal_manage

	* for deidentificaiton
		gl 			piisch	 	school_code school_province_preload school_district_preload ///
								lat lon ///
								school_name_preload school_address_preload school_code_preload survey_time ///
								school_emis_preload school_info_correct m1s0q2_name m1s0q2_code m1s0q2_emis
		gl 			piipo 		interview__id interview__key office_preload survey_time occupational_category ///
								professional_service sub_professional_service resp_finance_planning director_hr ///
								education DEM1q2 DEM1q1 DEM1q6




   * ******************************************************************** *
   * Settings for graphs etc
   * ******************************************************************** *
