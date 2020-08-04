/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-school.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	iecodebook		| *

						/* 	use iecodebook to harmonized
							variable names
							across all datasets 		*/


* create a template using iecodebook
iecodebook template ///
			/// path to PER survey %
			/// path to JOR
			/// path to MOZ
			/// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, surveys(`"${countries}"') ///
			gen(`"${countrynames}"')	// identify source of each obs


		/*excel editing happens manually here. */


* apply to all datasets
iecodebook append ///
			/// path to PER survey %
			/// path to JOR
			/// path to MOZ
			/// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, clear ///
			generate(`"${countrynames}"') 	/// identify where each







									* | Append | *

						






									* | ID Check | *



	captureb bysort country isid school_code

		if _rc {
			duplicates 	drop 	school_code student_knowledge lat lon, force	// drop obs that are same on these vars
			isid 				school_code
		}
