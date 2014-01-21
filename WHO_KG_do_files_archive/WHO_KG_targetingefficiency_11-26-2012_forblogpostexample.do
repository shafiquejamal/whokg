clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_02-07-2012.dta", clear
local datetouse "28 Nov 2012"

/*
// Look at coverage of each quintile. This also generates inclusion and exclusion errors assuming target group is poorest quintile 
local filename "WHO_KG_11-14-2012_coverage"
pmt_eligible receives_MBPF 			[aw=expfact], p(poorest20) qu(consq)
dataout_pmt_eligible, l("Recevies MBPF") f("$WHO_KG_reports/`filename'.csv") q(5) c(0) dataset_coverage , c(0) q(5) p("$WHO_KG_reports/`filename'_receivesMBPF.dta") c("MBPF")
pmt_eligible exemptfromcopayment 	[aw=expfact], p(poorest20) qu(consq)
dataout_pmt_eligible, l("Exempt from Copayment") f("$WHO_KG_reports/`filename'.csv") q(5) c(0) adataset_coverage , c(0) q(5) p("$WHO_KG_reports/`filename'_exemptfromcopayment.dta") c("Current Policy")

// Now put the coverage rates all one graph
preserve
use "$WHO_KG_reports/`filename'_receivesMBPF.dta", clear
append using "$WHO_KG_reports/`filename'_exemptfromcopayment.dta"
replace coverage = coverage * 100
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
graph bar (asis) coverage if category=="Current Policy", over(quantile) ascat bar(1, color(green)) bar(2, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)")
graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012_exemptcurrpol.pdf", replace
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") blabel(total, format(%9.0f)) ytitle("Coverage (%)")
graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012_exemptcurrpol_and_MPBF.pdf", replace
restore
*/

rename receives_MBPF MechanismA
label var MechanismA "Qualification under Mechanism A"
label define MechanismA 0 "Does not qualify under Mechanism A" 1 "Qualifies under Mechanism A"
label values MechanismA MechanismA
rename exemptfrom    MechanismB
label var MechanismB "Qualification under Mechanism B"
label define MechanismB 0 "Does not qualify under Mechanism B" 1 "Qualifies under Mechanism B"
label values MechanismB MechanismB

// Mean consumption of exempt and non exempt
// graphmeanofeachcat pccd, g("hey these are graph options") c(exemptfrom)
graph bar pccd [aw=expfact], over(MechanismA) title("Mean annual consumption comparison") ytitle("Consumption")  blabel(total, format(%9.0fc))
graph export "$WHO_KG_reports/MechanismA.png", replace
graph bar pccd [aw=expfact], over(MechanismB)    title("Mean annual consumption comparison") ytitle("Consumption")  blabel(total, format(%9.0fc))
graph export "$WHO_KG_reports/MechanismB.png", replace

// label values receives_MBPF receives_MBPF_n
// label values exemptfromcopayment exemptfromcopayment_n
overlappingcatgraphmean pccd using "$WHO_KG_reports/eraseme.dta", gc(graph bar (asis)) go( asy over(catvariablelevel, sort(catvariablelevel_n) lab(angle(15) labs(vsmall))) over(catvariablelabel, sort(catvariablelevel_n) lab(angle(0) labs(vsmall))) asc title("Average consumption of groups within population") ytitle("Per capita HH consumption (LCU)", margin(medium)) bar(4, col(navy) fi(inten70)) bar(1, col(maroon)) bar(3, col(navy)) bar(2, col(maroon) fi(inten70)) legend(size(vsmall)) blabel(total, format(%9.0fc)) legend(order(1 2 3 4))) catvarlist("MechanismA MechanismB") replace
graph export "$WHO_KG_reports/MechanismA_MechanismB.png", replace
exit
label values receives_MBPF receives_MBPF
label values exemptfromcopayment exemptfromcopayment


/*
svy: mean pccd if exemptfrom == 1
svy: mean pccd if exemptfrom == 0
svy: mean pccd if receives_MBPF == 1
svy: mean pccd if receives_MBPF == 0
*/

// keep
// % of exempt, non-exempt in each quintile
tab consq exemptfrom [aw=expfact], col mi
taboutgraph consq exemptfrom [aw=expfact]    using "$WHO_KG_reports/composition_distribution_exemptfromcopayments.csv", gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") title(`"Distribution of Population"') ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc)))

// keep
// % of MBPF, non-MBPF recipients in each quintile
tab consq receives_MBPF [aw=expfact], col mi
// tabout consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/receives_MBPF.csv", cells(col) f(2 2 2 2) replace
taboutgraph consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/composition_distribution_receives_MBPF.csv",                                 gc(`"graph bar"') ta(cells(col) f(2 2 2 2)) replace go( note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") b1title("Quintile") title(`"Distribution of Population"') ytitle("Percent of population in the quntile", margin(medium)) legend(size(small)) blabel(total, format(%9.0fc))) 

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

exit

// skip
graph bar (mean) hospitalized [aw=expfact], over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"Share reporting hospitalization in the past 12 months"') ytitle("Fraction of group", margin(medium)) blabel(total, format(%9.2fc)) subtitle("Average for each group") // legend(size(small) `relabellegend')
graph export "$WHO_KG_reports/Graph_share_reporting_hospitalization_exempt.pdf", replace

graph bar (mean) appliedmed [aw=expfact], over(exempt) note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") title(`"Share reporting applied for medical assistance in the past 30 days"') ytitle("Fraction of group", margin(medium)) blabel(total, format(%9.2fc)) subtitle("Average for each group") // legend(size(small) `relabellegend')
graph export "$WHO_KG_reports/Graph_share_reporting_appliedmedassistance_exempt.pdf", replace

// skip
local vlist appliedmed hospitalized
makelegendlabelsfromvarlabels `vlist', local(relabellegend) c(30)
graph bar (mean) `vlist' [aw=expfact], over(exempt) /* note("Source: KIHS 2010 data and WHO Calculations, `datetouse'") */ title(`"Share reporting applied for medical assistance in the past 30 days"') ytitle("Fraction of group", margin(medium)) blabel(total, format(%9.2fc)) subtitle("Average for each group") legend(size(vsmall) `relabellegend')
graph export "$WHO_KG_reports/Graph_share_reporting_appliedmedassistance_hospitalized_exempt.png", replace




