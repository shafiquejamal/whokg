clear
set more off
do setpaths.do

cd "$WHO_KG_processed/"
use "$WHO_KG_processed/health2010_kihs_relabeled.dta", clear
keep if reltohead == 1
isid hhid

// Looks like only the household head answered this question
tab illbutdidnotseek [aw=hhw], mi

// Now we have collapsed to a household level dataset, so the weight I will use is: hhw
tab consq famserv_bathing [aw=hhw], col
tab consq illbutdidnotseek [aw=hhw], col
// tab consq illbutdidnotseek [aw=expfact], col

tab consq notseek_notafford [aw=hhw], col
// tab consq notseek_notafford [aw=expfact], col

// Distribution is not as expected 
tab consq notseek_n if illbutdidnotseek == 1 [aw=hhw], col mi
