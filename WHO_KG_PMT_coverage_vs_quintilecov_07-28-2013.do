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

// This is the performance of the MBPF
insheet using "$WHO_KG_reports/WHO_KG_11-14-2012_coverage.csv", c clear
gen programtype = 0
replace programtype = 1 if geographycovered == "Exempt from Copayment"
save "$WHO_KG_reports/coverage_verus_quintilecov.dta", replace

// This has all the performance data
insheet using "$WHO_KG_reports/WHO_KG_PMTdevelopment_07-27-2013_2.csv", c clear
append using "$WHO_KG_reports/coverage_verus_quintilecov.dta"
replace programtype = 2 if programtype == .
label define programtype 0 "MBPF" 1 "SGBP" 2 "PMT" 3 "MBPF simulated to cover 45.9%"
label values programtype programtype

gen lnq1 = ln(q1)

// Relationship between quintile coverage and overall coverage is not at all linear
// twoway line q1 q2 q3 q4 q5 fractioncovered 

// Looks like there is an almost linear relationship between these performance measures and overall coverage 
twoway (line targetingaccuracy leakage undercoverage fractioncovered if programtype==2, lc(blue red green) xline(0.103, lc(black)) xline(0.458, lc(black)) )  /* 
	*/ (scatter targetingaccuracy fractioncovered if programtype==0, mcolor(blue) m(X)) (scatter leakage fractioncovered if programtype==0, mcolor(red) m(X)) /* 
	*/ (scatter undercoverage fractioncovered if programtype==0, mcolor(green) m(X)) /*
	*/ (scatter targetingaccuracy fractioncovered if programtype==1, mcolor(blue) m(circle)) (scatter leakage fractioncovered if programtype==1, mcolor(red) m(circle)) /* 
	*/ (scatter undercoverage fractioncovered if programtype==1, mcolor(green) m(circle)), legend (c(3)) title("Tergeting performance versus overall coverage") subtitle("PMT (lines), MBPF (x) and SGBP (circles) ") note("Source: KIHS 2010 and WHO calculations, 30 Jan 2013")

graph export `"$WHO_KG_reports/targeting_accuracy_vs_coverage.pdf"', replace

// MBPF quintile coverage at overall coverage = 0.103:
local MBPF_q1 = 0.2471986	
local MBPF_q2 = 0.1232354	
local MBPF_q3 = 0.0968192
local MBPF_q4 = 0.0411893
local MBPF_q5 = 0.0083770

// PMT quintile coverage at overall coverage = 0.103
local PMT_q1_p104 = 0.377381423	
local PMT_q2_p104 = 0.103891203
local PMT_q3_p104 = 0.022560427
local PMT_q4_p104 = 0.0161892
local PMT_q5_p104 = 0

local PMT_q1_p459 = 0.860017654					
local PMT_q2_p459 = 0.65804213
local PMT_q3_p459 = 0.475723317
local PMT_q4_p459 = 0.273227742
local PMT_q5_p459 = 0.030570889

local new_obs_number = _N+1
set obs `new_obs_number'
replace geographycovered="MBPF simulated 45.9% coverage" if _n == `new_obs_number'
replace programtype=3 if _n == `new_obs_number'
replace fractioncovered=0.458695985294738 if _n == `new_obs_number'

// The difference between PMT coverage per quintile and that of MBPF at coverage == 0.103
forv x = 1/5 {
	local PMT_minus_MBPF_q`x' 	= `PMT_q`x'_p104'-`MBPF_q`x''
	local MBPF_459_q`x' 		= `PMT_q`x'_p459'-`PMT_minus_MBPF_q`x''
	replace q`x'				= `MBPF_459_q`x'' if _n == `new_obs_number'
}
egen rowtotal_qs = rowtotal(q1 q2 q3 q4 q5)
gen fraction_covered_2 = 0.2*rowtotal_qs
save `"$WHO_KG_reports/stuff_versus_coverage_07-29-2013"', replace


twoway (line q1 q2 q3 q4 q5 fractioncovered if programtype==2, lc(blue red green black brown) xline(0.103, lc(black)) xline(0.458, lc(black)) )  	/* 
	*/ (scatter q1 fractioncovered if programtype==0, mcolor(blue)  m(X)) (scatter q2 fractioncovered if programtype==0, mcolor(red) m(X)) 			/* 
	*/ (scatter q3 fractioncovered if programtype==0, mcolor(green) m(X)) (scatter q4 fractioncovered if programtype==0, mcolor(black) m(X)) 		/*
	*/ (scatter q5 fractioncovered if programtype==0, mcolor(brown) m(X)) 																			/*
	*/ (scatter q1 fractioncovered if programtype==1, mcolor(blue)  m(Oh)) (scatter q2 fractioncovered if programtype==1, mcolor(red) m(Oh)) 		/* 
	*/ (scatter q3 fractioncovered if programtype==1, mcolor(green) m(Oh)) (scatter q4 fractioncovered if programtype==1, mcolor(black) m(Oh)) 		/*
	*/ (scatter q5 fractioncovered if programtype==1, mcolor(brown) m(Oh)) 																			/*
	*/ (scatter q1 fractioncovered if programtype==3, mcolor(blue)  m(S)) (scatter q2 fractioncovered if programtype==3, mcolor(red) m(S)) 			/* 
	*/ (scatter q3 fractioncovered if programtype==3, mcolor(green) m(S)) (scatter q4 fractioncovered if programtype==3, mcolor(black) m(S)) 		/*
	*/ (scatter q5 fractioncovered if programtype==3, mcolor(brown) m(S)), legend (c(5)) title("Quntile coverage versus overall coverage") subtitle("PMT (lines), MBPF (x), MBPF at 48.9% (square) and SGBP (circles) ") note("Source: KIHS 2010 and WHO calculations, 30 Jan 2013")
graph export `"$WHO_KG_reports/quintilecoverage_vs_coverage.pdf"', replace

