clear
set more off
do setpaths.do
program drop _all
program define makeonezero

	syntax varlist [if/]
	version 9.1 
	marksample touse
	
	foreach var of varlist `varlist' {
		// di "----------------------"
		// di "var: `var'"
		// tab `var', mi
		qui replace `var' = 1 if `var' ~= .
		qui replace `var' = 0 if `var' == . & `if'
		// tab `var', mi
		// count if `if' & `var' == .
	}

end program

cd "$WHO_KG_processed/"
use "$WHO_KG_hhsurveydata/health2010&kihs.dta", clear

// relabel the value labels to english
do "$WHO_KG_hhsurveydata/value_labels_label_define_commands2.do"
label define lang 1 "Russian" 2 "Kyrgyz", modify

// relabel variable labels
label var hhid "Household ID"
label var lang "Language"
gen male = .
replace male = 1 if a2 == 1
replace male = 0 if a2 == 2
label define male 0 "female" 1 "male"
label values male male
renamevarandvaluelabel a3 reltohead
label var reltohead "Relationship to HH head"
gen hhh = .
replace hhh = 1 if reltohead == 1
replace hhh = 0 if reltohead ~= 1 & reltohead ~=. & hhh ~= 1
label var hhh "Household member is household head"
label define hhh 0 "No" 1 "Yes"
label values hhh hhh
renamevarandvaluelabel nla idcode
label var idcode "ID Code"
isid hhid idcode
// Melitta says that the variable expfact is labelled incorrectly - it is not household weight but individual weight
label var expfact "Weight to be used for individual-level dataset"
gen urban = .
replace urban = 1 if b002 == 1
replace urban = 0 if b002 == 2
label var urban "Urban"
label define urban 0 "Rural" 1 "Urban"
label values urban urban

