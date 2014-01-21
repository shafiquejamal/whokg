clear
set more off
set trace off
do setpaths.do
program drop _all

// This file puts together the data that Oskon got from the MHIF (not the one that Bakhtygul helped get)

cd "$WHO_KG_processed/"


forv y = 2008/2010 {
	insheet using "$WHO_KG_data_and_qnrs/from_MHIF/MHIF_`y'.csv", c clear nonames
	keep v1-v7
	if (v1[2]=="") {
		drop if _n == 1
	}
	drop if _n == 1
	drop if _n == 1
	drop if _n == _N
	gen year = `y'
	
	foreach var of varlist * {
		
		cap confirm numeric variable `var'
		if (_rc ~= 0) { // variable is not numeric
			replace `var' = trim(`var')
			replace `var' = `var'[_n-1] if `var'[_n-1] ~= "" & `var' == ""
		} 
		else {
		
		}
	}

	destring, replace
	note: "Source: Mandatory Health Insurance Fund, Government of the Kyrgyz Republic, November 2012."
	save "$WHO_KG_processed/MHIF_`y'.dta", replace
	d
}

use "$WHO_KG_processed/MHIF_2008.dta", clear
append using "$WHO_KG_processed/MHIF_2009.dta"
append using "$WHO_KG_processed/MHIF_2010.dta"
save "$WHO_KG_processed/MHIF_2008_to_2010.dta", replace

rename v1 region_n
rename v2 region_t
rename v3 hospitaltype
label var hospitaltype "Hospital type: Secondary or Tertiary"
rename v4 totaltreated
label var totaltreated "Total cases treated in for the region"
rename v5 exemptionlevel 
label var exemptionlevel "Percent of copayment exempt"
rename v6 numberofcasestreated 
label var numberofcasestreated "Number of cases treated"
rename v7 amountofcompensation 
label var amountofcompensation "Amount of compensation"
// collapse (sum) amountofcompensation numberofcasestreated, by(year)

