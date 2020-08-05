* labpreserve.do
* when collapsing, replaces "(mean)" with "Av."

* thanks to https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/

// store list of numeric vars
ds 		, has(type numeric)
loc 	numeric = r(varlist)

// Sub in "Av." for (mean) for each of the varlabels

foreach v of local numeric {
	local l`v': variable label `v' // store label
	local str = subinstr("`l`v''", "(mean)", "Av.", 1) // determine the string to sub in
	label var `v' "`str'" 	// sub in the string
}

/* ideally I'd want to remove the '(mean)' prefix when things collapse, but


	la var 		targeting			"Targeting"
	la var 		monitoring 			"Monitoring"
	la var 		incentives			"Incentives"
	la var  	community_engagement "Community Engagement"
	la var 		coherence			"Coherence"
	la var 		transparency		"Transparency"
	la var 		accountability		"Accountability"
	la var  	knowledge_skills	"Knowledge+Skills"
	la var 		work_environment	"Work Environment"
	la var		merit				"Merit"
	la var 		motivation_attitudes "Motivation+Attitudes"
	la var  	polit_prsnel_mangmnt "Polit. Management"
	la var 		polit_policy_mkng	"Polit. Policy-Making"
	la var		polit_policy_imp	"Polit. Policy Implementation"
	la var 		unions_facil		"Union Facilitation"
	la var  	national_learning_goals	 "National Learning Goals"
	la var 		mandates_accountability "Mandates+Accountability"
	la var		quality_bureaucracy 	"Quality of Bureaucracy"
	la var 		impartial_decision_making "Impartial Decision-Making"
	la var 		bi 						"Bureaucracy Index"
	capture la var 		idpo 					"ID Public Officials"
