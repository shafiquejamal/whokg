clear
set more off
do setpaths.do

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
rename a3 reltohead
label var reltohead "Relationship to HH head"
// CHECK THIS WITH MELITTA
rename nla idcode
label var idcode "ID Code"
isid hhid idcode
// Melitta says that the variable expfact is labelled incorrectly - it is not household weight but individual weight
label var expfact "Weight to be used for individual-level dataset"

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

label var a1a "Lives in the family " 
label var a2 "Gender" 
label var reltohead "Relation to the head of the household" 
label var a4 "Date of birth" 
label var dd "Month" 
label var mm "Day" 
label var yyyy "Year" 
label var age "age" 
label var a5 "What is your marital status?" 
rename a5 marital 
label var a6 "Put the code of the spouse, if he/she lives in the household, if not zero" 
rename a6 spousecode
label var a7 "Nationality" 
rename a7 nationality
label var aa7 "Nationality - other" 
rename aa7 othernationality 
label var a8 "Do [NAME] refer to one of the listed below group?" 
rename a8 memberofgroup
label var a9 "Is [NAME] insured by the Mandatory Health Insurance Fund?" 
rename a9 insuredMHIF
label var b1 "In the past 30 days has [NAME] applied for medical assistance for any reason?" 
rename b1 appliedmedassist
label var b1a "How many times has [NAME] applied for medical assistance in the last 30 days?" 
rename b1a ntimesappliedmedasst
label var b2 "To whom did  [NAME] apply for care?" 
rename b2 towhomeappliedmedasst
label var ab2 "" 
// rename 
label var b3 "For what condition or reason did [NAME] apply for assistance?" 
rename b3 whyappliedmedasst
label var ab3 "" 
// rename 
label var b3a "Who provided the syringes in order to have [NAME] vaccinated?" 
rename b3a whoprovidedsyringes 
label var b4 "Where did [NAME] receive this assistance?" 
rename b4 whererecmedasst
label var ab4 "" 
// rename 
label var b5 "Did the doctor or nurse measure [NAME’s] blood pressure?" 
rename b5 measbloodpres
label var b6 "How far is the health facility [NAME] used from the house?" 
rename b6 howfarfacility
label var b7 "What mode of transport did you use to travel to the health facility?" 
rename b7 modetransportfac
label var ab7 "" 
// rename 
label var b8 "How long did it take to travel to the health facility one way?" 
rename b8 traveltimeoneway
label var b9 "How much did [NAME] spend for the travel to and from the health facility?" 
rename b9 travelcosttwoways
label var b10 "How long did [NAME] have to wait to consult the person at the health facility?" 
rename b10 waittimeconsult
label var b11 "Did [NAME] have to pay the person who they consulted?" 
rename b11 didhavetopayconsult
label var b12 "How much did [NAME] pay this person?" 
rename b12 howmuchpayconsult
label var b13 "Was [NAME] given a receipt for these charges?" 
rename b13 receipt
label var b14 "Did [NAME] make any gifts (money, food, jewellery etc) or provide any services to this person, besides the payment? If yes, what was the value of the gift or services?" 
rename b14 gifts
label var b15 "Was the gift given before, during or after the consultation?" 
rename b15 giftbeforeduringafter
label var b16 "Did [NAME] give it as a gift or was it requested by the person?" 
rename b16 giftorrequest
label var b17 "Did [NAME] have to make any other payments, including payments for laboratory tests, in connection with the consultation? If yes, how much was paid?" 
rename b17 howmuchotherpayments
label var b18 "Did [NAME] make any other gifts (money, food, jewellery etc) or provide any services to other staff at the health facility? If yes, what was the value of the gift or services to these other people?" 
rename b18 howmuchothergifts
label var b19 "Was any medicine prescribed to [NAME] at the health facility? If so, how many items were prescribed? " 
rename b19 howmanymedicinespresc
label var b21 "Where did [NAME] buy this medication?" 
rename b21 wherebuymedication
label var ab21 "" 
// rename 
label var b22 "How much did [NAME] pay for this medication in total?" 
rename b22 totalcostmedication
label var b22a "How many of the prescribed medicine did [NAME] receive at subsidized prices written on a special prescription of the Mandatory Health Insurance Fund? (Under the Additional Drug Benefit)" 
rename b22a specialprescrADB
label var b22b "How much did [NAME] pay for this subsidized medication?" 
rename b22b howmuchpaysubmed
label var b20 "Did [NAME] obtain all the medicine items prescribed?" 
rename b20 didobtallprescmed
label var b23 "If none or not all prescribed items were obtained, why did [NAME] not obtain this medication?" 
rename b23 whynotallprescmed
label var ab23 "" 
// rename 
label var b24 "In the last 30 days has [NAME] bought any medication not prescribed by a doctor?" 
rename b24 nonprescmed 
label var b25 "How much did [NAME] pay for this medication" 
rename b25 howmuchpaynonprescmed
label var b26 "n the last 30 days has it been necessary, for any reason, for [NAME] to apply for medical treatment but they did not?" 
rename b26 didforgomedtreatment
label var b27 "Why did [NAME] not seek treatment?" 
rename b27 whynonseektreat
label var ab27 "" 
// rename 
label var c1 "Has [NAME] been hospitalised in the last 12 months:" 
rename c1 hospitalized
label var c2 "How many times has [NAME] been hospitalised in the last 12 months" 
rename c2 ntimeshospitalized
label var c3 "What type of hospital was [NAME]  last treated in:" 
rename c3 typehospitaltreated
label var ac3 "" 
// rename 
label var ac5 "" 
// rename 
label var c5 "How was [NAME] referred to the hospital:" 
rename c5 howreferredtohosp
label var c6 "How did [NAME] get to the hospital:" 
rename c6 howgottohosp
label var ac6 "" 
// rename 
label var c7 "How far did [NAME] have to travel to the hospital (km):" 
rename c7 howfartravelhospkm 
label var c8 "How long did it take to travel to the hospital (oneway)?" 
rename c8 traveltimehosponeway
label var c9 "How long did [NAME] stay in the hospital? (days)" 
rename c9 howlongstayinhosp
label var c10 "What type of treatment was provided:[SELECT ALL]" 
rename c10 typeoftreatinhosp
label var ac10 "" 
// rename 
label var c13a "a. Bathing: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13a famserv_bathing 
label var c13b "b. Toileting: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13b famserv_toileting
label var c13c "c. Feeding: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13c famserv_feeding
label var c13d "d. Providing food: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13d famserv_food
label var c13e "e. Providing linen: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13e famserv_linen
label var c13f "f. Providing medical supplies (such as bandages or syringes): During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13f famserv_medsuppl
label var c13g "g. Providing drugs: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13g famserv_drugs
label var c13h "h. Providing other supplies (such as light bulb, soap, or washing powder): During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13h famserv_othersuppl
label var c13i "i. Injecting: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13i famserv_injecting
label var c13j "j. Staying at night near the patient: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13j famserv_staynight
label var c13k "k. Other medical services: During [NAME’s] stay(s) in hospital in the last 12 months, were any of the following services provided by family members?" 
rename c13k famserv_othermedserv
label var ac13k "" 
// rename 
label var c13a1 "Expenses during hospital stay: Official co-payment" 
rename c13a1 exphosp_officalcopayment
label var c14 "Expenses during hospital stay: food" 
rename c14 exphosp_food
label var c15 "Expenses during hospital stay: medicine" 
rename c15 exphosp_medicine
label var c16 "Expenses during hospital stay: other supplies" 
rename c16 exphosp_othersuppl
label var c19 "Expenses during hospital stay: Charges made for laboratory tests" 
rename c19 exphosp_labtests
label var c21_1 "Expenses during hospital stay: Payment to physicians (cash)" 
rename c21_1 exphosp_payphyscash
label var c21_2 "Expenses during hospital stay: Payment to physicians (inkind)" 
rename c21_2 exphosp_payphysinkind
label var c22 "Expenses during hospital stay: Did [NAME] give payment to physicial as a gift or was it requested by the physician?" 
rename c22 exphosp_physgiftrequest
label var c23_1 "Expenses during hospital stay: Payment to surgeon (cash)" 
rename c23_1 exphosp_paysurgcash
label var c23_2 "Expenses during hospital stay: Payment to surgeon (inkind)" 
rename c23_2 exphosp_paysurginkind
label var c24 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the surgeon?" 
rename c24 exphosp_surggiftrequest
label var c25_1 "Expenses during hospital stay: Payment to paediatrician (cash)" 
rename c25_1 exphosp_paypedcash
label var c25_2 "Expenses during hospital stay: Payment to paediatrician (inkind)" 
rename c25_2 exphosp_paypedinkind
label var c26 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the paediatrician?" 
rename c26 exphosp_pedgiftrequest
label var c27_1 "Expenses during hospital stay: Payment to obstetrician/ gynaecologist (cash)" 
rename c27_1 exphosp_payobgyncash
label var c27_2 "Expenses during hospital stay: Payment to obstetrician/ gynaecologist (inkind)" 
rename c27_2 exphosp_payobgyninkind
label var c28 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the staff?" 
rename c28 exphosp_obgyngiftrequest
label var c29_1 "Expenses during hospital stay: Payment to anaesthesiologist (cash)" 
rename c29_1 exphosp_payaneascash
label var c29_2 "Expenses during hospital stay: Payment to anaesthesiologist (inkind)" 
rename c29_2 exphosp_payaneasinkind
label var c30 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the anaesthesiologist?" 
rename c30 exphosp_anaesgiftrequest
label var c31_1 "Expenses during hospital stay: Payment to ancillary staff (e.g. nurses, lab technicians) (cash)" 
rename c31_1 exphosp_paystaffcash
label var c31_2 "Expenses during hospital stay: Payment to ancillary staff (e.g. nurses, lab technicians) (inkind)" 
rename c31_2 exphosp_paystaffinkind
label var c32 "Expenses during hospital stay: Did [NAME] give it as a gift or was it requested by the staff?" 
rename c32 exphosp_staffgiftrequest
label var c33_1 "Expenses during hospital stay: What was the value of any other gifts or other payments made by [NAME] with regard to their stay in hospital. (cash)" 
rename c33_1 exphosp_payothercash
label var c33_2 "Expenses during hospital stay: What was the value of any other gifts or other payments made by [NAME] with regard to their stay in hospital. (inkind)" 
rename c33_2 exphosp_payotherinkind
label var c34 "Expenses during hospital stay: Payment for single and comfortable room (ward) in the hospital." 
rename c34 exphosp_singleroom
label var e1 "Does [NAME] suffer from a chronic illness or disability that has lasted more than 3 months (including severe depression)?" 
rename e1 chronicillness
label var e2m "How long has [NAME] had this illness or disability? (months) IF MORE THAN ONE, TALK ABOUT THE MOST SERIOUS ONE" 
rename e2m chronicillness_months
label var e2y "How long has [NAME] had this illness or disability? (years) IF MORE THAN ONE, TALK ABOUT THE MOST SERIOUS ONE" 
rename e2y chronicillness_years
label var e3 "Has this chronic illness or disability been diagnosed by a professional?" 
rename e3 chronicillnessdiagnosed
label var e4 "How many days during the last month has [NAME] been unable to carry out [NAME’s] usual activities because of this illness or disability?" 
rename e4 chronicillnessunable
label var e5 "During the last 30 days has [NAME] had any acute (sudden) illness or injury?" 
rename e5 acuteillness
label var e6 "How many days during the last month has [NAME] been unable to carry out [NAME’s] usual activities because of this acute (sudden) illness or injury?" 
rename e6 acuteilnnessunable
label var e7 "Does [NAME] have hypertension?" 
rename e7 hypertension
label var e8 "How does [NAME] know that he/she has hypertension? " 
rename e8 hypertensionaware
label var e9 "Did the doctor prescribe medication for [NAME’s] high blood pressure?" 
rename e9 hypertensionprescmed
label var e9a "Do you take your blood pressure medicine every day or only when you need it?" 
rename e9a hypertensionmedtake
label var e10 "In the last 24 hours, did [NAME] take this hypertension medication?" 
rename e10 hypertensionmed24hrs
label var e11 "If not, why not? [choose only one answer" 
rename e11 hypertensionmedwhynot
label var e12 "Does [NAME] take any medicine without doctor’s prescription to low his/her blood pressure?" 
rename e12 hypertensionnonprescmed
label var e13 "Have [NAME] ever smoked?" 
rename e13 smokedever
label var e14 "Does [NAME] currently smoke (i.e. smoke at least one cigarette in the past month)? " 
rename e14 smoker
label var e15 "On average how many cigarettes a week does [NAME] smoke?" 
rename e15 mowmuchsmoke
label var e16 "Does [NAME] agree to measure his/her blood pressure, height, weight? " 
rename e16 agreemeasurebphw
label var e17_1 "Now I would like to measure your blood pressure. Please, give me you left arm. Tonometer first number" 
rename e17_1 bp_tonometer_first
label var e17_2 "Now I would like to measure your blood pressure. Please, give me you left arm. Tonometer second number" 
rename e17_2 bp_tonometer_second
label var e18 "Now, I would like to measure your height (cm)" 
rename e18 measheight
label var e19 "Now I would like to measure your weight (kg)" 
rename e19 measweight

