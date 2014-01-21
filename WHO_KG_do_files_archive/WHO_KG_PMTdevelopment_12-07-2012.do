clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all

// set scheme "scheme-for_ms_word.scheme"

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_12-04-2012.dta", clear
local datetouse "28 Nov 2012"

if (0) {
// forv x = 10/18 {
	local urban_regressors hsize i.hhh_education oven refrigerator car livingroomsper i.hasgasheating i.soc_st numchild16 numchild16_sq i.wallmaterial i.roofm i.mainwatersource i.oblast
	xi: svy, subpop(urban): reg logpccd `urban_regressors'
//	di "age: `x'"
//	di e(r2)
// }
}
// exit

// discarded soc_st, female, sheep, additionalhouse, hasgas, washingmachine, floormat, roofmat, watersupply, ovenfireplace, additionaldwellingandtype
// forv x = 10/18 {
	local rural_regressors refrigerator car livingroomsper numchild11 numchild11_sq i.oblast i.typeofdwell i.roof
	xi: svy, subpop(rural): reg logpccd `rural_regressors'
	// di "age: `x'"
	// di e(r2)
// }
exit

foreach var of varlist refrigerator car livingroomsper numchild11 numchild11_sq oblast typeofdwell cows typeofbath additionaldwe  {
	di "var: `var'"
	count if `var' == .
}
