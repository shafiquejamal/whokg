clear
clear matrix
set more off
clear mata
set maxvar 32767
do setpaths.do
program drop _all
program define taboutgraphbar

//	syntax varlist
	version 9.1
	// di `"`0'"'
	cap drop _v*
	cap ssc install lstrfun
	
	local tabout_arguments `"`0'"'
	// di `"First: `tabout_arguments'"'
	
	// pull out the note from 0
	if (regexm(`"`tabout_arguments'"',`"note\([^\)]*\)"')) {
		local note = regexs(0)
		// local tabout_arguments = regexr(`"`tabout_arguments'"',`"note.*\(.*\)"'," ")
		lstrfun tabout_arguments, regexr(`"`tabout_arguments'"',`"note\([^\)]*\)"'," ")
		di `"note removed: `tabout_arguments'"'
		di `"note is: `note'"'
	}
	
	if (regexm(`"`tabout_arguments'"',`"b1title\(.*\)"')) {
		local b1title = regexs(0)
		// di regexs(0)
		// local tabout_arguments = regexr(`"`tabout_arguments'"',`"b1title\([^\)]*\)"'," ")
		lstrfun tabout_arguments, regexr(`"`tabout_arguments'"',`"b1title\([^\)]*\)"'," ")
		di `"b1title: `tabout_arguments'"'
	}
	
	if (regexm(`"`tabout_arguments'"',`"subtitle\(.*\)"')) {
		local subtitle = regexs(0)
		// di regexs(0)
		// local tabout_arguments = regexr(`"`tabout_arguments'"',`"subtitle\([^\)]*\)"'," ")
		lstrfun tabout_arguments, regexr(`"`tabout_arguments'"',`"subtitle\([^\)]*\)"'," ")
		di `"subtitle: `tabout_arguments'"'
	}
	
	if (regexm(`"`tabout_arguments'"',`"ytitle\(.*\)"')) {
		local ytitle = regexs(0)
		// di regexs(0)
		// local tabout_arguments = regexr(`"`tabout_arguments'"',`"ytitle\([^\)]*\)"'," ")
		lstrfun tabout_arguments, regexr(`"`tabout_arguments'"',`"ytitle\([^\)]*\)"'," ")
		di `"ytitle: `tabout_arguments'"'
	}
	
	if (regexm(`"`tabout_arguments'"',`" title\(.*\)"')) {
		local title = regexs(0)
		// di regexs(0)
		// local tabout_arguments = regexr(`"`tabout_arguments'"',`" title\(.*\)"'," ")
		lstrfun tabout_arguments, regexr(`"`tabout_arguments'"',`" title\([^\)]*\)"'," ")
		di `"title: `tabout_arguments'"'
	}
		
	// first generate the table
	qui tabout `tabout_arguments' 
	local number_of_rows 	= r(r)
	local number_of_columns = r(c)
	return list
	
	// get the filename
	// di `"regexm:"'
	// di regexm(`"`tabout_arguments'"',`"using.*"((.*)\.(.+))""')
	if (regexm(`"`tabout_arguments'"',`"using.*"((.*)\.(.+))""')) {
		local pathtofile_original 			= regexs(1)
		local pathtofile_withoutextension 	= regexs(2)
		local pathtofile_extension 			= regexs(3)
		// local pathtofile_col1plot = `"`pathtofile_withoutextension'_col1plot.`pathtofile_extension'"'
	}
	
	// open the file and process it. 
	
	local count = 0
	tempname fhr
	tempname fhw
	tempfile tf
	file open `fhr' using `"`pathtofile_original'"', r 
	file open `fhw' using `"`tf'"', t write all replace
	
	local count = `count' + 1

	// First line is variable label. 
	file read `fhr' line
	return list
	local count = 1
	while r(eof)==0 {
		local count = `count' + 1
		// di `"count = `count'"'
		file read `fhr' line
		
		if (`count'~=3) { // This line is units - we can throw this away
			file write `fhw' `"`line'"' _n
			// di `"`line'"'
		}
    }
		
	file close `fhr'
	file close `fhw'
	
	preserve
	qui insheet using `"`tf'"', t clear
	save `"`pathtofile_withoutextension'.dta"', replace

	drop total
	drop if _n == _N
	
	local count = 0
	foreach var of varlist * {
		local count = `count' + 1
		// di `"var: `var'"'
		
		if (`count'==1) {
			qui rename `var' x
		}
		else {
			/* tempvar v`count'
			rename `var' `v`count''
			di "v_count = v`count'"
			local v`count'_labelforfilename = `"`var'"'
			local v`count'_varlabel : variable label `v`count''
			*/
			qui rename `var' _v`count'
			local v`count'_labelforfilename = `"`var'"'
			local v`count'_varlabel : variable label _v`count'
		}
	}
	
	if (`"`b1title'"'==`""') {
		local xtitle : variable label x
		local b1title = `"b1title(`"`xtitle'"')"'
	}
	
	if (`"`title'"'==`""') {
		local title = `"title(`"Composition of Population"')"'
	}
	
	if (`"`ytitle'"'==`""') {
		local ytitle = `"ytitle(`"Percent"')"'
	}
	
	if (`"`subtitle'"'==`""') {
		local subtitle = `"subtitle(`""')"'
	}
	
	// graph each y var, then all y vars
	forv x = 2/`count' {
		graph bar (asis) _v`x', over(x) `b1title' subtitle(`"`v`x'_varlabel'"') `title' `ytitle' `note'
		// di `"subtitle: subtitle(`"`v`x'_varlabel'"'), `v`x'_varlabel', v`x'_varlabel"'
		graph export "`pathtofile_withoutextension'_`v`x'_labelforfilename'.pdf", replace
		// local over = `"`over' over(`v`x'')"'
	}
	// graph all yvars

	qui reshape long _v, i(x) j(category)
	cap tostring category, replace
	forv x = 2/`count' {
		qui replace category = `"`v`x'_varlabel'"' if category == `"`x'"'
	}
	graph bar (asis) _v, over(category) over(x) asyvars `b1title' `title' `subtitle' `ytitle' `note' 
	graph export "`pathtofile_withoutextension'_allvars.pdf", replace

	restore
end program

program define graphmeanofeachcat

	syntax varname [if], Graphoptions(string asis) Categoricalvar(varname)
	version 9.1
	marksample touse
	
	di `"varname: `varname'"'
	di `"graphoptions: `graphoptions'"'
	di `"categoricalvar: `categoricalvar'"'
	
	tempvar levels
	levelsof `categoricalvar', local(`levels')
	

end program

cd "$WHO_KG_processed"
use "$WHO_KG_processed/health2010_kihs_relabeled_merged_02-07-2012.dta", clear

// Look at coverage of each quintile. This also generates inclusion and exclusion errors assuming target group is poorest quintile 
local filename "WHO_KG_11-14-2012_coverage"
pmt_eligible receives_MBPF 			[aw=expfact], p(poorest20) qu(consq)
dataout_pmt_eligible, l("Recevies MBPF") f("$WHO_KG_reports/`filename'.csv") q(5) c(0) set trace off
set traced 1dataset_coverage , c(0) q(5) p("$WHO_KG_reports/`filename'_receivesMBPF.dta") c("MBPF")
pmt_eligible exemptfromcopayment 	[aw=expfact], p(poorest20) qu(consq)
dataout_pmt_eligible, l("Exempt from Copayment") f("$WHO_KG_reports/`filename'.csv") q(5) c(0) adataset_coverage , c(0) q(5) p("$WHO_KG_reports/`filename'_exemptfromcopayment.dta") c("Current Policy")

// Now put the coverage rates all one graph
preserve
use "$WHO_KG_reports/`filename'_receivesMBPF.dta", clear
append using "$WHO_KG_reports/`filename'_exemptfromcopayment.dta"
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
// graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
graph bar (asis) coverage, over(category) over(quantile) asyvars bar(1, color(green)) bar(2, color(blue)) b1title("Quintile") title("Coverage Rates of Copayment Exemptions") subtitle("Current Policy and MBPF") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
graph export "$WHO_KG_reports/Graph_coverage_rates_11-14-2012.pdf", replace
restore

// Mean consumption of exempt and non exempt
// graphmeanofeachcat pccd, g("hey these are graph options") c(exemptfrom)
graph bar pccd [aw=expfact], over(receives_MBPF) title("Mean annual consumption comparison") subtitle("Groups receiving and not receiving MBPF") ytitle("Consumption") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
graph export "$WHO_KG_reports/Graph_mean_consumption_receivesMBPF_11-14-2012.pdf", replace
graph bar pccd [aw=expfact], over(exemptfrom)    title("Mean annual consumption comparison") subtitle("Groups receiving and not receiving exemptions under current policy") ytitle("Consumption") note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012")
graph export "$WHO_KG_reports/Graph_mean_consumption_exemptcurrentpolicy_11-14-2012.pdf", replace

svy: mean pccd if exemptfrom == 1
svy: mean pccd if exemptfrom == 0
svy: mean pccd if receives_MBPF == 1
svy: mean pccd if receives_MBPF == 0

// % of MBPF, non-MBPF recipients in each quintile
tab consq receives_MBPF [aw=expfact], col mi
// tabout consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/receives_MBPF.csv", cells(col) f(2 2 2 2) replace
set trace off
set traced 1
taboutgraphbar consq receives_MBPF [aw=expfact] using "$WHO_KG_reports/receives_MBPF.csv", cells(col) f(2 2 2 2) replace note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012") b1title("Quintile") ytitle("Percent of population in the quntile")

// % of exempt, non-exempt in each quintile
tab consq exemptfrom [aw=expfact], col mi
taboutgraphbar consq exemptfrom [aw=expfact] using "$WHO_KG_reports/exemptfromcopayments.csv", cells(col) f(2 2 2 2) replace note("Source: KIHS 2010 data and WHO Calculations, 14 Nov 2012") b1title("Quintile") ytitle("Percent of population in the quntile")

// Inclusion, Exclusion relative to poverty lines

