clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all
discard
set scheme for_ms_word

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_12-04-2012.dta", clear
sort hhid 
merge m:1 hhid using "$WHO_KG_processed/eligible_under_PMT.dta", update replace
tab _m
drop _m
tab eligible, nol mi
local datetouse "30 Jan 2013"
local filename "WHO_KG_11-14-2012_coverage"

// Target group is poorest 40 percent of the population

// Look at coverage of each quintile. This also generates inclusion and exclusion errors assuming target group is poorest quintile 
pmt_eligible receives_MBPF 			[aw=expfact], p(poorest40) qu(consq)
dataout_pmt_eligible, l("Recevies MBPF") f("$WHO_KG_reports/`filename'.csv") q(5) c(0)
dataset_coverage , q(5) p("$WHO_KG_reports/`filename'_receivesMBPF.dta") cat("MBPF (covers 10.3% of population)") c(1)
pmt_eligible exemptfromcopayment 	[aw=expfact], p(poorest40) qu(consq)
dataout_pmt_eligible, l("Exempt from Copayment") f("$WHO_KG_reports/`filename'.csv") q(5) c(0) adataset_coverage , q(5) p("$WHO_KG_reports/`filename'_exemptfromcopayment.dta") cat("Current Policy (covers 45.8% of population)") c(1)

// Now put the coverage rates all one graph
preserve
// ************************* Make sure these filenames are correct! In particular, the threshold suffix *************************
use "$WHO_KG_reports/`filename'_receivesMBPF.dta", clear
append using "$WHO_KG_reports/`filename'_exemptfromcopayment.dta"
append using "$WHO_KG_reports/dataset_coverage_all_21815.dta"
gen ordertoplot = 0
replace ordertoplot = 2 if category == "Current Policy (covers 45.8% of population)"
replace ordertoplot = 3 if category == "MBPF (covers 10.3% of population)"
replace ordertoplot = 1 if category == "PMT (covers 45.9% of population)"
replace coverage = coverage * 100
encode category, gen(catn)
makelegendlabelsfromvallabn, local(relabellegend) c(30) valuelabelname(catn)
save "$WHO_KG_processed/coverage_rates_per_quintile_three_targetingoptions.dta", replace
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(red)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(red)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
// graph bar (asis) coverage if category=="Current Policy", over(quantile) ascat bar(1, color(red)) bar(2, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)")
// graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012_exemptcurrpol.pdf", replace
graph bar (asis) coverage, over(category, sort(ordertoplot)) over(quantile) asyvars bar(1, color(orange)) bar(2, color(blue)) bar(3, color(red)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy, MBPF and a preliminary PMT") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small) `relabellegend') 
graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012_exemptcurrpol_MPBF_PMT.pdf", replace
graph bar (asis) coverage, over(category, sort(ordertoplot)) over(quantile) asyvars bar(1, color(orange)) bar(2, color(blue)) bar(3, color(red)) b1title("Quintile") 																										note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small) `relabellegend') 
graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012_exemptcurrpol_MPBF_PMT_notitle.pdf", replace

// Now plot the coverage rates for each program on a separate graph
use "$WHO_KG_reports/`filename'_exemptfromcopayment.dta", clear
replace coverage = coverage * 100
encode category, gen(catn)
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_exemptcurrpol.pdf", replace
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") 																			note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_exemptcurrpol_notitle.pdf", replace

use "$WHO_KG_reports/`filename'_receivesMBPF.dta", clear
replace coverage = coverage * 100
encode category, gen(catn)
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("MBPF") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_receivesMBPF.pdf", replace
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") 																  note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_receivesMBPF_notitle.pdf", replace

use "$WHO_KG_reports/dataset_coverage_all_22085.dta", clear
replace coverage = coverage * 100
encode category, gen(catn)
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Proposed PMT") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_PMT.pdf", replace
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(blue)) b1title("Quintile") 																		  note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)", margin(medium)) legend(size(small)) 
graph export "$WHO_KG_reports/Graph_coverage_rates_01-29-2013_PMT_notitle.pdf", replace

restore

