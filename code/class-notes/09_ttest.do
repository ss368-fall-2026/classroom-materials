/*
Author: Mike Baker 
Created: 2025-08-27  | Date Updated: 2026-09-03     						            

Purpose: in-class example of t-tests and practice problem

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

qui cap log close ttest
log using "${logs}/ttest.log", text replace name(ttest)

*--------------------------------------
* IMPORT DATA AND ESTIMATE OLS COEFF AND SE
*--------------------------------------

use "https://raw.githubusercontent.com/ss368-fall-2026/classroom-materials/main/data/jw_datasets/WAGE2.DTA", clear

reg lwage exper 

*--------------------------------------
* SIMPLE REGRESSION T-TEST
*--------------------------------------

* calculate t-stat 
local t = _b[exper]/_se[exper]
di "t-statistic: `t'"

local tabs = abs(`t')

* capture observations 
local N = `e(N)'

* calc df 
local df = `N' - 2 

* select significance level 
local sig_lvl = 0.05

* critical value lookup for two-sided test
*** this is finding the 100-sig_lvl/2 percentile of the t distribution
di invttail(`df',`sig_lvl'/2)

local c_neg = -invttail(`df',`sig_lvl'/2)
loca c_pos = invttail(`df',`sig_lvl'/2)

* calculate p-value - equivalent methods
di 2*(1 - t(`df',abs(`t')))
local p = 2*(1 - t(`df',abs(`t')))
di "p-value: `p'"

local cdf = t(`df',abs(`t'))
di "`cdf'"

di 2*ttail(`df', abs(`t'))

* PLOT CDF

clear
set obs 1000
generate x = (_n - 500)/50

gen t = tden(`df',x)
gen tcdf = t(`df',x)
local abs_t = abs(`t')

drop if !inrange(x,-4,4)

 * graph setup
local xmax = 4
local xmin = -4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

local ymax = 1
local ymin = 0
local yskip = 0.1
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 
		
#delimit ;
twoway 
line tcdf x, lcolor(gs13) ||
pci 0 `abs_t' `cdf' `abs_t', lcolor(red) lpattern(dash) ||
pci `cdf' `xmin' `cdf' `abs_t', lcolor(red) lpattern(dash) ||,
xtitle("")
xlabels(`xlabels')
xmtick(`xmlabels')
ytitle("P(T {&le} t)")
ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
ymtick(`ymlabels')
legend(off) 
graphregion(color(white));
graph export "output/simple_ttest_cdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

local tdens_t = tden(`df', `t')

* PLOT PDF  
clear
set obs 1000
generate x = (_n - 500)/50

drop if !inrange(x,-4,4)

* generate t-pdf
generate tdist = tden(`N'-2, x)

* shading 
gen right_tail = x >= `t'
gen left_tail = x <= -`t'
gen base = 0 

 * graph setup
local xmax = 4
local xmin = -4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

local ymax = 0.5
local ymin = 0
local yskip = 0.1
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 

local f_t = string(round(`t',0.01),"%9.2fc")
local f_p = string(round(`p',0.01),"%9.2fc")

* without shading 
#delimit ;
twoway 
line tdist x, lcolor(black) ||
pci 0 `tabs' `tdens_t' `tabs', lcolor(red) lpattern(dash) ||
scatteri 0 `tabs' (10) "|t|", mcolor(red) mlabcolor(black) ||,
xtitle("t") xlabels(`xlabels') xmtick(`xmlabels')
ytitle("Density") ylabels(`ylabels') ymtick(`ymlabels')
legend(off);
graph export "output/simple_ttest_pdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

* with shading
#delimit ;
twoway 
rarea tdist base x if right_tail, sort color(red%30) lcolor(background) ||
rarea tdist base x if left_tail, sort color(red%30) lcolor(background) ||
line tdist x, lcolor(black) ||
pci 0 `tabs' `tdens_t' `tabs', lcolor(red) lpattern(dash) ||
scatteri 0 `tabs' (10) "|t|", mcolor(red) mlabcolor(black) ||
pci 0 -`tabs' `tdens_t' -`tabs', lcolor(red) lpattern(dash) ||
scatteri 0 -`tabs' (2) "-|t|", mcolor(red) mlabcolor(black) ||,
xtitle("t") xlabels(`xlabels') xmtick(`xmlabels')
ytitle("Density") ylabels(`ylabels') ymtick(`ymlabels')
legend(off)
note("t-statistic: `f_t' // p-value: `f_p'");
graph export "output/simple_ttest_pdf_shaded.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

*--------------------------------------
* PRACTICE PROBLEM
*--------------------------------------

* relationship between mother's education and birth weight 
use "https://raw.githubusercontent.com/ss368-fall-2026/classroom-materials/main/data/jw_datasets/BWGHT.DTA", clear

reg bwght cigprice

* calc. t-stat 
di  _b[cigprice]/_se[cigprice]

* calc. P(T<=t) under the null 
di t(`e(N)', _b[cigprice]/_se[cigprice])

* calc. p-value 
di 2*(1-t(`e(N)', _b[cigprice]/_se[cigprice]))

* calculate the 95% confidence interval 
*** select significance level 
local sig_lvl = 0.05

*** critical value lookup for two-sided test
***** this is finding the (100-sig_lvl)/2 percentile of the t distribution. E.g., if sig_lvl is .05, we want to find the 97.5 percentile of the t-distribution 

local critical_value = invttail(`e(df_r)',`sig_lvl'/2)
di "`critical_value'"

local upper_ci = _b[cigprice] + `critical_value'*_se[cigprice]
di "`upper_ci'"

local lower_ci = _b[cigprice] - `critical_value'*_se[cigprice]
di "`lower_ci'"

di "Interval Estimate: [`lower_ci', `upper_ci']"

log close ttest
clear all 
