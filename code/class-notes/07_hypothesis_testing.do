/*
Author: Mike Baker 
Created: 2025-08-25 | Date Updated: 2026-09-01      						            

Purpose: simple practice: t-test, p-values, confidence intervals

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

qui cap log close hypothesis_testing
log using "${logs}/hypothesis_testing.log", text replace name(hypothesis_testing)

*------------------------------------------
* SIMPLE HYPOTHESIS TESTING - MEANS
*------------------------------------------

use "https://raw.githubusercontent.com/ss368-fall-2026/classroom-materials/main/data/jw_datasets/GPA1.DTA", clear 

sum colGPA
local ybar = `r(mean)'

* what is the null? 
local mu_0 = 2.98

* calculate the standard error of the mean estimator
local se = `r(sd)'/sqrt(`r(N)')
di `se'

* calculate t-stat
local t = (`ybar'-`mu_0')/`se'
di `t'

* calculate degrees of freedom
local df = `r(N)' - 1
di `df' 

* select significance level 
local alpha = 0.05

* critical value lookup for two-sided test
*** this is finding the (100-alpha)/2 percentile of the t distribution. E.g., if alpha is .05, we want to find the 97.5 percentile of the t-distribution 
di invttail(`df',`alpha'/2)

local c_neg = -invttail(`df',`alpha'/2)
loca c_pos = invttail(`df',`alpha'/2)

* calculate p-value - equivalent methods
/*
t is the t-distribution cdf: Prob(T<=t)
 
ttail is the t-distribution reverse cdf: Prob(T>T)

t(`df',abs(`t')) returns the probability that a T RV with `df' degrees of freedom has a value less than or equal to |t|

ttail(`df', abs(`t')) returns the probability that a T RV with `df' degrees of freedom has a value greater than |t|
*/

di t(`df', abs(`t'))
di 2*(1 - t(`df', abs(`t')))
local p = 2*(1 - t(`df',abs(`t')))

local abs_t = abs(`t')
local cdf = t(`df',abs(`t'))

di 2*ttail(`df', abs(`t'))

* calculate the 95% confidence interval 
local upper_ci = `ybar' + `c_pos'*`se'
di `upper_ci'

local lower_ci = `ybar' - `c_pos'*`se'
di `lower_ci'

* make plots 

clear
set obs 1000
generate x = (_n - 500)/50

gen t = tden(`df',x)
gen tcdf = t(`df',x)

* get t at critical values 
local t_neg = tden(`df', `c_neg')
local t_pos = tden(`df', `c_pos')

drop if !inrange(x,-4,4)

* CDF

* graph setup

 *** formatting labels: horizontal axis
local xmax = 4
local xmin = -4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

*** formatting labels: vertical axis
local ymax = 1
local ymin = 0
local yskip = 0.1
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 

* #delimit - changing the delimiter makes it easier to read the graph command 
* line plots the cdf, pci adds dashed red lines
* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
#delimit ;
twoway 
    line tcdf x, lcolor(black) ||
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
    graph export "${output}/figures/ttest_practice_cdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

* PDF 

* graph setup

*** formatting labels: horizontal axis
local xmax = 4
local xmin = -4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

*** formatting labels: vertical axis
local ymax = 0.45
local ymin = 0
local yskip = 0.1
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 

* #delimit - changing the delimiter makes it easier to read the graph command 
* line plots the pdf, pci adds dashed red lines
* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
#delimit ;
twoway 
    line t x, lcolor(black) ||
    pci 0 `c_neg' `t_neg' `c_neg', lcolor(red) lpattern(dash) ||
    pci 0 `c_pos' `t_pos' `c_pos', lcolor(red) lpattern(dash) ||,
    xtitle("")
    xlabels(`xlabels')
    xmtick(`xmlabels')
    ytitle("Density")
    ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
    ymtick(`ymlabels')
    legend(off) 
    graphregion(color(white));
    graph export "${output}/figures/ttest_practice_pdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

* 95% confidence interval 
clear
set obs 1
gen lower_ci = `lower_ci'
gen upper_ci = `upper_ci'
gen ybar = `ybar'
gen xval = 0 

 * graph setup
local ymax = 3.15
local ymin = 2.95
local yskip = 0.05
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 

* #delimit - changing the delimiter makes it easier to read the graph command 
* rcap plots the confidence interval, scatter plots the estimate 
* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
#delimit ;
twoway 
    rcap lower_ci upper_ci xval, lcolor(black) lpattern(dash) ||
    scatter ybar xval, msize(large) mlabcolor(red) ||,
    ytitle("Estimate and 95% CI")
    ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
    ymtick(`ymlabels')
    xtitle("")
    xlabels("")
    legend(off); 
    graph export "${output}/figures/confidence_interval_practice.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

log close hypothesis_testing
clear all 
