/********************************************************************
* Author:       Hude Hude
* Position:     Candidate for Yale PreDoc Position with Professor Cooper
* Task:         Coding Task for PreDoc Application
* Description:  This do-file contains code for completing the Yale PreDoc 
*               coding test, covering tasks up to Problem 5, with outputs 
*               summarized in LaTeX.
*
* Notes:        - Time taken: 3 hours 30 minutes for coding tasks; additional
*                 15 minutes for LaTeX write-up.
*               - Encountered challenges with `parmest` package; used an
*                 alternative approach to achieve desired results.
*               - Prepared a zip file with all relevant code and outputs.
*
* Contact:      hh3024@columbia.edu
********************************************************************/


cd "/Users/kissshot894/Documents/MAE/Predoc/Tobin/Medicare_workplace"
use datatask_treat.dta, clear

// 1)
// Convert prov_id to uppercase
replace prov_id = upper(prov_id)

merge 1:m prov_id using datatask_main.dta

keep if _merge == 3
drop _merge

// Save the merged file as a new .dta file
save datatask_merged.dta, replace

// 2)
// Sort the dataset by year before running the loop
sort year

// Loop through each technology variable to calculate weights
foreach tech in tech_1 tech_2 tech_3 tech_4 tech_5 tech_6 tech_7 tech_8 tech_9 tech_10 ///
                tech_11 tech_12 tech_13 tech_14 tech_15 tech_16 tech_17 tech_18 tech_19 tech_20 ///
                tech_21 tech_22 tech_23 tech_24 tech_25 tech_26 tech_27 tech_28 tech_29 tech_30 tech_31 {

    // Calculate the proportion of hospitals with each technology per year
    by year: egen prop_`tech' = mean(`tech')
    
    // Calculate the weight a_{k,t} for each technology
    gen a_`tech' = 1 - prop_`tech'
}

// Calculate the Saidin Index for each hospital and year (Equivalent to summing over each rows)
gen saidin = 0

foreach tech in tech_1 tech_2 tech_3 tech_4 tech_5 tech_6 tech_7 tech_8 tech_9 tech_10 ///
                tech_11 tech_12 tech_13 tech_14 tech_15 tech_16 tech_17 tech_18 tech_19 tech_20 ///
                tech_21 tech_22 tech_23 tech_24 tech_25 tech_26 tech_27 tech_28 tech_29 tech_30 tech_31 {

    // Add the weighted technology to the Saidin Index
    replace saidin = saidin + (`tech' * a_`tech')
}

// Display saidin index right next to each hospital-year pair
order prov_id year saidin

// Save the dataset with the Saidin Index as a seperate .dta file
save datatask_saidin.dta, replace

// 3)
// Load the dataset with the Saidin Index
use datatask_saidin.dta, clear  

// Keep only observations from 2004
keep if year == 2004                 

// Save as a new dataset containing only 2004 data
save datatask_2004.dta, replace   

// a)
// Summary statistics for Saidin Index
summarize saidin

// Kernel density plot of the Saidin Index
kdensity saidin, title("Kernel Density of Saidin Index in 2004")
graph export Kernel_Saidin_2004.png, replace

// b) & c)
// OLS regression on the observables.
regress saidin teach beds nonprof govt treat

// 4)
// Load entire dataset
use datatask_saidin.dta, clear

// Create interaction terms between each year from 2001 to 2010 and the treatment indicator
foreach yr of numlist 2001/2010 {
    gen treat_yr`yr' = treat * (year == `yr')
}

// To use xtset, prov_id must be non-string.
encode prov_id, gen(prov_ID)

xtset prov_ID year
	   
// Remove year 2004 to make it as baseline year
xtreg saidin ib2004.year treat_yr2001 treat_yr2002 treat_yr2003 treat_yr2005 ///
       treat_yr2006 treat_yr2007 treat_yr2008 treat_yr2009 treat_yr2010, fe cluster(prov_ID)
	   
//Alternative way: two-way fixed effect. But we want to identify gamma_t, which is absorbed in this method
reghdfe saidin treat_yr2001 treat_yr2002 treat_yr2003 treat_yr2005 ///
       treat_yr2006 treat_yr2007 treat_yr2008 treat_yr2009 treat_yr2010, absorb(prov_id year) cluster(prov_id)


// Redo xtreg and output estiamtes
// Remove year 2004 to make it as baseline year
xtreg saidin ib2004.year treat_yr2001 treat_yr2002 treat_yr2003 treat_yr2005 ///
       treat_yr2006 treat_yr2007 treat_yr2008 treat_yr2009 treat_yr2010, fe cluster(prov_ID)

// Using parmest, but I am not really sure how this work. At least I think I didn't use it right.
parmest, label saving("regression_results.dta", replace)
use "regression_results.dta", clear
// Create a new variable 'year' by extracting numeric year values from 'parm'
gen year = .

// Extract numeric year values for entries like "2001.year", "2004b.year"
replace year = real(regexs(1)) if regexm(parm, "([0-9]{4})")

// Extract year for 'treat_yr' parameters (e.g., "treat_yr2008")
replace year = real(regexs(1)) if regexm(parm, "treat_yr([0-9]{4})")

// Drop the row where 'parm' is "_cons"
drop if parm == "_cons"
drop label

// Keep only the first 10 rows
keep in 1/10
rename estimate lambda
// Drop the unnecessary columns
drop stderr dof t p min95 max95

// Save the dataset as year.dta
save year.dta, replace

// Repeat for treat estiamtes
use regression_results.dta, clear
// Create a new variable 'year' by extracting numeric year values from 'parm'
gen year = .

// Extract numeric year values for entries like "2001.year", "2004b.year"
replace year = real(regexs(1)) if regexm(parm, "([0-9]{4})")

// Extract year for 'treat_yr' parameters (e.g., "treat_yr2008")
replace year = real(regexs(1)) if regexm(parm, "treat_yr([0-9]{4})")

// Drop the row where 'parm' is "_cons"
drop if parm == "_cons"
drop label

// Keep only the first 10 rows
drop in 1/10
rename estimate beta
// Drop the unnecessary columns
drop stderr dof t p

save treat.dta, replace

// create output.dta
use treat.dta
merge 1:1 year using year.dta

order year
drop parm _merge
gen tr_mean = beta + lambda
// Rename variables according to the specified names
rename beta tr_effect           
rename min95 tr_lo            
rename max95 tr_hi            
rename lambda cr_mean         

save Hude_Hude_estimates.dta, replace


// 5)
use Hude_Hude_estimates.dta, clear
sort year

// Create adjusted 95% CI bounds by adding cr_mean to tr_lo and tr_hi
gen tr_lo_adj = tr_lo + cr_mean
gen tr_hi_adj = tr_hi + cr_mean

// Plot with transformed 95% CI bounds
twoway (line cr_mean year, lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (line tr_mean year, lcolor(red) lwidth(medium) lpattern(dash)) ///
       (rcap tr_lo_adj tr_hi_adj year, lcolor(red)) ///
       , ///
       title("Average Change in Saidin Index Relative to 2004") ///
       xlabel(2001(1)2010) ///
       ylabel(-4(1)7, angle(0)) ///
       legend(order(1 "Control Group" 2 "Treatment Group" 3 "95% CI for Treatment")) ///
       ytitle("Saidin Index Change") ///
       xtitle("Year") ///
       graphregion(color(white))

// Export the graph as a PNG file
graph export "Hude_Hude_estimates_graph.png", replace

// 6)
// See write-up







