   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               Global Education Dashboard                             *
   *               Main DO_FILE                                         *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

       /*

       ** NOTES:

       ** WRITTEN BY:   Tom Mosher

       ** Last date modified: August 2020
       */

*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           - Install packages needed to run all dofiles called
   *            by this master dofile.
   *           - Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited
	clear all
	macro drop _all
   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
   local user_commands ietoolkit scores // labutil      //Fill this list will all user-written commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }

   *Standardize settings accross users
   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above

*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           - Set the global box to point to the project folder
   *            on each collaborator's computer.
   *           - Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *

   * Users
   * -----------

   *User Number:
   * Tom (WB local)             			      	  1    //
   * Dan's shared drive             				  2    //

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------

    if $user == 1 {
        global WBOneDrive		"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard"
        global WBclone		    "C:/Users/WB551206/local/GitHub"
        global avrclone		     ""
    }


* These lines are used to test that the name is not already used (do not edit manually)
*round*baseline*****************************************************************
*untObs*publicofficial*school***************************************************
*subFld*scripts*****************************************************************
*iefolder will not work properly if the lines above are edited


   * Project folder globals
   * ---------------------

   global dataWorkFolder        "$WBOneDrive/global-edu-dashboard"	// deidentified data
   global dataWork_clone		"$WBclone/global-edu-dashboard" // this points to scripts.
   global rawencrypt			"A:/Countries" // raw data
   global encryptFolder         `"B:"'	// the encrypted folder where new, encrypted files are kept


  *iefolder*1*FolderGlobals*subfolder*********************************************
*iefolder will not work properly if the line above is edited


   *scripts sub-folder globals
   *global scripts_OD             "$dataWorkFolder/scripts" // points to the "dataset" scripts or dataWorkFolder/scripts
   global scripts_clone			 "$dataWork_clone/scripts" // points to the scripts on WB synced with github.
   global AA					 "${scripts_clone}/Analysis_ptA"
   global smp 					 "${scripts_clone}/sampling"

*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData"


   *publicofficial folder globals
   global publicofficial         "$mastData/public-official"
   global publicofficial_encrypt "$encryptFolder/public-official"

   *school folder globals
   global school                 "$mastData/school"
   global school_encrypt         "$encryptFolder/school"

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*RoundGlobals*rounds*baseline*baseline*******************************
*iefolder will not work properly if the line above is edited

   *baseline folder globals
   global baseline               "$dataWorkFolder/baseline"
   global baseline_clone		 "$dataWork_clone/baseline"
   global baseline_encrypt       "$encryptFolder/Round baseline Encrypted"
   global baseline_dt            "$baseline/DataSets" 			// DO NOT create a path for the clone for datasets.
   global baseline_do            "$baseline/Dofiles"
   global baseline_do_clone      "$baseline_clone/Dofiles"
   global baseline_out           "$baseline/Output"
   global baseline_out_clone     "$baseline_clone/Output"

   */
*iefolder*1*FolderGlobals*endRounds*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, different sets of control variables,
   * adofile paths etc.

  * do `"${scripts_clone}/GLOBE_global_setup.do"'


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited

do `"${scripts_clone}/clean/clean-global-setup.do"' // this the the clean-specific and also main

*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DOFILE
   *
   *           - When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           - The default is that these dofiles are set to not
   *            run. It is rare that all round-specfic master dofiles
   *            are called at the same time; the round specific master
   *            dofiles are almost always called individually. The
   *            exception is when reviewing or replicating a full project.
   *
   * ******************************************************************** *


*iefolder*3*RunDofiles*baseline*baseline****************************************
*iefolder will not work properly if the line above is edited

* [Settings]
/*set all settings to 1 if you want to run, default == 0 */

gl s1	= 0		// reconstruct bi vars
gl s2	= 0 	// generate top p-tile vars for BI
gl s3 	= 1		// 0 = keep 203 obs in peru PO dataset; 1 == drop unmatched obs as Brian does.
gl s4	= 1		// 1 reconstructs BI vars, 0 leaves raw data and only constructs Aggregate indicator



/* script settings settings to 1 if you want to run, default == 0 */

loc clean	= 1		// reconstruct bi vars
loc agg		= 1 	// generate top p-tile vars for BI


* [Cleaning]
* Import, Clean, Construct, Deidentify
if (`clean' == 1) {
	do "${scripts_clone}/clean/main-clean.do"
}

* [Aggregate]
* Collapse by admin unit, merge.
if (`agg' == 1) {
	do "${scripts_clone}/agg/main-agg.do"
}

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

/* credits!
Prof. Oscar Reyna-Torres https://www.princeton.edu/~otorres/Panel101.pdf