twoway (line q1 q2 q3 q4 q5 fractioncovered if programtype==2, lc(blue red green black brown) xline(0.103, lc(black)) xline(0.458, lc(black)) )  	/* 
	*/ (scatter q1 fractioncovered if programtype==0, mcolor(blue)  m(X)) (scatter q2 fractioncovered if programtype==0, mcolor(red) m(X)) 			/* 
	*/ (scatter q3 fractioncovered if programtype==0, mcolor(green) m(X)) (scatter q4 fractioncovered if programtype==0, mcolor(black) m(X)) 		/*
	*/ (scatter q5 fractioncovered if programtype==0, mcolor(brown) m(X)) 																			/*
	*/ (scatter q1 fractioncovered if programtype==1, mcolor(blue)  m(Oh)) (scatter q2 fractioncovered if programtype==1, mcolor(red) m(Oh)) 		/* 
	*/ (scatter q3 fractioncovered if programtype==1, mcolor(green) m(Oh)) (scatter q4 fractioncovered if programtype==1, mcolor(black) m(Oh)) 		/*
	*/ (scatter q5 fractioncovered if programtype==1, mcolor(brown) m(Oh)) 																			/*
	*/ (scatter q1 fractioncovered if programtype==3, mcolor(blue)  m(S)) (scatter q2 fractioncovered if programtype==3, mcolor(red) m(S)) 			/* 
	*/ (scatter q3 fractioncovered if programtype==3, mcolor(green) m(S)) (scatter q4 fractioncovered if programtype==3, mcolor(black) m(S)) 		/*
	*/ (scatter q5 fractioncovered if programtype==3, mcolor(brown) m(S)), legend (c(5)) subtitle("PMT (lines), MBPF (x), MBPF at 48.9% (square) and SGBP (circles) ") note("Source: KIHS 2010 and WHO calculations, 30 Jan 2013")
graph export `"$WHO_KG_reports/quintilecoverage_vs_coverage_notitle.pdf"', replace


keep if programtype == 3 | programtype == 1
reshape long q, i(geographycovered) j(quintile)
graph bar (asis) q, over(geographycovered) over(quintile) asyvars title("Coverage per quintile at 45.9%") subtitle("MBPF simulated at 45.9% and SGBP exemption") bar(1, col(red)) bar(2, col(blue)) note("Source: KIHS 2010 and WHO calculations, 30 Jan 2013") blabel(total, format(%9.2fc))
graph export `"$WHO_KG_reports/coverage_per_quintile.pdf"', replace
graph bar (asis) q, over(geographycovered) over(quintile) asyvars bar(1, col(red)) bar(2, col(blue)) note("Source: KIHS 2010 and WHO calculations, 30 Jan 2013") blabel(total, format(%9.2fc))
graph export `"$WHO_KG_reports/coverage_per_quintile_notitle.pdf"', replace
stop
/*
local PMT_minus_MBPF_q1 = `PMT_q1_p104'-`MBPF_q1'
local PMT_minus_MBPF_q2 = `PMT_q2_p104'-`MBPF_q2' 
local PMT_minus_MBPF_q3 = `PMT_q3_p104'-`MBPF_q3'
local PMT_minus_MBPF_q4 = `PMT_q4_p104'-`MBPF_q4'
local PMT_minus_MBPF_q5 = `PMT_q5_p104'-`MBPF_q5'

local MBPF_459_q1 = `PMT_q1_p459'-`PMT_minus_MBPF_q1'
local MBPF_459_q2 = `PMT_q2_p459'-`PMT_minus_MBPF_q2'
local MBPF_459_q3 = `PMT_q3_p459'-`PMT_minus_MBPF_q3'
local MBPF_459_q4 = `PMT_q4_p459'-`PMT_minus_MBPF_q4'
local MBPF_459_q5 = `PMT_q5_p459'-`PMT_minus_MBPF_q5'
*/


stop
local qxq1 = ""
forv x = 2/5 {
	gen q`x'q1 = q`x'/q1
	local qxq1 `"`qxq1' q`x'q1 "'
}
di `"`qxq1'"'

twoway line `qxq1' fractioncovered