// make a list of the other variables that need to be relabeled. Need to run this only once
if (1) {
tempname fh
file open `fh' using "$WHO_KG_processed/variables_needing_relabeling.txt", w replace all
foreach var of varlist a1a-hsize {
	di `"`var'"'
	file write `fh' `"label var `var' "" "' _n
	file write `fh' `"rename `var '"' _n
}
file close `fh'
}
destring, replace

label var TOTEXP 	"Total OOP health care expenditure"
label var DRUGEXP	"OOP expenditures for drugs"
label var IPEXP 	"Inpatient OOP health care expenditure"
label var OPEXP 	"Outpatient OOP health care expenditure"
gen TOTEXP_overpccd = TOTEXP/pccd*100
label var TOTEXP_overpccd "Total OOP health care expend as a percent of pccd (%)"
gen IPEXP_overpccd = IPEXP/pccd*100
label var IPEXP_overpccd "Inpatient OOP health care expend as a percent of pccd (%)"
gen OPEXP_overpccd = OPEXP/pccd*100
label var OPEXP_overpccd "Outpatient OOP health care expend as a percent of pccd (%)"
gen DRUGEXP_overpccd = DRUGEXP/pccd*100
label var DRUGEXP_overpccd "OOP expenditures for drugs as a percent of pccd (%)"

label var a1a "Lives in the family " 
label var a2 "Gender" 
label var reltohead "Relation to the head of the household" 
label var a4 "Date of birth" 
label var dd "Month" 
label var mm "Day" 
label var yyyy "Year" 
label var age "age" 
label var a5 "What is your marital status?" 
renamevarandvaluelabel a5 marital 
label var a6 "Put the code of the spouse, if he/she lives in the household, if not zero" 
renamevarandvaluelabel a6 spousecode
label var a7 "Nationality" 
renamevarandvaluelabel a7 nationality
label var aa7 "Nationality - other" 
renamevarandvaluelabel aa7 othernationality 
label var a8 "Do [NAME] refer to one of the listed below group?" 
renamevarandvaluelabel a8 memberofgroup
label var a9 "Is [NAME] insured by the Mandatory Health Insurance Fund?" 
renamevarandvaluelabel a9 insuredMHIF
label var b1 "(b1) In the past 30 days has [NAME] applied for medical assistance for any reason?" 
renamevarandvaluelabel b1 appliedmedassist
label var b1a "How many times has [NAME] applied for medical assistance in the last 30 days?" 
renamevarandvaluelabel b1a ntimesappliedmedasst
label var b2 "To whom did  [NAME] apply for care?" 
renamevarandvaluelabel b2 towhomeappliedmedasst
label var ab2 "" 
// renamevarandvaluelabel 
label var b3 "For what condition or reason did [NAME] apply for assistance?" 
renamevarandvaluelabel b3 whyappliedmedasst
label var ab3 "" 
// renamevarandvaluelabel 
label var b3a "Who provided the syringes in order to have [NAME] vaccinated?" 
renamevarandvaluelabel b3a whoprovidedsyringes 
label var b4 "Where did [NAME] receive this assistance?" 
renamevarandvaluelabel b4 whererecmedasst
label var ab4 "" 
// renamevarandvaluelabel 
label var b5 "Did the doctor or nurse measure [NAMEÕs] blood pressure?" 
renamevarandvaluelabel b5 measbloodpres
label var b6 "How far is the health facility [NAME] used from the house?" 
renamevarandvaluelabel b6 howfarfacility
label var b7 "What mode of transport did you use to travel to the health facility?" 
renamevarandvaluelabel b7 modetransportfac
label var ab7 "" 
// renamevarandvaluelabel 
label var b8 "How long did it take to travel to the health facility one way?" 
renamevarandvaluelabel b8 traveltimeoneway
label var b9 "How much did [NAME] spend for the travel to and from the health facility?" 
renamevarandvaluelabel b9 travelcosttwoways
label var b10 "How long did [NAME] have to wait to consult the person at the health facility?" 
renamevarandvaluelabel b10 waittimeconsult
label var b11 "Did [NAME] have to pay the person who they consulted?" 
renamevarandvaluelabel b11 didhavetopayconsult
label var b12 "How much did [NAME] pay this person?" 
renamevarandvaluelabel b12 howmuchpayconsult
label var b13 "Was [NAME] given a receipt for these charges?" 
renamevarandvaluelabel b13 receipt
label var b14 "Did [NAME] make any gifts (money, food, jewellery etc) or provide any services to this person, besides the payment? If yes, what was the value of the gift or services?" 
renamevarandvaluelabel b14 gifts
label var b15 "Was the gift given before, during or after the consultation?" 
renamevarandvaluelabel b15 giftbeforeduringafter
label var b16 "Did [NAME] give it as a gift or was it requested by the person?" 
renamevarandvaluelabel b16 giftorrequest
label var b17 "Did [NAME] have to make any other payments, including payments for laboratory tests, in connection with the consultation? If yes, how much was paid?" 
renamevarandvaluelabel b17 howmuchotherpayments
label var b18 "Did [NAME] make any other gifts (money, food, jewellery etc) or provide any services to other staff at the health facility? If yes, what was the value of the gift or services to these other people?" 
renamevarandvaluelabel b18 howmuchothergifts
label var b19 "Was any medicine prescribed to [NAME] at the health facility? If so, how many items were prescribed? " 
renamevarandvaluelabel b19 howmanymedicinespresc
label var b21 "Where did [NAME] buy this medication?" 
renamevarandvaluelabel b21 wherebuymedication
label var ab21 "" 
// renamevarandvaluelabel 
label var b22 "How much did [NAME] pay for this medication in total?" 
renamevarandvaluelabel b22 totalcostmedication
label var b22a "How many of the prescribed medicine did [NAME] receive at subsidized prices written on a special prescription of the Mandatory Health Insurance Fund? (Under the Additional Drug Benefit)" 
renamevarandvaluelabel b22a specialprescrADB
label var b22b "How much did [NAME] pay for this subsidized medication?" 
renamevarandvaluelabel b22b howmuchpaysubmed
label var b20 "Did [NAME] obtain all the medicine items prescribed?" 
renamevarandvaluelabel b20 didobtallprescmed
label var b23 "If none or not all prescribed items were obtained, why did [NAME] not obtain this medication?" 
renamevarandvaluelabel b23 whynotallprescmed
label var ab23 "" 

// renamevarandvaluelabel 
label var b24 "In the last 30 days has [NAME] bought any medication not prescribed by a doctor?" 
renamevarandvaluelabel b24 nonprescmed 
label var b25 "How much did [NAME] pay for this medication" 
renamevarandvaluelabel b25 howmuchpaynonprescmed
label var b26 "n the last 30 days has it been necessary, for any reason, for [NAME] to apply for medical treatment but they did not?" 
renamevarandvaluelabel b26 didforgomedtreatment
label var b27 "Why did [NAME] not seek treatment?" 
renamevarandvaluelabel b27 whynonseektreat
label var ab27 "" 
// renamevarandvaluelabel 
label var c1 "(c1) Has [NAME] been hospitalised in the last 12 months:" 
renamevarandvaluelabel c1 hospitalized
label var c2 "How many times has [NAME] been hospitalised in the last 12 months" 
renamevarandvaluelabel c2 ntimeshospitalized
label var c3 "What type of hospital was [NAME]  last treated in:" 
renamevarandvaluelabel c3 typehospitaltreated
label var ac3 "" 
// renamevarandvaluelabel 
label var ac5 "" 
// renamevarandvaluelabel 
label var c5 "How was [NAME] referred to the hospital:" 
renamevarandvaluelabel c5 howreferredtohosp
label var c6 "How did [NAME] get to the hospital:" 
renamevarandvaluelabel c6 howgottohosp
label var ac6 "" 
// renamevarandvaluelabel 
label var c7 "How far did [NAME] have to travel to the hospital (km):" 
renamevarandvaluelabel c7 howfartravelhospkm 
label var c8 "How long did it take to travel to the hospital (oneway)?" 
renamevarandvaluelabel c8 traveltimehosponeway
label var c9 "How long did [NAME] stay in the hospital? (days)" 
renamevarandvaluelabel c9 howlongstayinhosp
label var c10 "What type of treatment was provided:[SELECT ALL]" 
renamevarandvaluelabel c10 typeoftreatinhosp
label var ac10 "" 
// renamevarandvaluelabel 
label var c13a "a. Bathing: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13a famserv_bathing 
label var c13b "b. Toileting: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13b famserv_toileting
label var c13c "c. Feeding: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13c famserv_feeding
label var c13d "d. Providing food: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13d famserv_food
label var c13e "e. Providing linen: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13e famserv_linen
label var c13f "f. Providing medical supplies (such as bandages or syringes): During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13f famserv_medsuppl
label var c13g "g. Providing drugs: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13g famserv_drugs
label var c13h "h. Providing other supplies (such as light bulb, soap, or washing powder): During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13h famserv_othersuppl
label var c13i "i. Injecting: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13i famserv_injecting
label var c13j "j. Staying at night near the patient: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13j famserv_staynight
label var c13k "k. Other medical services: During [NAMEÕs] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
renamevarandvaluelabel c13k famserv_othermedserv
label var ac13k "" 
// renamevarandvaluelabel 
label var c13a1 "Expenses during hospital stay: Official co-payment" 
renamevarandvaluelabel c13a1 exphosp_officalcopayment
label var c14 "Expenses during hospital stay: food" 
renamevarandvaluelabel c14 exphosp_food
label var c15 "Expenses during hospital stay: medicine" 
renamevarandvaluelabel c15 exphosp_medicine
label var c16 "Expenses during hospital stay: other supplies" 
renamevarandvaluelabel c16 exphosp_othersuppl
label var c19 "Expenses during hospital stay: Charges made for laboratory tests" 
renamevarandvaluelabel c19 exphosp_labtests
label var c21_1 "Expenses during hospital stay: Payment to physicians (cash)" 
renamevarandvaluelabel c21_1 exphosp_payphyscash
label var c21_2 "Expenses during hospital stay: Payment to physicians (inkind)" 
renamevarandvaluelabel c21_2 exphosp_payphysinkind
label var c22 "Expenses during hospital stay: Did [NAME] give payment to physicial as a gift or was it requested by the physician?" 
renamevarandvaluelabel c22 exphosp_physgiftrequest
label var c23_1 "Expenses during hospital stay: Payment to surgeon (cash)" 
renamevarandvaluelabel c23_1 exphosp_paysurgcash
label var c23_2 "Expenses during hospital stay: Payment to surgeon (inkind)" 
renamevarandvaluelabel c23_2 exphosp_paysurginkind
label var c24 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the surgeon?" 
renamevarandvaluelabel c24 exphosp_surggiftrequest
label var c25_1 "Expenses during hospital stay: Payment to paediatrician (cash)" 
renamevarandvaluelabel c25_1 exphosp_paypedcash
label var c25_2 "Expenses during hospital stay: Payment to paediatrician (inkind)" 
renamevarandvaluelabel c25_2 exphosp_paypedinkind
label var c26 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the paediatrician?" 
renamevarandvaluelabel c26 exphosp_pedgiftrequest
label var c27_1 "Expenses during hospital stay: Payment to obstetrician/ gynaecologist (cash)" 
renamevarandvaluelabel c27_1 exphosp_payobgyncash
label var c27_2 "Expenses during hospital stay: Payment to obstetrician/ gynaecologist (inkind)" 
renamevarandvaluelabel c27_2 exphosp_payobgyninkind
label var c28 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the staff?" 
renamevarandvaluelabel c28 exphosp_obgyngiftrequest
label var c29_1 "Expenses during hospital stay: Payment to anaesthesiologist (cash)" 
renamevarandvaluelabel c29_1 exphosp_payaneascash
label var c29_2 "Expenses during hospital stay: Payment to anaesthesiologist (inkind)" 
renamevarandvaluelabel c29_2 exphosp_payaneasinkind
label var c30 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the anaesthesiologist?" 
renamevarandvaluelabel c30 exphosp_anaesgiftrequest
label var c31_1 "Expenses during hospital stay: Payment to ancillary staff (e.g. nurses, lab technicians) (cash)" 
renamevarandvaluelabel c31_1 exphosp_paystaffcash
label var c31_2 "Expenses during hospital stay: Payment to ancillary staff (e.g. nurses, lab technicians) (inkind)" 
renamevarandvaluelabel c31_2 exphosp_paystaffinkind
label var c32 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the staff?" 
renamevarandvaluelabel c32 exphosp_staffgiftrequest
label var c33_1 "Expenses during hospital stay: What was the value of any other gifts or other payments made by [NAME] with regard to their stay in hospital. (cash)" 
renamevarandvaluelabel c33_1 exphosp_payothercash
label var c33_2 "Expenses during hospital stay: What was the value of any other gifts or other payments made by [NAME] with regard to their stay in hospital. (inkind)" 
renamevarandvaluelabel c33_2 exphosp_payotherinkind
label var c34 "Expenses during hospital stay: Payment for single and comfortable room (ward) in the hospital." 
renamevarandvaluelabel c34 exphosp_singleroom
label var e1 "Does [NAME] suffer from a chronic illness or disability that has lasted more than 3 months (including severe depression)?" 
renamevarandvaluelabel e1 chronicillness
label var e2m "How long has [NAME] had this illness or disability? (months) IF MORE THAN ONE, TALK ABOUT THE MOST SERIOUS ONE" 
renamevarandvaluelabel e2m chronicillness_months
label var e2y "How long has [NAME] had this illness or disability? (years) IF MORE THAN ONE, TALK ABOUT THE MOST SERIOUS ONE" 
renamevarandvaluelabel e2y chronicillness_years
label var e3 "Has this chronic illness or disability been diagnosed by a professional?" 
renamevarandvaluelabel e3 chronicillnessdiagnosed
label var e4 "How many days during the last month has [NAME] been unable to carry out [NAMEÕs] usual activities because of this illness or disability?" 
renamevarandvaluelabel e4 chronicillnessunable
label var e5 "During the last 30 days has [NAME] had any acute (sudden) illness or injury?" 
renamevarandvaluelabel e5 acuteillness
label var e6 "How many days during the last month has [NAME] been unable to carry out [NAMEÕs] usual activities because of this acute (sudden) illness or injury?" 
renamevarandvaluelabel e6 acuteilnnessunable
label var e7 "Does [NAME] have hypertension?" 
renamevarandvaluelabel e7 hypertension
label var e8 "How does [NAME] know that he/she has hypertension? " 
renamevarandvaluelabel e8 hypertensionaware
label var e9 "Did the doctor prescribe medication for [NAMEÕs] high blood pressure?" 
renamevarandvaluelabel e9 hypertensionprescmed
label var e9a "Do you take your blood pressure medicine every day or only when you need it?" 
renamevarandvaluelabel e9a hypertensionmedtake
label var e10 "In the last 24 hours, did [NAME] take this hypertension medication?" 
renamevarandvaluelabel e10 hypertensionmed24hrs
label var e11 "If not, why not? [choose only one answer" 
renamevarandvaluelabel e11 hypertensionmedwhynot
label var e12 "Does [NAME] take any medicine without doctorÕs prescription to low his/her blood pressure?" 
renamevarandvaluelabel e12 hypertensionnonprescmed
label var e13 "Have [NAME] ever smoked?" 
renamevarandvaluelabel e13 smokedever
label var e14 "Does [NAME] currently smoke (i.e. smoke at least one cigarette in the past month)? " 
renamevarandvaluelabel e14 smoker
label var e15 "On average how many cigarettes a week does [NAME] smoke?" 
renamevarandvaluelabel e15 mowmuchsmoke
label var e16 "Does [NAME] agree to measure his/her blood pressure, height, weight? " 
renamevarandvaluelabel e16 agreemeasurebphw
label var e17_1 "Now I would like to measure your blood pressure. Please, give me you left arm. Tonometer first number" 
renamevarandvaluelabel e17_1 bp_tonometer_first
label var e17_2 "Now I would like to measure your blood pressure. Please, give me you left arm. Tonometer second number" 
renamevarandvaluelabel e17_2 bp_tonometer_second
label var e18 "Now, I would like to measure your height (cm)" 
renamevarandvaluelabel e18 measheight
label var e19 "Now I would like to measure your weight (kg)" 
renamevarandvaluelabel e19 measweight

label var d1a "(Awareness) free of charge? : a. Consultation with primary care practitioner" 
renamevarandvaluelabel d1a aw_isfree_primcare
label var d1b "(Awareness) free of charge? : b. Consultation with specialist" 
renamevarandvaluelabel d1b aw_isfree_spec
label var d1c "(Awareness) free of charge? : c. Blood or urine test" 
renamevarandvaluelabel d1c aw_isfree_bloodtest
label var d1d "(Awareness) free of charge? : d. Hormone analysis, kidney test, test for rheumatism" 
renamevarandvaluelabel d1d aw_isfree_kidneytest
label var d1e "(Awareness) free of charge? : e. Blood pressure measurement " 
renamevarandvaluelabel d1e aw_isfree_bpmeas
label var d1f "(Awareness) free of charge? : f. Ambulance services (except private)" 
renamevarandvaluelabel d1f aw_isfree_ambulance
label var d1g "(Awareness) free of charge? : g. Ultrasound for pregnant women" 
renamevarandvaluelabel d1g aw_isfree_ultrasoundpreg
label var d2 "Are you entitled to receive outpatient drugs at subsidized prices?" 
renamevarandvaluelabel d2 aw_subsidized_drugs
label var d3 "Are your children under 16 years of age entitled to receive outpatient drugs at reduced prices? " 
renamevarandvaluelabel d3 aw_yourchdrugsredprices
label var d4 "Imagine that you have been hospitalized.  You have already paid an official co-payment.  Do you have to pay in addition to medical personnel?" 
renamevarandvaluelabel d4 aw_paymentsmedpers
label var d5 "Imagine that you have been hospitalized.  You have already paid an official co-payment.  Do you have to pay in addition for medicines during your hospitalization? " 
renamevarandvaluelabel d5 aw_paymentsmedicines
label var d6 "At present time, what is the co-payment for delivery? (soms) 999= do not know" 
renamevarandvaluelabel d6 aw_copaymentdelivery
label var d7 "At present time, what is the co-payment for hospitalization for children under 5 years old? 999= do not know" 
renamevarandvaluelabel d7 aw_copaymentch5
label var d8 "Imagine that you have paid official co-payment when you were hospitalized.  Who do you consult to verify whether you paid the correct co-payment amount?  [Interviewer: Choose only 1 answer]" 
renamevarandvaluelabel d8 aw_whocopaymentcorrect

label var d9 "Imagine that the co-payment you were charged was higher than what you should have paid.  Where do you submit a complaint?  [Interviewer: Choose only one answer]" 
renamevarandvaluelabel d9 aw_wherecomplain

// Fix the coding
makeonezero d11_* if d10 == 1
label var d10 "Over the last year has finding the money to pay for health care for the members of your family been:" 
renamevarandvaluelabel d10 moneyforhealthcare
label var d11_1 "Borrow money: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_1 payhc_borrow
label var d11_2 "Sell farm animal: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_2 payhc_sellanimal
label var d11_3 "Sell produce: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_3 payhc_sellproduce
label var d11_4 "Sell valuables: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_4 payhc_sellvaluables
label var d11_5 "Use savings: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_5 payhc_savings
label var d11_6 "Decrease current consumption: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_6 payhc_decreasecons
label var d11_7 "Help of relatives: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_7 payhc_helpofrelatives
label var d11_8 "Other (specify): Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
renamevarandvaluelabel d11_8 payhc_other
label var d12 "Has anyone in your household ever been refused health services?" 
renamevarandvaluelabel d12 hhmemberrefusedhealthserv
label var d13 "What was the reason for this (refusing health services)?" 
renamevarandvaluelabel d13 whyrefusedhealthservices

// Fix the coding
makeonezero d15_* if d14 == 1

// This variable should be the same for all hhmembers
label var d14 "Has anyone in your household ever been ill but did not seek care?" 
renamevarandvaluelabel d14 illbutdidnotseek

// For the following, replace missing values with 0 where illbutdidnotseek = yes and the var = .
/*
forv x = 1/9 {
	di "------------------"
	tab d15_`x', mi
	replace d15_`x' = 1 if d15_`x' ~= .
	replace d15_`x' = 0 if d15_`x' == . & illbutdidnotseek == 1
	tab d15_`x', mi
}
*/
label var d15_1 "Thought that they would get better without doing anything : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_1 notseek_betterwithout
/*
replace notseek_betterwithout = 0 if notseek_betterwithout == . & illbutdidnotseek == 1
// These should both be zero
count if illbut == 1 & notseek_b == .
count if illbut ~= 1 & notseek_b ~= .
*/
label var d15_2 "Thought they would get better using traditional herbs : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_2 notseek_traditionalherbs
label var d15_3 "Thought they could get better using pharmaceuticals they already had : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_3 notseek_alreadyhadpharm
label var d15_4 "Put off getting help as could not afford to pay : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_4 notseek_notafford
label var d15_5 "Poor quality services : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_5 notseek_poorquality
label var d15_6 "Distrust to doctors : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_6 notseek_distructdoctors
label var d15_7 "No residency registration : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_7 notseek_residencyreg
label var d15_8 "Other (specify) : What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_8 notseek_other
label var d15_9 "The health facility where necessary services available was far away: What was the reason for this? (ill but did not seek)" 
renamevarandvaluelabel d15_9 notseek_faraway

// Fix the coding
makeonezero d17_* if d16 == 1
label var d16 "Has anyone in your household ever been referred to hospital but not gone?" 
renamevarandvaluelabel d16 referredtohospnotgone
label var d17_1 "Thought that things would get better : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_1 nogohosp_getbetter
label var d17_2 "Unable to afford treatment : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_2 nogohosp_notafford
label var d17_3 "Unable to get to where services were available : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_3 nogohosp_unableservices
label var d17_4 "Referred to another hospital : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_4 nogohosp_refanotherhosp
label var d17_5 "Distrust to the health personnel : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_5 nogohosp_distrusthealthpers
label var d17_6 "Other (specify) : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
renamevarandvaluelabel d17_6 nogohosp_other

// in case we want to analysize a household-level dataset
label var hsize "Household size" 
gen hhw = expfact * hsize
label var hhw "Weight for household-level dataset"

// any contact with health care system?
gen anycontacthealthcare = .
replace anycontacthealthcare = 1 if ( appliedmed == 1 | hospitalized == 1 )
replace anycontacthealthcare = 0 if ( appliedmed == 0 & hospitalized == 0 )
label var anycontacthealthcare "Has the respondend had any contact with the health care system recently  (hospitalized in last 12 months or applied for medical assistance in last 30 days)"
label define anycontacthealthcare 0 "No recent contact with health care system" 1 "Recent contact with health care system"
label values anycontacthealthcare anycontacthealthcare

// Lets get rid of the two households that have more than one hhh (household head)
duplicates drop hhid reltohead if reltohead == 1, force

sort hhid idcode
save "$WHO_KG_processed/health2010_kihs_relabeled.dta", replace

gen poorest20 = .
replace poorest20 = 1 if consq == 1
replace poorest20 = 0 if consq ~= 1 & consq ~= .
label var poorest20 "Person is among the poorest 20% of the population"
label define poorest20 0 "No" 1 "Yes"
label values poorest20 poorest20

// Need data on whether hhmember is currently in school
preserve
use "$KG_PER_dir_kihs_2010_data2/f2_01_eng.dta", clear
duplicates drop
gen studiesnow = .
replace studiesnow = 0 if c3 == 2
replace studiesnow = 1 if c3 == 1
label var studiesnow "Do you study now? (in an educational institution)"
// gen sechighervoc = .
// label var sechighervoc "Studies at secondary, higher"
label define studiesnow 0 "No" 1 "Yes"
label values studiesnow studiesnow
renamevarandvaluelabel c0 idcode
renamevarandvaluelabel hh_code hhid
keep idcode hhid studiesnow
sort hhid idcode
save "$KG_PER_dir_proc/studiesnow.dta", replace
restore

preserve
use "$KG_PER_dir_kihs_2010_data2/f1_nal_eng.dta", clear
renamevarandvaluelabel c9 education
renamevarandvaluelabel c8 maritalstatus
renamevarandvaluelabel hh_code hhid
renamevarandvaluelabel c1 idcode
keep education maritalstatus hhid idcode
sort hhid idcode
save "$KG_PER_dir_proc/education_maritalstatus.dta", replace
restore

// Now merge in data on whether hhmember currently studies
sort hhid idcode
merge 1:1 hhid idcode using "$KG_PER_dir_proc/studiesnow.dta"
tab _m
tab studiesnow, mi
keep if _m ~= 2
tab studiesnow, mi
drop _m

sort hhid idcode
merge 1:1 hhid idcode using "$KG_PER_dir_proc/education_maritalstatus.dta"
keep if _m ~= 2
drop _m

// Now merge in data on which households receive MBPF.
merge n:1 hhid using "$KG_PER_dir_proc/KIHS_2010_hhid_MBPF"
keep if _m ~= 2
drop _m
replace MBPF = 0 if MBPF == .
replace MBPF_annual = 0 if MBPF_annual == .
gen receives_MBPF = .
replace receives_MBPF = 1 if MBPF_annual ~= .
replace receives_MBPF = 0 if MBPF_annual == 0
label var receives_MBPF "Member of a household that receives MBPF"
label define receives_MBPF 0 "non-recipient of MBPF" 1 "recipient of MBPF"
label define receives_MBPF_n 0 "0: non-recipient of MBPF" 1 "1: recipient of MBPF"
label values receives_MBPF receives_MBPF
gen lvreceives_MBPF = receives_MBPF
label values lvreceives_MBPF receives_MBPF_n

// Now make a variable which is our best guess at who technically qualifies for copayment exemption
gen exemptfromcopayment = .
label var exemptfromcopayment "Exempt from copayment under current policy"
// first use response to question a8
replace exemptfromcopayment = 0 if memberofgroup == . | memberofgroup == 0
replace exemptfromcopayment = 1 if memberofgroup ~= . & memberofgroup ~= 0
label define exemptfromcopayment 0 "Not exempt under current policy" 1 "Exempt under current policy"
label define exemptfromcopayment_n 0 "0: Not exempt under current policy" 1 "1: Exempt under current policy"
label values exemptfromcopayment exemptfromcopayment
gen lvexemptfromcopayment_n = exemptfromcopayment
label values lvexemptfromcopayment_n exemptfromcopayment_n
// question c10: now include anyone who went to the hospital due to pregnancy.
// Note, there is a problem with c10: It seems that there is only one response for each recipient, even though the survey says that the responded can select multiple responses.
replace exemptfromcopayment = 1 if typeoftreatinhosp == 4
// seems like anyone over 70 also qualifies
replace exemptfromcopayment = 1 if age >= 70
replace exemptfromcopayment = 1 if age <  5
// Children under the age of 16 years from large families with 4 or more children (students of educational institutions - to the end of their studies, but no more than up to the age of 18 years) with a production of a certificate of social security or social worker ail okmotus;
gen child = .
replace child = 1 if age <  18
replace child = 0 if age >= 18
bys hhid: egen numchildren = sum(child)
replace exemptfromcopayment = 1 if numchildren >= 4 & age < 16
replace exemptfromcopayment = 1 if numchildren >= 4 & age < 18 & studiesnow == 1 // in school
// Partial: Children from 5 years and up to the age of 16 years (students of educational institutions - until the end of their studies, but no longer than until the age of 18);
replace exemptfromcopayment = 1 if age < 16 
replace exemptfromcopayment = 1 if age < 18 & studiesnow == 1
// Partial: Students at basic vocational schools, students of secondary and higher vocational schools full-time education until the age of 21.
replace exemptfromcopayment = 1 if age < 21 & studiesnow == 1 

// The PMT approach can go here
// ----------------------------
// Will use Franziska Gassman's PMT formula
sort hhid idcode
save "$WHO_KG_processed/health2010_kihs_relabeled_merged_02-07-2012.dta", replace

// farm animals (e.g. cows) - lots of missing values. This is questionable. Check with Melitta
preserve
use "$KG_PER_dir_kihs_2010_data2/f6_7131_eng.dta", clear
duplicates drop hh_code kvartal c1, force
isid hh_code kvartal c1
keep if c1==1
isid hh_code kvartal
drop c1
renamevarandvaluelabel hh_code hhid
collapse (mean) c2 c3 c5 c8, by(hhid)
// Check with Melitta about this: can we treat missing values as zero?
replace c2=0 if c2==.
replace c3=0 if c3==.
replace c5=0 if c5==.
replace c8=0 if c8==.
isid hhid
renamevarandvaluelabel c2 cows
label var cows "Average number of cows throughout the year (over multiple quarters)"
renamevarandvaluelabel c3 sheepgoats
label var sheepgoats "Average number of sheeps and goats throughout the year (over multiple quarters)"
renamevarandvaluelabel c5 horses
label var horses "Average number of horses throughout the year (over multiple quarters)"
renamevarandvaluelabel c8 poultry
label var poultry "Average number of poultry throughout the year (over multiple quarters)"
foreach var of varlist cows sheepgoats horses poultry {
	replace `var' = 0 if `var' == .
}
sort hhid
save "$WHO_KG_processed/farm_animals.dta", replace
restore


