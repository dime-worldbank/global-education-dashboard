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


	**Note globals that remain consistent will not overwrite






   * ******************************************************************** *
   *  country list
   * ******************************************************************** *

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








	* ******************************************************************** *
	*  output file folders and paths
	* ******************************************************************** *


   * ******************************************************************** *
   * Set global lists of variables
   * ******************************************************************** *
