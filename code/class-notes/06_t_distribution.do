/*
Author: Mike Baker 
Created: 2025-02-01 | Date Updated: 2026-09-01      						            

Purpose: plot t distribution

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

qui cap log close t_distribution
log using "${logs}/t_distribution.log", text replace name(t_distribution)

*---------------------------------------------
* PLOT T DIST CDF AND PDF 
*---------------------------------------------
/* t-distribution commands
	t is the cdf
	ttail is the reverse cdf: 1 - cdf 
	tden is the pdf
*/

clear
set obs 1000
generate x = (_n - 500)/50

* generate t-distribution cdf and pdf for various degrees of freedom
foreach i in 10 20 50 100 200 {
	gen t`i' = tden(`i', x)
	gen tcdf`i' = t(`i', x)
}

drop if !inrange(x,-4,4)

* PLOT CDF

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
line tcdf10 x, lcolor(gs13) ||
line tcdf20 x, lcolor(gs8) ||
line tcdf50 x, lcolor(gs5) ||
line tcdf200 x, lcolor(black) ||,
xtitle("")
xlabels(`xlabels')
xmtick(`xmlabels')
ytitle("P(T {&le} t)")
ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
ymtick(`ymlabels')
legend(label(1 "t, df=10") label(2 "t, df=20") label(3 "t, df=50") label(4 "t, df=200") symxsize(*0.5) symysize(*0.5) row(1) position(6)) 
graphregion(color(white));
graph export "output/t_cdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

* PLOT PDF

 * graph setup
local xmax = 4
local xmin = -4
local xskip = 1
local xmskip = `xskip'/2

qui mylabels `xmin'(`xskip')`xmax', myscale(@) local(xlabels) 
qui mylabels `xmin'(`xmskip')`xmax', myscale(@) local(xmlabels) 

local ymax = 0.45
local ymin = 0
local yskip = 0.1
local ymskip = `yskip'/2
qui mylabels `ymin'(`yskip')`ymax', myscale(@) local(ylabels)
qui mylabels `ymin'(`ymskip')`ymax', myscale(@) local(ymlabels) 
		
#delimit ;
twoway 
line t10 x, lcolor(gs13) ||
line t20 x, lcolor(gs8) ||
line t50 x, lcolor(gs5) ||
line t200 x, lcolor(black) ||,
xtitle("")
xlabels(`xlabels')
xmtick(`xmlabels')
ytitle("Density")
ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
ymtick(`ymlabels')
legend(label(1 "t, df=10") label(2 "t, df=20") label(3 "t, df=50") label(4 "t, df=200") symxsize(*0.5) symysize(*0.5) row(1) position(6)) 
graphregion(color(white));
graph export "output/t_pdf.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

*---------------------------------------------
* PLOT T DIST AGAINST STANDARD NORMAL
*---------------------------------------------

* normalden is the standard normal
gen n = normalden(x)

#delimit ;
twoway 
line t10 x, lcolor(gs13) ||
line t20 x, lcolor(gs8) ||
line t50 x, lcolor(gs5) ||
line t200 x, lcolor(black) ||
line n x, lcolor(red) ||, 
xtitle("")
xlabels(`xlabels')
xmtick(`xmlabels')
ytitle("Density")
ylabels(`ylabels',angle(0) glcolor(dimgray) glpattern(dash))
ymtick(`ymlabels')
legend(label(1 "t, df=10") label(2 "t, df=20") label(3 "t, df=50") label(4 "t, df=200") label(5 "z") symxsize(*0.5) symysize(*0.5) row(1) position(6)) 
graphregion(color(white));
graph export "output/t_pdf_w_normal.svg", width(1600) fontface("Times New Roman") replace;
#delimit cr 

log close t_distribution
clear all 