label var d1a "(Awareness) free of charge? : a. Consultation with primary care practitioner" 
rename d1a aw_isfree_primcare
label var d1b "(Awareness) free of charge? : b. Consultation with specialist" 
rename d1b aw_isfree_spec
label var d1c "(Awareness) free of charge? : c. Blood or urine test" 
rename d1c aw_isfree_bloodtest
label var d1d "(Awareness) free of charge? : d. Hormone analysis, kidney test, test for rheumatism" 
rename d1d aw_isfree_kidneytest
label var d1e "(Awareness) free of charge? : e. Blood pressure measurement " 
rename d1e aw_isfree_bpmeas
label var d1f "(Awareness) free of charge? : f. Ambulance services (except private)" 
rename d1f aw_isfree_ambulance
label var d1g "(Awareness) free of charge? : g. Ultrasound for pregnant women" 
rename d1g aw_isfree_ultrasoundpreg
label var d2 "Are you entitled to receive outpatient drugs at subsidized prices?" 
rename d2 aw_subsidized_drugs
label var d3 "Are your children under 16 years of age entitled to receive outpatient drugs at reduced prices? " 
rename d3 aw_yourchdrugsredprices
label var d4 "Imagine that you have been hospitalized.  You have already paid an official co-payment.  Do you have to pay in addition to medical personnel?" 
rename d4 aw_paymentsmedpers
label var d5 "Imagine that you have been hospitalized.  You have already paid an official co-payment.  Do you have to pay in addition for medicines during your hospitalization? " 
rename d5 aw_paymentsmedicines
label var d6 "At present time, what is the co-payment for delivery? (soms) 999= do not know" 
rename d6 aw_copaymentdelivery
label var d7 "At present time, what is the co-payment for hospitalization for children under 5 years old? 999= do not know" 
rename d7 aw_copaymentch5
label var d8 "Imagine that you have paid official co-payment when you were hospitalized.  Who do you consult to verify whether you paid the correct co-payment amount?  [Interviewer: Choose only 1 answer]" 
rename d8 aw_whocopaymentcorrect