// Create a categorical variable for children. What is the age limit of children? Lets say 18
/*
local childagelimit = 18
gen ischild = .
replace ischild = 1 if age <  `childagelimit'
replace ischild = 0 if age >= `childagelimit'
egen numchildren = count(ischild)
*/
gen numchildrengr = .
replace numchildrengr = 0 if numchildren == 0
replace numchildrengr = 1 if numchildren == 1
replace numchildrengr = 2 if numchildren == 2
replace numchildrengr = 3 if numchildren == 3
replace numchildrengr = 4 if numchildren == 4
replace numchildrengr = 5 if numchildren >= 5
label define numchildrengr 0 "No children" 1 "1 child" 2 "2 children" 3 "3 children" 4 "4 children" 5 "5 or more children" 
label values numchildrengr numchildrengr

// Assets
preserve
use "$KG_PER_dir_kihs_2010_data2/f7_02_eng.dta", clear
duplicates drop hh_code c1, force
megaif 15 18 19 57 60 , c(keep) v(c1)
label list c1
// missing oven, garage, car
renamevarandvaluelabel hh_code hhid
keep hhid c1 c2
renamevarandvaluelabel c2 asset
reshape wide asset, i(hhid) j(c1)
label var asset15 "Personal Computer (binary indicator)"
renamevarandvaluelabel asset15 computer
label var asset18 "Regular washing machine" 
label var asset19 "Automatic washing machine"
gen washingmachine = 0
replace washingmachine = 1 if (asset18 > 0 & asset 18 ~= .) | (asset18 > 0 & asset 18 ~= .)
label var washingmachine "Washing maching, regular or automatic (binary indicator)"
label var asset57 "Mobile Phone (binary indicator)"
renamevarandvaluelabel asset57 mobilephone
label var asset60 "Satellite antenna (binary indicator)"
renamevarandvaluelabel asset60 satelliteantenna
foreach var of varlist computer mobilephone satelliteantenna {
	tab `var', mi
	replace `var' = 1 if `var' >0 & `var' ~= .
	replace `var' = 0 if `var' ==.
	tab `var', mi	
}
drop asset18 asset19
isid hhid
sort hhid
save "$WHO_KG_processed/assets.dta",replace
restore

// Oven, garage, livingrooms
preserve
use "$KG_PER_dir_kihs_2010_data2/f7_01_eng_updated", clear
tab q36_a6, mi
renamevarandvaluelabel hh_code hhid
gen ovenfireplace = . 
replace ovenfireplace = 0 if q36_a6 == .
replace ovenfireplace = 1 if q36_a6 > 0 & q36_a6 ~= .
tab ovenfireplace, mi

tab q44
gen garage = .
replace garage = 0 if q44 == 2 | q44 == .
replace garage = 1 if q44 == 1
tab garage

renamevarandvaluelabel q7 numberoflivingrooms

tab q14, mi
gen wallsnotbrickconcretewood = .
megaif 1 2 4, c(replace wallsnotbrickconcretewood = 0) v(q14)
megaif 1 2 4, c(replace wallsnotbrickconcretewood = 1) v(q14) e("~=") s("&")
tab wallsnotbrickconcretewood

tab q32, mi
gen bathroomoutsidehouse = .
replace bathroomoutsidehouse = 1 if q32 >  1
replace bathroomoutsidehouse = 0 if q32 == 1
tab bathroomoutsidehouse

tab q40
gen additionalhouse = .
replace additionalhouse = 1 if q40 == 1
replace additionalhouse = 0 if q40 == 2
tab additionalhouse

tab q16r3c2
gen watersupply = .
replace watersupply = 0 if q16r3c2 == 2
replace watersupply = 1 if q16r3c2 == 1
tab watersupply

tab q28_a1, mi
gen centralheating = .
replace centralheating = 1 if q28_a1 == 1
replace centralheating = 0 if q28_a1 == .
tab centralheating

keep hhid ovenfireplace garage numberoflivingrooms wallsnotbrick bathroomoutside additionalhouse watersupply centralheating
isid hhid
sort hhid
save "$WHO_KG_processed/aboutthehouse.dta",replace
restore

preserve 
use "$KG_PER_dir_kihs_2010_data2/f4_eng.dta", clear
rename hh_code hhid
tostring resp, gen(resp2)
gen idcode = ""
replace idcode = regexs(1) if regexm(resp2,"([0-9][0-9])$")  
destring idcode, replace
// rename resp idcode
rename kwartal kvartal
sort hhid idcode kvartal
collapseandpreserve (last) soc_st, by(hhid idcode) o
keep hhid idcode soc_st
isid hhid idcode
sort hhid idcode
save "$WHO_KG_processed/employment.dta",replace
restore

// Merge in farm animals
sort hhid
merge m:1 hhid using "$WHO_KG_processed/farm_animals.dta"
keep if _m ~= 2
drop _m

// Merge in assets
merge m:1 hhid using "$WHO_KG_processed/assets.dta"
tab _m
keep if _m ~= 2
drop _m

// Merge in housing characteristics
sort hhid
merge m:1 hhid using "$WHO_KG_processed/aboutthehouse.dta"
tab _m
keep if _m ~= 2
drop _m

// Merge in employment status
sort hhid idcode
merge 1:1 hhid idcode using "$WHO_KG_processed/employment.dta"
tab _m
keep if _m ~= 2
drop _m

gen livingroomsperperson = numberoflivingrooms/hsize
label var livingroomsperperson "Livingrooms per person"

// Generate householdhead characteristics
gen female = .
replace female = 1 if male == 0
replace female = 0 if male == 1
label define female 0 "Male" 1 "Female"
label values female female 
tab male, mi 
tab female, mi
genhhhcharacteristics female, 	b(hhid) gen(hhh_female) 	h(relto) id(1)
genhhhcharacteristics marital, 	b(hhid) gen(hhh_marital) 	h(relto) id(1)
genhhhcharacteristics education,b(hhid) gen(hhh_education) 	h(relto) id(1)
genhhhcharacteristics soc_st, 	b(hhid) gen(hhh_soc_st) 	h(relto) id(1)

// Get total income
merge m:1 hhid using "$KG_PER_dir_proc/KG_PER_KIHS_2010_forADePT_saveold_09Nov2012.dta", keepusing(toty)
drop _m
gen ln_toty = ln(toty)
label var ln_toty "ln of total income"

exit
// Check to compare consumption aggregate from POVERTY.dta file
renamevarandvaluelabel pccd pccd_POVERTY
merge m:1 hhid using "$KG_PER_dir_proc/KG_PER_KIHS_2010_forADePT_saveold_09Nov2012.dta", keepusing(pccd)
tab _m

// Information on copayment exemptions (complete? reduced?)
// Source: #6_Presentation_Trends in informal payment.pdf, slide 35
// Medical and social status:
//  ?
// Other categories: 
//	pregnancies and deliveries
// 	children < 5
//  pensioners > 75

// Source: #5_Informal payments 2001-06.pdf
//  box 1 on page 20:
//  page 19 "The definition of priority beneficiary groups has changed over the examined time period several times with the largest expansion of the SGBP in 2006"

// Source: #1_e95045.pdf "Health Systems in Transition"
//  page 47 "Exemption categories were drawn up on the basis of social considerations and disease types, with the aim of protecting vulnerable groups of the population and those with the highest expected use of health services."
//	page 48 "In the process of implementing the SGBP, there has been a considerable increase in the population categories entitled to various forms of exemption, from 29 categories in 2001 to 72 in 2009. This increase in the number of exempt categories was accompanied by an increase in the number of patients entitled to exemptions...
//		In order to ensure that increased state commitments correspond to available financing, an inventory of legislative documents regulating exemptions was envisaged...
//		Patients who fall below the poverty line but are not entitled to exemptions can receive basic health services paid for by the reserve fund of health organizations. These are mostly men and women, except pregnant women, who are of working age. However, at present the mechanisms for this exemption are not well defined. "
//  page 80 "The levels of co-payments, as well as the patient categories exempted from co-payments or entitled to reduced rates, are defined in the SGBP"
//  page 126 "Increased levels of funding allowed certain groups to be exempted from co-payments, including children under 5 years of age, pensioners older than 70 years, and women for prenatal care and deliveries"
//  		...so is it 70 or 75 years of age? Do they have to be a "pensioner"?

// Source: #2_Coverage Good Practices.pdf
//  page 281 "Exemption categories were designed based on categorical targeting and disease types to protect populations with high expected health care use."
//  page 281-282 "Targeting based on social categories. Assistance was intended to reach economi- cally vulnerable groups, but they were defined largely in terms of social and demographic characteristics, whereas, for example, war veterans, people over 5 years of age, and the disabled regardless of their income were fully exempt from any fees."
//				"Targeting based on medical condition/disease type. Interventions to prevent and cure diseases with important public health consequences and externalities were also exempt from charges (TB, AIDS, syphilis, polio, diphtheria)."
//  
