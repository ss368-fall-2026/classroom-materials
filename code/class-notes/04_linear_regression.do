/*
Author: Mike Baker 
Created: 2025-08-27 | Date Updated: 2026-08-25        						            

Purpose: example of manually calculating the OLS coefficients and standard errors; create visualizations for linear regression and sampling distribution of OLS estimates

*/

*****************************************************************
* PRELIMINARIES
*****************************************************************
clear all
qui cap restore

* DIRECTORY SETUP - file paths for log and output files 
* main directory
global main "C:\Users\michael.baker\Documents\ss368\ss368-fall2026\classroom-materials"
cd "${main}"

global output  "${main}/output"
global logs    "${output}/logs"   

qui cap log close linear_regression
log using "${logs}/linear_regression.log", text replace name(linear_regression)

*--------------------------------------
* MANUALLY CALCULATE COEFFICIENT ESTIMATES 
*--------------------------------------

use "https://raw.githubusercontent.com/ss368-fall-2026/classroom-materials/main/data/jw_datasets/WAGE1.DTA", clear

* calc. covariance 
corr educ wage, cov
*** store as a local macro to use later 
local covariance = `r(cov_12)'

*** calc. mean and variance of education
sum educ,d
local mean_educ = `r(mean)'
local variance_educ = `r(Var)'

*** calc. mean of wage
qui sum wage
local mean_wage = `r(mean)'

* manually calculate beta_hat and intercept

*** beta_hat = cov(educ, wage)/var(educ)
local beta_hat = `covariance'/`variance_educ'