// Mean consumption of exempt and non exempt
graph bar pccd [aw=expfact], over(receives_MBPF) title("Mean annual consumption comparison") subtitle("Groups receiving and not receiving MBPF") ytitle("Consumption") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0fc))
graph export "$WHO_KG_reports/Graph_mean_consumption_receivesMBPF_11-14-2012.pdf", replace
graph bar pccd [aw=expfact], over(exemptfrom)    title("Mean annual consumption comparison") subtitle("Groups receiving and not receiving exemptions under current policy") ytitle("Consumption") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0fc))
graph export "$WHO_KG_reports/Graph_mean_consumption_exemptcurrentpolicy_11-14-2012.pdf", replace

// label values receives_MBPF receives_MBPF_n
// label values exemptfromcopayment exemptfromcopayment_n
overlappingcatgraphmean pccd using "$WHO_KG_reports/eraseme.dta", gc(graph bar (asis)) catvarlist("exempt receives") 			v(0 "Non-beneficiary" 1 "Beneficiary") over1options(lab(angle(15) labs(vsmall))) over2options(lab(angle(0) labs(vsmall))) go(note(`"Source: KIHS 2010 data and WHO Calculations, `datetouse' "') asy asc title("Average consumption of groups within population") ytitle("Per capita HH consumption (LCU)", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc)) ) replace
graph export "$WHO_KG_reports/Graph_mean_consumption_exemptcurrentpolicy_MBPF_11-14-2012.pdf", replace

