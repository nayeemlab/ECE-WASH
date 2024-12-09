* directory
cd "H:\Research\Project WASH BDHS\Code\Data"
use "BDBR81FL.DTA", clear


* exclude missing/not liste
drop if b16==0 | b16 == .

rename b16  hvidx
rename v001 hv001
rename v002 hv002
sort hv001 hv002 hvidx
save tempBR, replace

* master file
use "BDPR81FL.DTA", clear
* keep de facto members
keep if hv103 == 1 
sort hv001 hv002 hvidx
merge 1:1 hv001 hv002 hvidx using tempBR
drop if _merge==2

* final meged data
save BR_PR_mrg, replace

* Load prepared dataset
use BR_PR_mrg, clear


*weight
cap gen wt = hv005/1000000
svyset hv002 [pw = wt], strata(hv022)

** Age at beginning of school 
global school_start_yr = 2022
global school_start_mo = 1
gen cmcSch = ($school_start_yr - 1900)*12 + $school_start_mo
gen school_age = int((cmcSch - b3) / 12) if b3 != .
replace school_age = hv105 if b3 == .
tab school_age
keep if (school_age == 5)
tab school_age
tab school_age [iw = wt]


** Attend/Not Attend pre-primary
gen ece = 0
replace ece = 1 if (hv121 == 2 & hv122 == 0)
label define ecelab 1 "Yes" 0 "No"
label values ece ecelab
tab ece
tab ece [iw = wt]



** WASH 

* hand washing/Hygiene
*basic: both water and soap/detergent available
*limited: one/neither is available
gen hwashing=.
replace hwashing = 1 if (hv230b==1 & hv232==1)
replace hwashing = 2 if (hv230b==0 | hv232==0)
replace hwashing=. if hv102!=1 
label define hwashinglab 1 "Basic" 2 "Limited"
label values hwashing hwashinglab
tab hwashing
svy: tab hwashing ece, row

*** Place for handwashing ***
tab hv230a
gen hwashplace = .
replace hwashplace = 1 if (hv230a == 1)
replace hwashplace = 2 if (hv230a == 2)
label define hwashplace 1 "Fixed" 2 "Mobile"
label values hwashplace hwashplace
tab hwashplace
svy: tab hwashplace ece, row

* Type of Toilet/Sanitation
tab hv205
gen toilet=.
replace toilet = 1 if inlist(hv205, 11, 12, 13, 15, 21, 22, 41)
replace toilet = 2 if inlist(hv205, 14, 23, 31, 42, 43, 96)
label define toiletlab 1 "Improved" 2 "Unimproved/No facility" 
label values toilet toiletlab
tab toilet
svy: tab toilet ece , row

*** Toilet Sharing ***
tab hv225, nolabel
gen toiletshare = hv225
label define toilets 0 "No" 1 "Yes"
label values toiletshare toilets
tab toiletshare
svy: tab toiletshare ece, row

*Source fo water
gen water=.
replace water = 1 if inlist(hv201, 11, 12, 13, 14, 21, 31, 41, 51, 61, 62, 71) 
replace water = 2 if inlist(hv201, 32, 42, 43, 96) 
label define waterlab 1 "Improved" 2 "Unimproved" 
label values water waterlab
label variable water "Sources of Water"
tab water
svy:tab water ece, row 

*** Treatment of Household Drinking Water ***
tab hv237
gen watertrt = 2
replace watertrt = 1 if (hv237a == 1|hv237b == 1|hv237c == 1|hv237d == 1|hv237e == 1|hv237f == 1)
label define watertrt 1 "Yes" 2 "No" 
label values watertrt watertrt
label variable watertrt "Treatment of Household Drinking Water"
tab watertrt
svy:tab watertrt ece, row

*Residence.
tab hv025
gen area = hv025
label define arealab  2 "Rural" 1 "Urban"
label values area arealab
tab area
tab area ece, row
svy: tab area ece, row


*Division.
tab hv024
gen division= hv024
label define divisionlab  1 "Barisal" 2 "Chattogram" 3 "Dhaka" 4 "Khulna" 5 "Mymensingh" 6 "Rajshahi" 7 "Rangpur" 8 "Sylhet" 
label values division divisionlab
tab division 
svy: tab division ece, row

*Mother Education.
tab v106
gen melevel = v106
label define melevellab  0 "No education" 1 "Primary" 2 "Secondary" 3 "Higher"
label values melevel melevellab
tab melevel
svy: tab melevel ece, row

*Father Education.
tab v701
gen helevel = v701
recode helevel 8=.
label define helevellab  0 "No education" 1 "Primary" 2 "Secondary" 3 "Higher"
label values helevel helevellab
tab helevel
svy: tab helevel ece, row

*Mother work.
tab v714
gen mwork = v714
label define mworklab  0 "No" 1 "Yes"
label values mwork mworklab
tab mwork
svy: tab mwork ece, row

*Father Occu.
tab v704
gen fwork = v704
recode fwork 0=0
recode fwork 61=0
recode fwork 96=0
recode fwork 11/23=1
recode fwork 31=2
recode fwork 41=2
recode fwork 51/52=3
recode fwork 98/99=.
recode fwork 99998=.
label define fworkla  0 "Not working" 1 "Agriculture/manual" 2 "Professional/Services" 3 "Sales"
label values fwork fworkla
tab fwork
svy: tab fwork ece, row

*Religion.
tab v130
gen religion=v130
recode religion 1=1
recode religion 2/4=2
recode religion 96=.
label define religionlab 1 "Islam" 2 "Others"
label values religion religionlab
tab religion
svy: tab religion ece, row

