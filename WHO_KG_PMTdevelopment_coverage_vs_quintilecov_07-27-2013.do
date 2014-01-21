clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all

// set scheme "scheme-for_ms_word.scheme"

// The target group for this will be the poorest 40% percent of the population (will define these people as "the poor")
//
// 27 July 2013: I want to examine the relationship between overall coverage rate and coverage at each quintile. The reason is that I want to compare the MBPF program with the SGBP at the 
// 	same coverage rate, but they have different coverage rates. So I want to see about simulating an increased coverage rate for the MBPF, and hopefully this exercise will help. 

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_hhlevel_12-04-2012.dta", clear
local filename_root "WHO_KG_PMTdevelopment_07-30-2013b"
local extension = ".csv"local filename = "`filename_root'`extension'"
local filename2 = "`filename_root'_`extension'"local filename_outreg = "`filename_root'_outreg`extension'"

local datetouse "27 July 2013"
qui svysetlocal svyweight = r(wtype)local svyexp    = r(wexp) di "[`svyweight'`svyexp']"

// start loop here: loop over many cutoffs

// set the cutoff
// will loop over cutoffs
// local cabsolute 21815 // This will cover 45.8% (actually 45.86%) of the population, the same as copayment exemptions under the current policy (SGBP)
local cabsolute_list 21815
di `"cabsolute_list =`cabsolute_list'"'

local urban_regressors hsize i.hhh_education oven refrigerator car livingroomsper hasgasheating i.soc_st numchild16 numchild16_sq i.wallmaterial i.roofm i.mainwatersource i.oblast
local rural_regressors refrigerator car livingroomsper numchild11 numchild11_sq i.oblast i.typeofdwell i.roof // (1)

set trace off
set traced 2
local count = 0
foreach cutoff of numlist `cabsolute_list' {
	local count = `count' + 1
	di "cutoff = `cutoff'"

	// ------------ Urban Model ----------------------------

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

	xi: pmt2 logpccd `urban_regressors' [`svyweight'`svyexp'] if urban==1, cab(`cutoff')  p(poorest40) quantilec(consq) graphme(1)
	varsformyrelabel

	if (`count' == 1) {
		local a ""
	}
	else {
		local a "a"
	}

	dataout_pmt2 , l("Urban") c(`cutoff') f("$WHO_KG_reports/`filename'") q(5) `a'

	
	// ------------ Rural Model ----------------------------
  
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

	xi: pmt2 logpccd `rural_regressors' [`svyweight'`svyexp'] if rural==1, cab(`cutoff') p(poorest40) quantilec(consq) graphme(1)
	varsformyrelabel
	// dataout_pmt2 , l("Rural") c(`cutoff') f("$WHO_KG_reports/`filename'") q(5) a
	
	// ------------ Put them together Model ----------------------------
	cap drop logpccd_hat
	gen logpccd_hat = .	replace logpccd_hat = logpccd_hat_urban if urban == 1	replace logpccd_hat = logpccd_hat_rural if rural == 1
	
	if ("`cutoffs'"~="") {
		di "absolute cutoff was not specified - percentile was specified"		// find out the value of logpccd that corresponds to the cutoff		_pctile logpccd [`svyweight'`svyexp'], n(100)		// return list			local logcutoff = r(r`cutoff')		di "logcutoff = `logcutoff'" 
		local explogcutoff = exp(`logcutoff')
		di "explogcutoff = `explogcutoff'"
	}
	else {
		di "absolute cutoff was specified"
		local logcutoff = ln(`cutoff')
		di "logcutoff: `logcutoff'"
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
	// dataout_pmt_eligible, l("All") f("$WHO_KG_reports/`filename'") q(5) c(`cutoff') a
	dataout_pmt_eligible, l("All") f("$WHO_KG_reports/`filename2'") q(5) c(`cutoff') `a' // This file has the overall coverage rates without breaking down by urban/rural	dataset_coverage , c(`cutoff') q(5) p("$WHO_KG_reports/dataset_coverage_all_`cutoff'.dta") cat("PMT (covers 45.9% of population)")
		}
exit

sort hhid
preserve
keep hhid eligible
isid hhid
save "$WHO_KG_processed/eligible_under_`cabsolute'_PMT.dta", replace

use "$WHO_KG_reports/dataset_coverage_all_`cabsolute'.dta", clear
// add coverage for 2009 PMT applied to 2009 data
// reshape long coverage, i(quantile) j(year)
gen coverage_percent = coverage*100
graph bar (asis) coverage_percent, over(quantile) title("Coverage at each quintile - all households") ytitle("Coverage (%)") // bar(1, color(red)) bar(2, color(blue))
graph export "$WHO_KG_reports/graph_coverage_all_`cabsolute'.pdf", replace
restore
