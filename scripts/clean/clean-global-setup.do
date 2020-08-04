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

   **Define all your conversion rates here instead of typing them each
   * time you are converting amounts, for example - in unit standardization.
   * We have already listed common conversion rates below, but you
   * might have to add rates specific to your project, or change the target
   * unit if you are standardizing to other units than meters, hectares,
   * and kilograms.

   /*Standardizing length to meters
		global foot     = 0.3048
		global mile     = 1609.34
		global km       = 1000
		global yard     = 0.9144
		global inch     = 0.0254

   *Standardizing area to hectares
		global sqfoot   = (1 / 107639)
		global sqmile   = (1 / 258.999)
		global sqmtr    = (1 / 10000)
		global sqkmtr   = (1 / 100)
		global acre     = 0.404686

   *Standardizing weight to kilorgrams
		global pound    = 0.453592
		global gram     = 0.001
		global impTon   = 1016.05
		global usTon    = 907.1874996
		global mtrTon   = 1000

*/






   * ******************************************************************** *
   *  country list
   * ******************************************************************** *

        global countries        `"PER JRD MOZ RWA"'
		global countries3		`"PER JRD RWA"'		// this takes out MOZ as it's missing all sch vars

		global countrynames		"Peru Jordan Mozambique Rwanda" // make sure this order is the same!!
		*global

		* I need to create this now to standardize and minimize across all do-files
		foreach country of global countrynames {
			global pos_`country' : list posof "`country'" in countrynames
			}
		global pos_1 PER
		global pos_2 JRD
		global pos_3 MOZ
		global pos_4 RWA

		global c_n : list sizeof countries










   * ******************************************************************** *
   *  country file shortcuts
   * ******************************************************************** *
        global peruwork			`"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork"'

		* datasets

		* Peru
		global PER_po            `"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork/MasterData/public_officials/DataSet/C_Peru+PO.dta"'
		global PER_sch            `"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork/MasterData/schools/DataSet/C_Peru+Schools.dta"'
		global PER_g1x			`"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork/baseround/DataSets/Deidentified/Merged_Dept.dta"'
			gl PER_g2xa			`"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork/baseround/DataSets/Deidentified/Merged_byDistrict.dta"'
			gl PER_g2xd			`"C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/DataWork/baseround/DataSets/Deidentified/DIST_Merged_byDistrict.dta"'

		* Jordan
		global JRD_po          `"C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\Jordan\Dashboard-Jordan\MasterData\publicofficial\DataSet\F_po.dta"'
		global JRD_sch            `"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Jordan/Dashboard-Jordan/MasterData/school/DataSet/F_sch.dta"'
		global JRD_g1x			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Jordan/Dashboard-Jordan/baseline/DataSets/Intermediate/merge_g1_all.dta"'
			gl JRD_g2xa			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Jordan/Dashboard-Jordan/baseline/DataSets/Intermediate/merge_g2_all.dta"'
			gl JRD_g2xd			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Jordan/Dashboard-Jordan/baseline/DataSets/Intermediate/merge_g2_district.dta"'

		* Mozambique
		global MOZ_po 			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/MasterData/publicofficial/DataSet/F_po.dta"'
		global MOZ_sch 			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/MasterData/school/DataSet/F_sch.dta"'
		global MOZ_g1x			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/baseline/DataSets/Intermediate/merge_g1_all.dta"'
			gl MOZ_g2xa			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/baseline/DataSets/Intermediate/merge_g2_all.dta"'
			gl MOZ_g2xd			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/baseline/DataSets/Intermediate/merge_g2_district.dta"'

		* Rwanda
		global RWA_po 			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/MasterData/publicofficial/DataSet/F_po.dta"'
		global RWA_sch 			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/MasterData/school/DataSet/F_sch.dta"'
		global RWA_g1x			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/baseline/DataSets/Intermediate/merge_g1_all.dta"'
		global RWA_g2xa			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/baseline/DataSets/Intermediate/merge_g2_all.dta"'
		global RWA_g2xd			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/baseline/DataSets/Intermediate/merge_g2_district.dta"'


		* files we create in this project
		global GLOBE_data 		 `"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets"'
		global GLOBE_po			 `"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_po.dta"'
		global GLOBE_sch		 `"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/school/GLOBE_sch.dta"'
		global GLOBE_g1x			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/merged/GLOBE_MERGE.dta"'

		global GLOBE_pomc		`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_pomc.dta"'

		global GLOBE_pomcdta	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/mc"'

		global GLOBE_pomcalc		`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_pomcalc.dta"'

		global GLOBE_pomcalcB		`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_pomcalcB"'
		global GLOBE_m0				`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_pom0.dta"'
		global GLOBE_pomcresults	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/global_datasets/po/GLOBE_mcresults.dta"'

		* Output Folders
		global JRD_out			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Jordan/Dashboard-Jordan/baseline/Output/Final/TeX"'
		global PER_out 			`"C:/Users/wb551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/Peru/baseround/Output/Final/TeX"'
		global MOZ_out			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Mozambique/Dashboard-Mozambique/baseline/Output/Final/TeX"'
		global RWA_out			`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Rwanda/Dashboard-Rwanda/baseline/Output/Final/TeX"'










	* ******************************************************************** *
	*  output file folders and paths
	* ******************************************************************** *

	*For global documents that describe cumulative data
    	* For LaTeX and other outputs
 		global 		docs		"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/globaldocs"

		* global out
		global 		GLOBE_out 	"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/globalout"

		// html
		gl 			html 		"${GLOBE_out}/html"

		// global LaTeX folder
	 		global 	tex			"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/globalout/TeX"
	 		global 	OLS			"${tex}/OLS"
	 		global	cor			"${tex}/Correlations"
	 		global 	scatters	"${tex}/Scatters"
	 		global 	sumstats	"${tex}/SumStats"
	 		global 		hist	"${sumstats}/histograms"
	 		global 	vardecomp	"${tex}/VarianceDecomp"

	* for country-specific analysis run from the global script (ie analysis pt A)
		global 		countriespath	"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/countries"

		global 		G_PER_tex	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/countries/Peru/TeX"'
		global 		G_JRD_tex	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/countries/Jordan/TeX"'
		global 		G_MOZ_tex	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/countries/Mozambique/TeX"'
		global 		G_RWA_tex	`"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/Edu+Dashboard/countries/Rwanda/TeX"'

		* can you do this?
		foreach cty of global countries {
		global 		`cty'_OLS		`"${G_`cty'_tex}/OLS"'
		global		`cty'_cor		`"${G_`cty'_tex}/Correlations"'
		global 		`cty'_scatters	`"${G_`cty'_tex}/Scatters"'
		global 		`cty'_sumstats	`"${G_`cty'_tex}/SumStats"'
		global 			`cty'_hist	`"${`cty'_sumstats}/histograms"'
		global 		`cty'_vardecomp	`"${G_`cty'_tex}/VarianceDecomp"'
			}











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

		*Mandates and Accountability
		global 		ma			"mandates_accountability coherence transparency accountability"
		global		ma_imp1		"MA_imp1 coherence transparency accountability"
		global 		ma_imp2		"MA_imp2 coherence transparency accountability"
		global		mallimps	"mandates_accountability MA_imp1 MA_imp2 coherence transparency accountability"

	* for Correlations
		global 		cor1 		bi national_learning_goals mandates_accountability quality_bureaucracy ///
		 						impartial_decision_making /*bi+secondary */
		global 		cor2 		bi targeting monitoring incentives community_engagement coherence ///
								transparency accountability knowledge_skills work_environment merit ///
								motivation_attitudes polit_prsnel_mangmnt polit_policy_mkng ///
								polit_policy_imp unions_facil /*bi+tertiary */
		global 		cor3 		bi national_learning_goals mandates_accountability quality_bureaucracy ///
		 						impartial_decision_making ///
								targeting monitoring incentives community_engagement coherence ///
								transparency accountability knowledge_skills work_environment merit ///
								motivation_attitudes polit_prsnel_mangmnt polit_policy_mkng ///
								polit_policy_imp unions_facil  /*1ry, 2ry, 3ry indicators*/

		global 		cor4 		content_prof student_knowledge student_prof ///
								ecd_student_knowledge inputs infrastructure ///
								operational_manage	/*school levels vars */
			gl 		cor4MOZ 	student_knowledge absence_rate absence_rate_1st content_knowledge ///
								pedagogical_knowledge inputs infrastructure

		global 		cor5 		bi national_learning_goals mandates_accountability quality_bureaucracy ///
		 						impartial_decision_making /// /*bi+secondary*/
								student_knowledge student_prof ///
								inputs infrastructure ///
								operational_manage

		global  	anova_m		bi national_learning_goals mandates_accountability quality_bureaucracy ///
		 						impartial_decision_making inputs infrastructure student_knowledge math_sk lit_sk
			gl 		anova_mMOZ	bi national_learning_goals mandates_accountability quality_bureaucracy ///
			 						impartial_decision_making inputs infrastructure student_knowledge


	/* Breakdown of some school-level indicators
		global		teaching	"content_proficiency literacy_content_proficiency math_content_proficiency intrinsic_motivation"
		global		learners4th	"student_knowledge math_student_knowledge lit_student_knowledge student_proficient lit_student_proficient math_student_proficient"
		global		learners1st	"ecd_student_knowledge ecd_math_student_proficiency ecd_literacy_student_proficiency"
		global		inputs		"inputs infrastructure"
		global		management	"operational_management principal_knowledge_score principal_management problem_solving"
		global 		practice	"$teaching $learners1st $inputs $management"
		*/

	* Store key basic stats indicators %% consider other vars here.
		global 		dstatsvars 	idschool absence_rate total_enrolled student_knowledge ///
								math_sk lit_sk inputs infrastructure  /*for schools*/
	*				/*bi*/		/*defined above, serves as "po dstatvars" */
		global 		combdstat 	absence_rate total_enrolled student_knowledge ///
								math_sk lit_sk inputs infrastructure  ///
								bi national_learning_goals mandates_accountability quality_bureaucracy ///
								impartial_decision_making /*combines PO + school dstat vars */
			gl 		combdstat5 	inputs infrastructure  ///
									bi national_learning_goals mandates_accountability quality_bureaucracy ///
									impartial_decision_making
			gl 		combdstat100 	absence_rate student_knowledge ///
									math_sk lit_sk
		global 		allschool	idschool absence_rate total_enrolled student_knowledge ///
								math_sk lit_sk inputs infrastructure		/*right now, same as dstatvars*/

		global		ttestvars 	"absence_rate total_enrolled student_knowledge math_student_knowledge lit_student_knowledge inputs infrastructure "

	* Variance Decomposition
		global 		decompdvvars "absence_rate total_enrolled student_knowledge inputs infrastructure "
		global		anova_po	 "student_knowledge content_knowledge teacher_satisfied_job principal_management infrastructure_impute"
		global 		anova_school student_knowledge math_sk lit_sk
			gl 		anova_schMOZ student_knowledge
		global 		anova_sch_ex student_attendance content_knowledge inputs infrastructure operational_manage principal_knowl_score teacher_satis_job sch_monitoring
			gl 		anova_exMOZ		absence_rate absence_rate_1st content_knowledge ///
								pedagogical_knowledge inputs infrastructure













   * ******************************************************************** *
   * Settings for graphs etc
   * ******************************************************************** *


		/* Varlabels
		global		SclCrlnVnames `" student_knowledge "Student 4thGrade Exam" content_knowledge "Teacher Content Knowledge" intrinsic_motivation TeacherMotivation inputs_impute Inputs infrastructure_impute Infrastructure"'
		global		POCrlnVnames	"national_learning_goals NatlLearningGoals mandates_accountability Mandates+Acct quality_bureaucracy QualofBureauc impartial_decision_making ImpartDescMaking"
		global		POvdecompnames	"_cons Constant national_learning_goals NatlLearningGoals mandates_accountability Mandates+Acct quality_bureaucracy QualofBureauc impartial_decision_making ImpartDescMaking"
		global 		POSumNames		"idpo ID national_learning_goals NatlLearningGoals mandates_accountability Mandates+Acct quality_bureaucracy QualofBureauc impartial_decision_making ImpartDescMaking"
		global 		dstatnames		"idschool SchoolID absence_rate TeacherAbsenceRate total_enrolled Stud.Enrollment student_knowledge 4thGradeExam math_student_knowledge 4thGradeMathExam lit_student_knowledge 4thGradeLitExam inputs_impute Inputs infrastructure_impute Infrastructure "
		global 		binames			"national_learning_goals NationalLearningGoals targeting NLG:targeting monitoring NLG:monitoring incentives NLG:incentives community_engagement NLG:community_engage mandates_accountability Mandates_Acctbly coherence MA:coherence transparency MA:transparency accountability MA:acctbly quality_bureaucracy QualityofBureaucracy knowledge_skills QB:knowledge+skills work_environment QB:work+environ merit QB:merit motivation_attitudes QB:motivation impartial_decision_making ImpartialDecisionMaking polit_pers_manage IDM:personnel politicized_policy_making IDM:policy+making polit_policy_imp IDM:implementation unions_facil IDM:unions bi OverallBureaucracyIndex bi_imp1 BureaucracyIndex_i1 bi_imp2 BureaucracyIndex_i2 NLG_imp1 NationalLearningGoals_i1 MA_imp1 Mandates+Acctbly_i1 QB_imp1 QualityofBureaucracy_i1 IDM_imp1 ImpartialDecisionMaking_i1 NLG_imp2 NationalLearningGoals_i2 MA_imp2 Mandates+Acctbly_i2 QB_imp2 QualityofBureaucracy_i2 IDM_imp2 ImpartialDecisionMaking_i2 "
		*global 		manames			"MA_imp2 Mandates+Acctbty_i2 coherence Coherence transparency Transparency accountability Accountability"
		*global 		orgzatnnames	"ORG1q1a StaffChange:Head ORG1q1b StaffChange:Finance ORG1q1c StaffChange:Director ORG1q1d StaffChange:SchoolSpvsr ORG1q1e StaffChange:M+Edirector ORG1q2a ReasonsForLeave "
		*global 		macornames		"student_knowledge Student4thTestScore content_knowledge TeacherContentKnowl intrinsic_motivation TeacherMotivation inputs_impute Inputs infrastructure_impute Infrastructure"

		* Summary Statistics
		*global 		sumstats	"cells("count mean sd min max") nomtitle nonumber noobs"
		global		SumStats	`"noobs nomtitle nonumber cells((count(label("N")) mean(label("Mean") fmt(a)) sd(label("Sd") fmt(a)) min(label("Min") fmt(a)) max(label("Max") fmt(a)) p25(fmt(a)) p50(fmt(a)) p75(fmt(a)) ))"'
		global 		sum			`"main(n mean sd min max p25 p50 p75) nonumber nomtitle label cell(( n(fmt(3) label(N)) mean(fmt(3) label(Mean)) sd(fmt(3) label(sd)) min(fmt(3) label(Min)) max(fmt(3) label(Max)) p25(fmt(3) label(25th Pctile)) p50(fmt(3) label(Median)) p75(fmt(3) label(75th Pctile)) ))"'
		*global		bregs		`"r2 ar2 b(%9.3f) se(%9.3f) starlevels (* 0.10 ** 0.05 *** 0.01)	keep(*) addnotes(Standard errors in parentheses. /sym{*} /(p<0.10/), /sym{**} /(p<0.05/), /sym{***} /(p<0.01/)) nonotes"'
		global		ols			`"r2 ar2 b(%9.3f) se(%9.3f) starlevels (* 0.10 ** 0.05 *** 0.01) addnotes(Standard errors in parentheses. /sym{*} /(p<0.10/), /sym{**} /(p<0.05/), /sym{***} /(p<0.01/)) nonotes"'
		*global		decompols	`"stats(N r2 mss rss F, labels("No. Obs" "R-sq" "Model Sum Sq" "Residual Sum Sq" "F-Stat")) mlabels(,depvars) b(%9.3f) se(%9.3f) starlevels (* 0.10 ** 0.05 *** 0.01) addnotes(Standard errors in parentheses. /sym{*} /(p<0.10/), /sym{**} /(p<0.05/), /sym{***} /(p<0.01/)) nonotes keep(*)"'
		*global		stackdecompols `"stats(N r2 mss rss F, labels("No. Obs" "R-sq" "Model Sum Sq" "Residual Sum Sq" "F-Stat")) nomtitles b(%9.3f) se(%9.3f) starlevels (* 0.10 ** 0.05 *** 0.01) addnotes(Standard errors in parentheses. /sym{*} /(p<0.10/), /sym{**} /(p<0.05/), /sym{***} /(p<0.01/)) nonotes keep(*)"'
*/


		* table of summary statistics
		global set_ss_tex		`"noobs nomtitle nonumber cells( `"count(label("N")) mean(label("Mean") fmt(a)) sd(label("Sd") fmt(a)) min(label("Min") fmt(a)) max(label("Max") fmt(a))"' ) label tex wrap"' //align(p{\colw}) abbrev
		global set_ss_xl		`"noobs nomtitle nonumber cells((count(label("N")) mean(label("Mean") fmt(a)) sd(label("Sd") fmt(a)) min(label("Min") fmt(a)) max(label("Max") fmt(a)) ))"'

		global set_anova_tex	`"se mtitle noobs nogaps compress nonumb style(tex) label varwidth(50) cells( b(fmt(3)) ) tex align(p{\colw}) wrap ml("Variance Explained")"'
		global set_anova_xl	`"se mtitle noobs compress nonumb style(tab)"'

			//anova labels
		global lbl_anova		`" sat_culture "Culture Opportunities" sat_sport "Sport Opportunties" sat_transport "Transportation" sat_walk "Walking and Cycling Opportunties" sat_parks "Parks" sat_archi "Architecture" sat_public "Public Areas" sat_roads "Roads" sat_air "Air Qualtiy" sat_noise "Noise Levels" sat_wastetrans "Waste Transport" sat_wastesort "Waste Sorting" sat_manage "Municipality Management" sat_develop "Municipality Development" sat_plan "Local Involvement in Planning" sat_spatialplan "Local Involvement in Spatial Planning" sat_munchange "Municipality Management Improved" sat_devchange "Municipality Development Improved" "'

		* correlations
		global set_cor_tex		`"varwidth(23) unstack noobs nomtitle nonumber cells(( b(fmt(3) )  )) label ml(,none) coll(,none) tex nomtitles fragment abbrev prehead(`"\small"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' `"\setlength{\tabcolsep}{.5pt}"'  `"\begin{tabular}{l*{@E}{c}}"')  postfoot(`"\end{tabular}"')	"'
		global set_cor_smtex		`"unstack noobs nomtitle nonumber cells(( b(fmt(a))  )) label ml(,none) coll(,none) abbrev varwidth(15) modelwidth(3)  longtable tex align(p{\colw}) wrap legend nogaps compress"' // star
			gl prehead_cor 		`"  `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' `"\begin{longtable}{l*{@M}{p{\colw}}}"' `"\tiny"' `"\caption{@title}"' \\ `"\hline\hline\endfirsthead\hline\endhead\hline\endfoot\endlastfoot"'  "'
			gl postfoot_cor		`" `"\hline\hline"' `"\multicolumn{@span}{l}{\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)}"' \\ `"\end{longtable}"' "'
		global set_cor_xl		`"unstack noobs nomtitle nonumber cells(( b(fmt(a) star)  )) label ml(,none) coll(,none) abbrev varwidth(15) longtable tab align(p{\colw}) wrap legend"'

		global set_colcor_tex		`"noobs nomtitle nonumber cells(( b(fmt(a)) p(label("p-value") fmt(a2))  )) label longtable ml(,none)"'

		* scatters
		global set_sca_png		`"xscale( range(0/5) ) xlabel( 0(.5)5 ) scheme(plotplain)"'
		global set_mc_graph1		`" xti(`"Observations Kept"') xlab(#6) xmti(##2) ylab(0(.1).5) ymti(##2) legend(pos(6) order(1 `"25th/75th percentile"' 2 `"Mean BI Difference"')) yline(.05 )"'
		global set_mc_graph2		`"xti(`"Observations Kept"') xlab(#10) xscale( range(0(10)100) ) xmti(##2) ylab(0(.1)1.2) ymti(##2) legend(pos(6) order(1 `"-/+ 1 Std. Deviation"' 2 `"Mean BI Difference"'))"'
		global set_mc_graph3 	`"xti(`"Observations Kept"') xlab(#6) xmti(##2) xscale( range(1(1)18) ) ylab(0(.1)1) ymti(##2) legend(pos(6) order(1 `"-/+ 1 Std. Deviation"' 2 `"Mean BI Difference"')) 	yline(0.05)	m(smcircle)  msize(11-pt) mcolor(gray%35) mlcolor(gray%5) caption("Each point represents a simulated mean and darker points indicate greater density")"' // for region
		global set_mc_graph4 	`" xti(`"Observations Kept"') xlab(#5) xmti(##2) xscale( range(1(1)10) ) yscale( range(0(.1)1.2) ) ylab(#5) ymti(##5) legend(pos(6) order(1 `"-/+ 1 Std. Deviation"' 2 `"Mean BI Difference"')) 	yline(0.05)	m(smcircle)  msize(11-pt) mcolor(gray%35) mlcolor(gray%5) caption("Each point represents a simulated mean and darker points indicate greater density")"'  // for districts






		* regressions
		global set_reg_tex 			 `"nonumber cells( b(label("b") fmt(3) star) se(label("se") fmt(2))  ) label abbrev  legend stats(N F r2 r2_a, labels("N" "F-Stat" "R-sq" "Adj. R-sq") ) varlabels(_cons Constant) style(tex) modelwidth(5) mlabels(, nodepvars numbers) longtable tex align(p{\colw}) "'
		global set_reg_xl			 `"nonumber cells( b(fmt(3) star) se(fmt(2)) ) legend stats(N F r2 r2_a)"'

		* histograms
		/* note this does not set the bin, main title # */
		global set_hist 		`"start(0) xscale( range(0 5) )  xlab(0(.5)5)  ytitle(`"Frequency (in percent)"')  scheme(plotplain)"'
		global set_hist_100  	`"start(0) xscale( range(0 100) )  xlab(0(10)100) ytitle(`"Frequency (in percent)"')  scheme(plotplain)"'
		global set_histnomin 	`"fraction ytitle(`"Frequency (in percent)"') scheme(plotplain)"'