overlappingcatgraphmean pccd using "$WHO_KG_reports/eraseme.dta", gc(graph bar (asis)) catvarlist("exempt receives eligible") 	v(0 "Non-beneficiary" 1 "Beneficiary") over1options(lab(angle(15) labs(vsmall))) over2options(lab(angle(0) labs(vsmall))) replace go(note(`"Source: KIHS 2010 data and WHO Calculations, `datetouse' "') asy asc title("Average consumption of groups within population") ytitle("Per capita HH consumption (LCU)", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 
graph export "$WHO_KG_reports/Graph_mean_consumption_exemptcurrentpolicy_MBPF_PMT_11-14-2012.pdf", replace

// distribution of exempt and non-exempt
// % of exempt, non-exempt in each quintile
tab consq exemptfrom [aw=expfact], col mi
taboutgraph consq exemptfrom [aw=expfact]    using "$WHO_KG_reports/composition_distribution_exemptfromcopayments.csv",         gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") title(`"Distribution of Population"') subtitle("Current Exemption Policy") ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc)))
taboutgraph consq exemptfrom [aw=expfact]    using "$WHO_KG_reports/composition_distribution_exemptfromcopayments_notitle.csv", gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") 																			ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc)))

// distribution of MBPF and non-MBPF
// % of MBPF, non-MBPF recipients in each quintile
tab consq receives_MBPF [aw=expfact], col mi
taboutgraph consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/composition_distribution_receives_MBPF.csv", 			gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") title(`"Distribution of Population"') subtitle("MBPF") ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 
taboutgraph consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/composition_distribution_receives_MBPF_notitle.csv", 	gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") 													   ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 

// distribution of PMT eligible and ineligible
// % of PMT==1, PMT==0 in each quintile
tab consq eligible [aw=expfact], col mi
// tabout consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/receives_MBPF.csv", cells(col) f(2 2 2 2) replace
taboutgraph consq eligible [aw=expfact] using "$WHO_KG_reports/composition_distribution_PMTeligible.csv", 			gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") title(`"Distribution of Population"') subtitle("Using PMT") ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 
taboutgraph consq eligible [aw=expfact] using "$WHO_KG_reports/composition_distribution_PMTeligible_notitle.csv",	gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( bar(2, color(blue)) bar(1, color(red)) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") 									 						ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 

// mean expenditures on inpatient, outpatient, total healthcare, by exemptionstatus
// FIX THIS: Legend is using variable names instead of variable labels
// Confirm with melitta that this is ok
// restrict to any contact with HC system

// For next two, I am missing the DRUG EXP
// replace below with Stacked (IPEXP, OPEXP, DRUGEXP = TOTAL)

// show this, then  restrict, this one before the next one
// non-restricted
local vlist IPEXP OPEXP DRUGEXP
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(30)
graph bar (mean) `vlist' [aw=expfact], stack over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"Annual OOP health care spending (LCU)"') ytitle("LCU") blabel(total, format(%9.0fc)) subtitle("Average for each group, entire population") legend(size(small) `relabellegend') // nolabel
graph export "$WHO_KG_reports/Graph_healthcareexp_LCU.pdf", replace

// restricted
graph bar (mean) `vlist' if anycontacthealthcare == 1 [aw=expfact], stack over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"Annual OOP health care spending (LCU)"') ytitle("LCU") blabel(total, format(%9.0fc)) subtitle("Average for each group, recent users of healthcare only") legend(size(small) `relabellegend') // nolabel
graph export "$WHO_KG_reports/Graph_healthcareexp_LCU_restricted_to_usersofhealthcareonly.pdf", replace

// show this, then restrict
local vlist IPEXP_ OPEXP_ DRUGEXP_
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(35)
graph bar (mean) `vlist' [aw=expfact], stack over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"OOP health care spending as a percent of consumption"') ytitle("Percent of per capita consumption", margin(medium)) blabel(total, format(%9.0fc)) subtitle("Average for each group") legend(size(vsmall) `relabellegend') // nolabel
graph export "$WHO_KG_reports/Graph_healthcareexp_fractionofpccd.pdf", replace

// restricted
graph bar (mean) `vlist' if anycontacthealthcare == 1 [aw=expfact], stack over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"OOP health care spending as a percent of consumption"') ytitle("Percent of per capita consumption", margin(medium)) blabel(total, format(%9.0fc)) subtitle("Average for each group, healthcare users only") legend(size(vsmall) `relabellegend') // nolabel
graph export "$WHO_KG_reports/Graph_healthcareexp_fractionofpccd_restricted_to_usersofhealthcareonly.pdf", replace


// ----------------------- PROFILE THE MBPF RECIPIENTS ----------------------------------

tab receives_MBPF hospitalized [aw=expfact], col r freq
tab exempt 		  hospitalized [aw=expfact], col r freq

tab receives_MBPF appliedmed [aw=expfact], col r freq
tab exempt 		  appliedmed [aw=expfact], col r freq

tab receives_MBPF child5 [aw=expfact], col r freq
tab exempt 		  child5 [aw=expfact], col r freq

tab receives_MBPF eld70 [aw=expfact], col r freq
tab exempt 		  eld70 [aw=expfact], col r freq

tab receives_MBPF iswomanofreproductiveage  [aw=expfact], col r freq
tab exempt        iswomanofreproductiveage  [aw=expfact], col r freq

/*
keep if reltohead == 1

keep if consq == 5
sum * [aw=hhw]
*/

svy: mean female if 	noMBPFbutisexempt == 1
svy: mean age if 		noMBPFbutisexempt == 1
svy: mean pccd if 		noMBPFbutisexempt == 1
svy: mean child18 if 	noMBPFbutisexempt == 1
svy: mean eld60 if 		noMBPFbutisexempt == 1
svy: mean urban if		noMBPFbutisexempt == 1
svy: mean noMBPFbutisexempt

svy: mean female if 	MPBFbutnotexempt == 1
svy: mean age if 		MPBFbutnotexempt == 1
svy: mean pccd if 		MPBFbutnotexempt == 1
svy: mean child18 if 	MPBFbutnotexempt == 1
svy: mean eld60 if 		MPBFbutnotexempt == 1
svy: mean urban if		MPBFbutnotexempt == 1
svy: mean MPBFbutnotexempt

svy: mean female if 	MBPFandexempt == 1
svy: mean age if 		MBPFandexempt == 1
svy: mean pccd if 		MBPFandexempt == 1
svy: mean child18 if 	MBPFandexempt == 1
svy: mean eld60 if 		MBPFandexempt == 1
svy: mean urban if		MBPFandexempt == 1
svy: mean MBPFandexempt
