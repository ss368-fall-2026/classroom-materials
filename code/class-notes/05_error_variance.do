/*
Author: Mike Baker 
Created: 2025-09-01 | Date Updated: 2026-08-26      						            

Purpose: create visualizations to show cases of constant variance (homoskedasticity) and non-constant variance (heteroskedasticity)

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

qui cap log close error_variance
log using "${logs}/error_variance.log", text replace name(error_variance)

*--------------------------------------
* GENERATE DATA
*--------------------------------------

clear all
set obs 500

* set seed for repoducibility
set seed 7307

* gpa is uniform from 2-4 (for demo purposes)
gen gpa = runiform(2,4)

* set parameters for dgp 
local b0 = 30000
local b1 = 15000
local base_sd = 5000

* constant variance (homoskedasticity)
gen u_c = `base_sd'*rnormal()
gen earnings_c = `b0' + `b1'*gpa + u_c

* non-constant variance (heteroskedasticity)
*** set standard deviation to scale with gpa, but maintain variance at same level of constant variance case - seeking to isolate the difference as the dependence of the variance on x, not the growth of the variance 
gen sd_nc = -7000 + 4000*gpa^3

qui sum sd_nc 

local scale = `base_sd'/`r(mean)'

replace sd_nc = `scale'*sd_nc  

gen u_nc = rnormal(0,sd_nc)
gen earnings_nc = `b0' + `b1'*gpa + u_nc

*--------------------------------------
* CREATE VISUALS
*--------------------------------------

* prep labels
qui mylabels 40000(10000)120000, myscale(@) local(ylabels) format("%9.0fc")
qui mylabels 40000(5000)120000, myscale(@) local(ymlabels)

qui mylabels 2(0.5)4, myscale(@) local(xlabels)
qui mylabels 2(0.25)4, myscale(@) local(xmlabels)

* Panel A: Constant Variance (Homoskedasticity)
#delimit ; 
twoway
	scatter earnings_c gpa, mcolor(black) msymbol(O) msize(vsmall) ||
    lfit earnings_c gpa, lcolor(red) lwidth(medthick) ||,
	xtitle("College GPA") xlabel(`xlabels') xmtick(`xmlabels')
	ytitle("Earnings 10 Years Post-Graduation") ylabel(`ylabels') ymtick(`ymlabels')
	legend(off)
	title("Panel A: Constant Variance (Homoskedasticity)", size(small))
	name(constant, replace);
#delimit cr 

* Panel B: Non-Constant Variance (Heteroskedasticity)
#delimit ; 
twoway
	scatter earnings_nc gpa, mcolor(black) msymbol(O) msize(vsmall) ||
    lfit earnings_nc gpa, lcolor(red) lwidth(medthick) ||,
	xtitle("College GPA") xlabel(`xlabels') xmtick(`xmlabels')
	ytitle("Earnings 10 Years Post-Graduation") ylabel(`ylabels') ymtick(`ymlabels')
	legend(off)
	title("Panel B: Non-Constant Variance (Heteroskedasticity)", size(small))
	name(non_constant, replace);
#delimit cr 

* combine graphs into a single figure 
graph combine constant non_constant, cols(2) imargin(0 0 0 0) title("")
qui graph export "${output}/figures/heteroskedasticity_visual.svg", width(1600) fontface("Times New Roman") replace

log close error_variance
clear all 
