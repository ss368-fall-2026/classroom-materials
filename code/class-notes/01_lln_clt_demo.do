/*
Author: Mike Baker         						            
Created: 2025-08-20 | Date Updated: 2026-08-19

Purpose: create visualizations to demonstrate the law of large numbers and the central limit theorem

*/

*----------------------------------------------------------------
* PRELIMINARIES
*----------------------------------------------------------------

clear all
qui cap restore

* DIRECTORY SETUP - file paths for log and output files 

* main directory
global main "C:\Users\michael.baker\Documents\ss368\ss368-fall2026\classroom-materials"
cd "${main}"

global output  "${main}/output"
global logs    "${output}/logs"   

qui cap log close lln_clt_demo
log using "${logs}/lln_clt_demo.log", text replace name(lln_clt_demo)

*----------------------------------------------------------------
* LAW OF LARGE NUMBERS
*----------------------------------------------------------------
/* simulation: 
- draw 100 samples of different sample sizes
- for each sample, calculate the sample mean
- plot the distribution of sample means (the sampling distribution)
*/

* setting the seed ensures the results are repoducible, otherwise the random number generation will produce slightly different results each time 
set seed 7645

* setting the number of samples to 100 
local num_samples = 100

* looping through different sample sizes 
foreach sample_size in 100 1000 10000 100000 {
	
	* results are saved in a matrix and then converted to a dta 
	matrix sample_means_size_`sample_size' = J(`num_samples', 1, .)

	forvalues i = 1/`num_samples' {
		
		clear
		qui set obs `sample_size'
		
		gen rand = runiform(0,1)
		
		qui sum rand 
		
		matrix sample_means_size_`sample_size'[`i', 1] = `r(mean)'
		
		drop rand 
		
	}

	* convert matrix to dta 
	clear 
	qui svmat sample_means_size_`sample_size', names(sample_mean)
	
	* plot histogram
	
	*** create labels for the horizontal axis
	qui mylabels 0.4(0.05)0.6, myscale(@) local(xlabels)
	qui mylabels 0.4(0.025)0.6, myscale(@) local(xmlabels)
	
	*** format presentation of sample size and number of samples 
	local f_sample_size = string(`sample_size', "%9.0fc")
	local f_num_samples = string(`num_samples', "%9.0fc")
	
	local ymax = 25
	
	* #delimit - changing the delimiter makes it easier to read the graph command 
	* histogram plots the sampling distribution, pci adds a line at the pop. mean, scatteri adds the label population mean 
	* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
	#delimit ; 
	twoway histogram sample_mean1, frequency color(orange) gap(10) ||
	pci 0 0.5 `ymax' 0.5, lcolor(black) lpattern(dash) ||
	scatteri `ymax' 0.5 "Population Mean", msymbol(i) mlabcolor(black) mlabposition(3) ||,
	title("Distribution of Sample Means")
	subtitle("N = `f_sample_size', No. of Samples = `f_num_samples'")
	ylabel(, angle(0)) xtitle("Sample Means")
	xlabel(`xlabels') xmtick(`xmlabels') 
	ytitle("Frequency")
	legend(off);
	graph export "${output}/figures/lln_sample_means_`num_samples'_samples_size_`sample_size'.svg", width(1600) fontface("Times New Roman") replace; 
	#delimit cr 
}

*-----------------------------------------------
* CENTRAL LIMIT THEOREM
*-----------------------------------------------

* setting the seed ensures the results are repoducible, otherwise the random number generation will produce slightly different results each time 
set seed 5673

* setting the number of samples to 10,000
local num_samples = 10000

* will use the exponential function with beta = 1. Exp. Value = beta and Variance = beta^2
local mu = 1
local sigma = 1

* looping through different samples sizes
foreach sample_size in 5 20 50 500 {
	
	* results are saved in a matrix and then converted to a dta 
	matrix sample_means_size_`sample_size' = J(`num_samples', 1, .)

	forvalues i = 1/`num_samples' {
		
		clear
		qui set obs `sample_size'
		
		gen double rand = rexponential(1)
		
		* standardize 		
		qui sum rand 
		
		local std = (`r(mean)'-`mu')/(`sigma'/sqrt(`sample_size'))
		
		matrix sample_means_size_`sample_size'[`i', 1] = `std'
		
		drop rand 
		
	}

	* convert matrix to dta 
	clear 
	qui svmat sample_means_size_`sample_size', names(sample_mean)

	* plot histogram
	
	*** create labels for the horizontal axis
	qui mylabels -5(1)5, myscale(@) local(xlabels)
	qui mylabels -5(0.5)5, myscale(@) local(xmlabels)
	
	*** format presentation of sample size and number of samples 
	local f_sample_size = string(`sample_size', "%9.0fc")
	local f_num_samples = string(`num_samples', "%9.0fc")

	
	* #delimit - changing the delimiter makes it easier to read the graph command 
	* histogram plots the sampling distribution, function plots the normal distribution
	* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
	#delimit ;
	twoway histogram sample_mean1, density color(orange) gap(10) ||
	function normalden(x, 0, 1), range(-5 5) lcolor(red) ||,
	title("Distribution of Standardized Sample Means")
	subtitle("N = `f_sample_size', No. of Samples = `f_num_samples'")
	ylabel(, angle(0)) xtitle("Standardized Sample Mean")
	xlabel(`xlabels') xmtick(`xmlabels') 
	ytitle("Density")
	legend(off);
	graph export "${output}/figures/clt_sample_means_`num_samples'_samples_of_size_`sample_size'.svg", width(1600) fontface("Times New Roman") replace; 
	#delimit cr 
}

log close lln_clt_demo
clear all 