*** formatting for display purposes 
local f_beta_hat = string(round(`covariance'/`variance_educ', .001),"%9.3fc")
di "Slope Coefficient (Beta Hat): `f_beta_hat'"

*** intercept = (mn of wage) - `beta_hat'*(mean of educ)
local intercept = `mean_wage'-`beta_hat'*`mean_educ'

*** formatting for display purposes 
local f_intercept = string(round(`mean_wage'-`beta_hat'*`mean_educ', .001),"%9.3fc")
di "Intercept: `f_intercept'"

* calc. the residuals/prediction errors (u_hat)
gen u_hat = wage - `intercept' - `beta_hat'*educ 

* calc. the sum of squared residuals (SSR)
egen ssr = total(u_hat^2)

* calc. the std. error of the slope coefficient 
*** get number of observations 
qui count 
local N = `r(N)'

*** est. the population variance using the residuals  
local pop_variance_est = (1/(`N'-2))*ssr

*** get the standard deviation of indep. var.
qui sum educ
local sd_educ = `r(sd)'

local se_beta_hat = sqrt(1/(`N'-1))*sqrt(`pop_variance_est')/`sd_educ'
local f_se_beta_hat = string(round(`se_beta_hat', .001),"%9.3fc")
di "Standard Error (Beta Hat): `f_se_beta_hat'"

* calc. the R-squared 

*** calculate the sum of squares total (SST)
egen sst = total((wage - `mean_wage')^2)

*** calc. R-squared: 1 - (ssr/sst)
local r2 = 1-(ssr/sst)
local f_r2 = string(round(`r2', .001),"%9.3fc")

di "R-squared: `f_r2'"

di "Summary"
di "Slope Coefficient (Beta Hat): `f_beta_hat'"
di "Standard Error (Beta Hat): `f_se_beta_hat'"
di "Intercept: `f_intercept'"
di "R-squared: `f_r2'"

* check against built-in regression function 
reg wage educ 
*** everything checks 

* labels
qui mylabels -2(2)30, myscale(@) local(ylabels)
qui mylabels -2(1)30, myscale(@) local(ymlabels)

qui mylabels 0(2)18, myscale(@) local(xlabels)
qui mylabels 0(1)18, myscale(@) local(xmlabels)

* make scatterplot of wage and education
scatter wage educ, mcolor(gs8) msize(tiny) title("Scatter Plot of Wages and Education") ytitle("Avg. Hourly Earnings") ylabel(`ylabels', angle(0)) ymtick(`ymlabels') xtitle("Years of Education") xlabel(`xlabels') xmtick(`xmlabels') xline(0, lcolor(black) lpattern(dash)) legend(off) graphregion(color(white))
qui graph export "${output}/figures/scatter_wage_educ.svg", width(1600) fontface("Times New Roman") replace

* make scatterplot of wage and education - with line of best fit 
twoway scatter wage educ, mcolor(gs8) msize(tiny) || lfit wage educ, lcolor(red) ||, title("Line of Best Fit") ytitle("Avg. Hourly Earnings") ylabel(`ylabels', angle(0)) ymtick(`ymlabels') xtitle("Years of Education") xlabel(`xlabels') xmtick(`xmlabels') xline(0, lcolor(black) lpattern(dash)) legend(off) graphregion(color(white))
qui graph export "${output}/figures/scatter_wage_educ_reg_line.svg", width(1600) fontface("Times New Roman") replace

*--------------------------------------
* GENERATE DATA
*--------------------------------------

* context: we want to estimate the effect of earnings on body weight 
* population: workers in a us county 

* generate data 
clear 
set obs 100000

set seed 730

* generate earnings variable - based on approx. earnings in the U.S. 
gen ln_earnings = rnormal(10.7, 0.7)
gen earnings = exp(ln_earnings)

sum earnings,d 
sum ln_earnings,d 
local sd_ln_earnings = `r(sd)'

* generate idiosyncratic disturbance 
gen u = rnormal(0,18)

* outcome = body weight 
gen body_wt = 100 + 8*ln_earnings + u 

sum body_wt,d

replace earnings = earnings/1000

*--------------------------------------
* CREATE HISTOGRAMS
*--------------------------------------

qui mylabels 0(250)1250, myscale(@) local(xlabels) format("%9.0fc")

histogram earnings, density color(gs8) gap(10) title("Annual Earnings") ylabel(, angle(0)) xtitle("Earnings (Thousands)") xlabel(`xlabels') ytitle("Density") legend(off) graphregion(color(white)) 
qui graph export "${output}/figures/histogram_earnings.svg", width(1600) fontface("Times New Roman") replace

histogram ln_earnings, density color(gs8) gap(10) title("Log(Annual Earnings)") ylabel(, angle(0)) xtitle("Log(Annual Earnings)") ytitle("Density") legend(off) graphregion(color(white)) 
qui graph export "${output}/figures/histogram_ln_earnings.svg", width(1600) fontface("Times New Roman") replace

histogram body_wt, density color(gs8) gap(10) title("Body Weight (lbs)") ylabel(, angle(0)) xtitle("Body Weight (lbs)") ytitle("Density") legend(off) graphregion(color(white)) 
qui graph export "${output}/figures/histogram_body_wt.svg", width(1600) fontface("Times New Roman") replace

*--------------------------------------
* REGRESSION PLOTS
*--------------------------------------

* visualize regression
qui mylabels 75(50)275, myscale(@) local(ylabels)
qui mylabels 75(25)300, myscale(@) local(ymlabels)

qui mylabels 0(2)16, myscale(@) local(xlabels)
qui mylabels 0(1)16, myscale(@) local(xmlabels)

scatter body_wt ln_earnings, mcolor(gs8) msize(tiny) title("Scatter Plot of Body Weight and Log(earnings)") ytitle("Body Weight (lbs.)") ylabel(`ylabels', angle(0)) ymtick(`ymlabels') xtitle("Log(earnings)") xlabel(`xlabels') xmtick(`xmlabels') xline(0, lcolor(black) lpattern(dash)) legend(off) graphregion(color(white))
qui graph export "${output}/figures/scatter_body_wt_earnings.svg", width(1600) fontface("Times New Roman") replace

twoway scatter body_wt ln_earnings, mcolor(gs8) msize(tiny) || lfit body_wt ln_earnings, lcolor(red) range(0 16) ||, title("Line of Best Fit") ytitle("Body Weight") ylabel(`ylabels', angle(0)) ymtick(`ymlabels') xtitle("Log(earnings)") xlabel(`xlabels') xmtick(`xmlabels') xline(0, lcolor(black) lpattern(dash)) legend(off) graphregion(color(white))
qui graph export "${output}/figures/reg_body_wt_earnings.svg", width(1600) fontface("Times New Roman") replace

reg body_wt ln_earnings 
local pop_beta = _b[ln_earnings]

* save the dta as a temporary file to enable loop below 
tempfile raw_data 
save `raw_data'

*--------------------------------------
* SAMPLING VARIANCE VISUALS
*--------------------------------------

 *** formatting labels: horizontal axis
local xmax = 12
local xmin = 4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

*** formatting labels: vertical axis
local ymax = 1.4
local ymin = 0
local yskip = 0.2
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 

local num_samples = 10000

foreach sample_size in 1000 5000 {
	
		set seed 403
		
		matrix beta1_est_`num_samples' = J(`num_samples', 1, .)
		
		use `raw_data', clear 
		
		forvalues i = 1/`num_samples' { 
			preserve 
				
				*** draw a random sample without replacement 
				qui sample `sample_size', count
				
				qui reg body_wt ln_earnings 
				
				matrix beta1_est_`num_samples'[`i', 1] = _b[ln_earnings] 
			
			restore 
		}
	
		* convert matrix to dta
		clear 
		qui svmat beta1_est_`num_samples', names(beta)

		qui sum beta1
		local e_beta1 = `r(mean)'

		* plot histogram
		local f_e_beta1 = string(round(`e_beta1',.001), "%09.3fc")
		local f_pop_beta = string(round(`pop_beta',.001), "%09.3fc")
		local f_sample_size = string(`sample_size', "%9.0fc")
		local f_num_samples = string(`num_samples', "%9.0fc")
		twoway histogram beta1, density color(gs8) gap(10) ||, title("Distribution of Estimates Across Samples") subtitle("N = `f_sample_size', Samples = `f_num_samples'") ylabel(`ylabels', angle(0)) ymtick(`ymlabels') xtitle("Beta Estimates") xlabel(`xlabels') xmtick(`xmlabels') ytitle("Density") legend(off) graphregion(color(white)) caption("Population Beta: `f_pop_beta'" "Avg. Beta Across Samples: `f_e_beta1'")
		qui graph export "${output}/figures/sampling_variation_ex_`num_samples'_samples_size_`sample_size'.svg", width(1600) fontface("Times New Roman") replace
}

log close linear_regression
clear all 
