* p1-explore.do
* converts the markdown file for regression panel files.

* settings: set to 1 to compile the md file
loc p1 	0	// environmental controls
loc p2  0	// noise controsl
loc p3  1 	// rich set of school controls
loc p4  0	// distance from school to HQ
loc p5  0	// interactions between school admin+district offices


* turn off graph
	set graph off

************* Globals ***************************
gl html 		"${dataWorkFolder}/out/html"
gl sl 	student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation content_knowledge pedagogical_knowledge operational_manage instr_leader principal_knowl_score principal_manage
loc slz 	student_knowledge_z ecd_student_knowledge_z inputs_z infrastructure_z intrinsic_motivation_z content_knowledge_z pedagogical_knowledge_z operational_manage_z instructional_leadership_z principal_knowl_score_z principal_manage_z
gl slnop 	student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation content_knowledge operational_manage instr_leader principal_knowl_score principal_manage
loc slznop 	student_knowledge_z ecd_student_knowledge_z inputs_z infrastructure_z intrinsic_motivation_z content_knowledge_z  operational_manage_z instructional_leadership_z principal_knowl_score_z principal_manage_z


* generate the html file
	if (`p1' == 1) {
	stmd 		"${scripts_clone}/reg/dist-panel1.stmd" /// 				/* Markdown file name	*/
				, saving("${html}/p1/dist-panel1.html")	///			/* html file name */
				nostop 								///		/* continue when error occurs */
				replace
}


	if (`p2' == 1) {
	stmd 		"${scripts_clone}/reg/dist-panel2.stmd" /// 				/* Markdown file name	*/
				, saving("${html}/p2/dist-panel2.html")	///			/* html file name */
				nostop 								///		/* continue when error occurs */
				replace
}

	if (`p3' == 1) {
	stmd 		"${scripts_clone}/reg/dist-panel3.stmd" /// 				/* Markdown file name	*/
				, saving("${html}/p3/dist-panel3.html")	///			/* html file name */
				nostop 								///		/* continue when error occurs */
				replace
}

	if (`p4' == 1) {
	stmd 		"${scripts_clone}/reg/dist-panel4.stmd" /// 				/* Markdown file name	*/
				, saving("${html}/p4/dist-panel4.html")	///			/* html file name */
				nostop 								///		/* continue when error occurs */
				replace
}

	if (`p5' == 1) {
	stmd 		"${scripts_clone}/reg/dist-panel5.stmd" /// 				/* Markdown file name	*/
				, saving("${html}/p5/dist-panel5.html")	///			/* html file name */
				nostop 								///		/* continue when error occurs */
				replace
}