label var d9 "Imagine that the co-payment you were charged was higher than what you should have paid.  Where do you submit a complaint?  [Interviewer: Choose only one answer]" 
rename d9 aw_wherecomplain
label var d10 "Over the last year has finding the money to pay for health care for the members of your family been:" 
rename d10 moneyforhealthcare
label var d11_1 "Borrow money: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_1 payhc_borrow
label var d11_2 "Sell farm animal: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_2 payhc_sellanimal
label var d11_3 "Sell produce: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_3 payhc_sellproduce
label var d11_4 "Sell valuables: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_4 payhc_sellvaluables
label var d11_5 "Use savings: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_5 payhc_savings
label var d11_6 "Decrease current consumption: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_6 payhc_decreasecons
label var d11_7 "Help of relatives: Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_7 payhc_helpofrelatives
label var d11_8 "Other (specify): Over the last year has it been necessary to do any of the following in order to raise money to pay for health care for members of your family?" 
rename d11_8 payhc_other
label var d12 "Has anyone in your household ever been refused health services?" 
rename d12 hhmemberrefusedhealthserv
label var d13 "What was the reason for this (refusing health services)?" 
rename d13 whyrefusedhealthservices

destring, replace
// local varlist_d15 d15_1 d15_2 d15_3 d15_4 d15_5 d15_6 d15_7 d15_8 d15_9
foreach var of local varlist_d15 {
	destring `var', replace
}
exit

// This variable should be the same for all hhmembers
label var d14 "Has anyone in your household ever been ill but did not seek care?" 
rename d14 illbutdidnotseek

// For the following, replace missing values with 0 where illbutdidnotseek = yes and the var = .
forv x = 1/9 {
	di "------------------"
	tab d15_`x', mi
	replace d15_`x' = 1 if d15_`x' ~= .
	replace d15_`x' = 0 if d15_`x' == . & illbutdidnotseek == 1
	tab d15_`x', mi
}

label var d15_1 "Thought that they would get better without doing anything : What was the reason for this? (ill but did not seek)" 
rename d15_1 notseek_betterwithout
/*
replace notseek_betterwithout = 0 if notseek_betterwithout == . & illbutdidnotseek == 1
// These should both be zero
count if illbut == 1 & notseek_b == .
count if illbut ~= 1 & notseek_b ~= .
*/
label var d15_2 "Thought they would get better using traditional herbs : What was the reason for this? (ill but did not seek)" 
rename d15_2 notseek_traditionalherbs
label var d15_3 "Thought they could get better using pharmaceuticals they already had : What was the reason for this? (ill but did not seek)" 
rename d15_3 notseek_alreadyhadpharm
label var d15_4 "Put off getting help as could not afford to pay : What was the reason for this? (ill but did not seek)" 
rename d15_4 notseek_notafford
label var d15_5 "Poor quality services : What was the reason for this? (ill but did not seek)" 
rename d15_5 notseek_poorquality
label var d15_6 "Distrust to doctors : What was the reason for this? (ill but did not seek)" 
rename d15_6 notseek_distructdoctors
label var d15_7 "No residency registration : What was the reason for this? (ill but did not seek)" 
rename d15_7 notseek_residencyreg
label var d15_8 "Other (specify) : What was the reason for this? (ill but did not seek)" 
rename d15_8 notseek_other
label var d15_9 "The health facility where necessary services available was far away: What was the reason for this? (ill but did not seek)" 
rename d15_9 notseek_faraway

label var d16 "Has anyone in your household ever been referred to hospital but not gone?" 
rename d16 referredtohospnotgone
label var d17_1 "Thought that things would get better : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_1 nogohosp_getbetter
label var d17_2 "Unable to afford treatment : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_2 nogohosp_notafford
label var d17_3 "Unable to get to where services were available : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_3 nogohosp_unableservices
label var d17_4 "Referred to another hospital : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_4 nogohosp_refanotherhosp
label var d17_5 "Distrust to the health personnel : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_5 nogohosp_distrusthealthpers
label var d17_6 "Other (specify) : What was the reason for this? (Has anyone in your household ever been referred to hospital but not gone)" 
rename d17_6 nogohosp_other

label var hsize "Household size" 

sort hhid idcode
save "$WHO_KG_processed/health2010_kihs_relabeled.dta", replace

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
