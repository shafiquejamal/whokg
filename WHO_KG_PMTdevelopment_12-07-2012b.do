clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all

// set scheme "scheme-for_ms_word.scheme"

// The target group for this will be the poorest 40% percent of the population (will define these people as "the poor")

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_hhlevel_12-04-2012.dta", clear
local datetouse "30 Jan 2013"
local filename_root "WHO_KG_PMTdevelopment_01-30-2013"
local extension = ".csv"local filename = "`filename_root'`extension'"local filename_outreg = "`filename_root'_outreg`extension'"
qui svysetlocal svyweight = r(wtype)local svyexp    = r(wexp) di "[`svyweight'`svyexp']"

// set the cutoff
// local cabsolute 20900 // This will cover 40% of the population
// local cabsolute 22000 // This will cover 46.6% of the population 
// local cabsolute 22085 // This will cover 47.6% of the population 
// local cabsolute 21850 // This will cover 46.9% of the population - the same as the current copayment exemption (for rural (1))
// local cabsolute 21950 // This will cover 46.9% of the population - the same as the current copayment exemption (for rural (2))
local cabsolute 21815 // This will cover 45.8% (actually 45.86%) of the population, the same as copayment exemptions under the current policy (SGBP)

set trace off
set traced 3

// Comment this out
// ---------------------
/*
keep if _n/2 == floor(_n/2)
keep if _n/2 == floor(_n/2)
keep if _n/2 == floor(_n/2)
*/


// ------------ Urban Model ----------------------------
local urban_regressors hsize i.hhh_education oven refrigerator car livingroomsper hasgasheating i.soc_st numchild16 numchild16_sq i.wallmaterial i.roofm i.mainwatersource i.oblast
xi: svy, subpop(urban): reg logpccd `urban_regressors'
varsformyrelabel
// construct and save the regression equation
variables_and_coeffs using "$WHO_KG_reports/`filename_root'_urban_variables_and_coeffs.csv", r(0.001) o
construct_reg_eqn , f("$WHO_KG_reports/`filename_root'_urban_equation.txt") r(0.0000001)
local equation_urban `"`r(equation)'"'
di "equation_urban is: `equation_urban'"
// Want to create a "dataset" of coefficients and their names so that one can plot these in stata
dataset_coefficients , f("$WHO_KG_reports/plotme_urban.dta")
cap drop logpccd_hat_urban
predict logpccd_hat_urban if e(sample)
xi: pmt2 logpccd `urban_regressors' [`svyweight'`svyexp'] if urban==1, cab(`cabsolute')  p(poorest40) quantilec(consq) graphme(1)
varsformyrelabel
dataout_pmt2 , l("Urban") c(`cabsolute') f("$WHO_KG_reports/`filename'") q(5)

// ------------ Rural Model ----------------------------
   local rural_regressors refrigerator car livingroomsper numchild11 numchild11_sq i.oblast i.typeofdwell i.roof // (1)
// local rural_regressors refrigerator car livingroomsper numchild11 numchild11_sq i.oblast i.typeofdwell i.roof i.additionaldw ln_land garage i.hhh_e i.bathroomout i.bathroomshared
// local rural_regressors refrigerator car livingroomsper numchild11 numchild11_sq i.oblast i.typeofdwell i.roof i.coldwatermeterinstalled i.soc_ // (2)
xi: svy, subpop(rural): reg logpccd `rural_regressors'
varsformyrelabel
variables_and_coeffs using "$WHO_KG_reports/`filename_root'_rural_variables_and_coeffs.csv", r(0.001) o
construct_reg_eqn , f("$WHO_KG_reports/`filename_root'_rural_equation.txt") r(0.0000001)
local equation_rural `"`r(equation)'"'
di "equation_rural: `equation_rural'"
di "equation_urban: `equation_urban'"

// Want to create a "dataset" of coefficients and their names so that one can plot these in stata
dataset_coefficients , f("plotme_rural.dta")
cap drop logpccd_hat_rural
predict logpccd_hat_rural if e(sample)
xi: pmt2 logpccd `rural_regressors' [`svyweight'`svyexp'] if rural==1, cab(`cabsolute') p(poorest40) quantilec(consq) graphme(1)
varsformyrelabel
dataout_pmt2 , l("Rural") c(`cabsolute') f("$WHO_KG_reports/`filename'") q(5) a

// ------------ Put them together Model ----------------------------
gen logpccd_hat = .replace logpccd_hat = logpccd_hat_urban if urban == 1replace logpccd_hat = logpccd_hat_rural if rural == 1
local appendorcreate = "a"foreach cutoff of numlist `cabsolute' {

	di "cutoff = `cutoff'"
	if ("`cutoffs'"~="") {
		di "absolute cutoff was not specified - percentile was specified"		// find out the value of logpccd that corresponds to the cutoff		_pctile logpccd [`svyweight'`svyexp'], n(100)		// return list			local logcutoff = r(r`cutoff')		di "logcutoff = `logcutoff'" 
		local explogcutoff = exp(`logcutoff')
		di "explogcutoff = `explogcutoff'"
	}
	else {
		di "absolute cutoff was specified"
		local logcutoff = ln(`cutoff')
		di "cutoff: `logcutoff'"
		local explogcutoff = exp(`logcutoff')
		di "explogcutoff = `explogcutoff'"
	}
	
	// get rid of decimal in the name of variable
	local cutoff2 = round(`cutoff')
	di "cutoff rounded = `cutoff2'"
		cap drop eligible_`cutoff2'	gen eligible_`cutoff2' = .	replace eligible_`cutoff2' = 1 if logpccd_hat <  `logcutoff' & logpccd_hat ~= .	replace eligible_`cutoff2' = 0 if logpccd_hat >= `logcutoff' & logpccd_hat ~= .
	
	//cap drop eligible 
	replace eligible = eligible_`cutoff2'	// This will generate the performance, given actual consumption, quintiles of consumption, and eligibility
	pmt_eligible eligible_`cutoff2' [`svyweight'`svyexp'], p(poorest40) qu(consq)
	dataout_pmt_eligible, l("All") f("$WHO_KG_reports/`filename'") q(5) c(`cutoff') `appendorcreate'	dataset_coverage , c(`cutoff') q(5) p("$WHO_KG_reports/dataset_coverage_all_`cutoff'.dta") cat("PMT (covers 45.9% of population)")
			if (`"`appendorcreate'"' == "") { 		local appendorcreate = "a" 	}}
exit

sort hhid
preserve
keep hhid eligible
isid hhid
save "$WHO_KG_processed/eligible_under_PMT.dta", replace

use "$WHO_KG_reports/dataset_coverage_all_`cabsolute'.dta", clear
// add coverage for 2009 PMT applied to 2009 data
// reshape long coverage, i(quantile) j(year)
gen coverage_percent = coverage*100
graph bar (asis) coverage_percent, over(quantile) title("Coverage at each quintile - all households") ytitle("Coverage (%)") // bar(1, color(red)) bar(2, color(blue))
graph export "$WHO_KG_reports/graph_coverage_all_`cabsolute'.pdf", replace
restore