*Wealth index Status.
tab hv270
gen wealth= hv270
recode wealth (1/2=1) (3=2) (4/5=3)
label define wealthlab  1 "Poor" 2 "Middle" 3 "Rich" 
label values wealth wealthlab
tab wealth
svy: tab wealth ece, row

*HH family members.
tab hv009
gen hhmembers = hv009
replace  hhmembers    = 1 if (hhmembers <= 4) 
replace  hhmembers   = 2 if (hhmembers > 4)
label define hhmembers1 1 "less equal 4" 2 "greater 4"
label values hhmembers hhmembers1
tab hhmembers ece, row 
svy: tab hhmembers ece, row 

*household head sex.
tab hv219
gen hhsex = hv219
label define hhsex1 1 "Male" 2 "Female"
label values hhsex hhsex1
tab hhsex ece, row 
svy: tab hhsex ece, row 


*Access to Massmedia
tab v120
tab v121
gen massMedia=0
replace massMedia=1 if (v120==1|v121==1)
replace massMedia=. if (v120==7|v121==7)
label define masslab 1 "Have access" 0 "Have no access"
label values massMedia masslab
tab massMedia
svy: tab massMedia ece, row

*** Mother exposed to Mass Media ***
tab v157
tab v158
tab v159
gen exmassmedia = .
replace exmassmedia = 1 if (inlist(v157, 1, 2)|inlist(v158, 1, 2)|inlist(v159, 1, 2))
replace exmassmedia = 2 if (v157 == 0|v158 == 0|v159 == 0)
label define exmassmedia 1 "Yes" 2 "No"
label values exmassmedia exmassmedia
tab exmassmedia
svy: tab exmassmedia ece, row
 
***Child Information

*child sex.
tab b4
gen csex = b4
label define csexlab 1 "Male" 2 "Female"
label values csex csexlab
tab csex ece, row 
svy: tab csex ece, row 

* Birth order 
gen fe_bord = bord if b0 < 2
replace fe_bord = bord - b0 + 1 if b0 > 1
recode fe_bord (1 =1 "1") (2/3=2 "2-3") (4/max=3 "4+"), gen(fe_bord_cat) label(fe_bord_lab)
label var fe_bord_cat "Birth order categories"
ta fe_bord_cat ece, row
svy: ta fe_bord_cat ece, row

* Save final data (15/11)
save final_data, replace

* Load final_data 
use final_data, clear

*******************************************
** Descriptives
svy: tab ece, count col
svy: tab hwashing , count col
svy: tab hwashplace , count col
svy: tab toilet, count col
svy: tab toiletshare , count col
svy: tab water, count col 
svy: tab watertrt , count col
svy: tab area, count col
svy: tab division, count col
svy: tab melevel, count col
svy: tab helevel, count col
svy: tab mwork, count col
svy: tab fwork, count col
svy: tab religion, count col
svy: tab wealth, count col
svy: tab hhmembers, count col 
svy: tab hhsex, count col 
svy: tab massMedia, count col
svy: tab exmassmedia , count col
svy: tab csex, count col 
svy: tab fe_bord_cat, count col

**********************************************
tab ece
svy: tab ece
tab hwashing ece, row
svy: tab hwashing ece, row
tab hwashplace ece, row
svy: tab hwashplace ece, row
tab toilet ece , row
svy: tab toilet ece , row
tab toiletshare ece , row
svy: tab toiletshare ece , row
tab water ece, row 
svy:tab water ece, row 
tab watertrt ece, row 
svy:tab watertrt ece, row
tab area ece, row
svy: tab area ece, row
tab division ece, row
svy: tab division ece, row
tab melevel ece, row
svy: tab melevel ece, row
// tab helevel ece, row
// svy: tab helevel ece, row
// tab mwork ece, row
// svy: tab mwork ece, row
// tab fwork ece, row
// svy: tab fwork ece, row
tab religion ece, row
svy: tab religion ece, row
tab wealth ece, row
svy: tab wealth ece, row
tab hhmembers ece, row 
svy: tab hhmembers ece, row 
tab hhsex ece, row 
svy: tab hhsex ece, row 
tab massMedia ece, row
svy: tab massMedia ece, row
tab exmassmedia ece, row
svy: tab exmassmedia ece, row
tab csex ece, row 
svy: tab csex ece, row 
tab fe_bord_cat ece, row
svy: tab fe_bord_cat ece, row


***  Logistic Modeling

 * Crode model
svy: logit ece ib2.hwashing, or
svy: logit ece ib2.hwashplace, or
svy: logit ece ib2.toilet, or
svy: logit ece i.toiletshare, or
svy: logit ece i.water, or
svy: logit ece ib2.watertrt, or
svy: logit ece ib2.area, or
svy: logit ece i.division, or
svy: logit ece i.melevel, or
/*
svy: logit ece i.helevel, or
svy: logit ece ib1.mwork, or
svy: logit ece i.fwork, or
*/
svy: logit ece ib2.religion, or
svy: logit ece i.wealth, or
svy: logit ece i.hhmembers, or
svy: logit ece i.hhsex, or
svy: logit ece i.massMedia, or
svy: logit ece i.exmassmedia, or
svy: logit ece ib2.csex, or
svy: logit ece ib3.fe_bord_cat, or

* Adjusted model
svy: logit ece ib2.hwashing ib2.hwashplace ib2.toilet i.toiletshare ib2.watertrt i.division i.melevel i.wealth i.massMedia ib3.fe_bord_cat, or


