/*
Author: Mike Baker         						            
Created: 2025-08-21 | Date Updated: 2026-08-19

Purpose: confidence intervals demo - 20-sided die 

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

qui cap log close ci_demo

log using "${logs}/ci_demo.log", text replace name(ci_demo)

*---------------------------------------------------
* CONFIDENCE INTERVALS AND DISTRIBUTIONS
*---------------------------------------------------

* GENERATE DATA 
clear all 

* number of samples 
local num_samples = 100      

set obs `num_samples'

* generate sample identifier
gen sample_id = _n

set seed 6725

* generate the die roll outcomes for each observation
local sample_size = 20 

forvalues i = 1/`sample_size' {
    gen obs`i' = ceil(runiform() * 20)
}

* pop mean for a uniform(1,20) rv is 10.5 
local mu = 10.5 

* for each sample size, produce a set of confidence intervals and a histogram of the sample means
foreach sample_size in 6 20 {
	
	preserve 
		
		if `sample_size' == 6 {
			drop obs7-obs20 
		}
		
		egen sample_sd = rowsd(ob*)

		egen sample_mean = rowmean(ob*)

		gen se_hat = sample_sd/sqrt(`sample_size')

		gen lower_ci = sample_mean - se_hat
		gen upper_ci = sample_mean + se_hat
		
		* how often does the CI include the true value? 
		qui count if upper_ci >= `mu' &  lower_ci <= `mu'
		local share_in_ci = (`r(N)'/`num_samples')*100
		
		di "Share of CIs that contain true value (68% CI): `share_in_ci'"
		
		*** formatting labels: horizontal axis
		qui mylabels 0(2)20, myscale(@) local(xlabels)
		qui mylabels 0(1)20, myscale(@) local(xmlabels)
		
		* rcap plots the confidence intervals, scatter plots the estimates - limiting to only the first thirty samples for the figure 
		* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
		twoway rcap lower_ci upper_ci sample_id if inrange(sample_id,1,30), horizontal || scatter sample_id sample_mean if inrange(sample_id,1,30) ||, xline(`mu') xlab(0(5)20) title("68% Confidence Intervals: Sample Sizes of `sample_size'") xtitle("Sample") xlabels(`xlabels') xmtick(`xmlabels') legend(off) graphregion(color(white)) note("Share of CIs that contain true value (68% CI): `share_in_ci'")
		graph export "${output}/figures/ci68_sampsize`sample_size'.svg", width(1600) fontface("Times New Roman") replace
		
		replace lower_ci = sample_mean - 1.96*se_hat
		replace upper_ci = sample_mean + 1.96*se_hat
		
		* how often does the CI include the true value? 
		qui count if upper_ci >= `mu' &  lower_ci <= `mu'
		local share_in_ci = (`r(N)'/`num_samples')*100
		
		di "Share of CIs that contain true value (95% CI): `share_in_ci'"
		
		* rcap plots the confidence intervals, scatter plots the estimates - limiting to only the first thirty samples for the figure 
		* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
		twoway rcap lower_ci upper_ci sample_id if inrange(sample_id,1,30), horizontal || scatter sample_id sample_mean if inrange(sample_id,1,30) ||, xline(`mu') xlab(0(5)20) title("95% Confidence Intervals: Sample Sizes of `sample_size'") xtitle("Sample") xlabels(`xlabels') xmtick(`xmlabels') legend(off) graphregion(color(white)) note("Share of CIs that contain true value (95% CI): `share_in_ci'")
		graph export "${output}/figures/ci95_sampsize`sample_size'.svg", width(1600) fontface("Times New Roman") replace
		
		* histogram plots the sampling distribution (i.e., the distribution of estimates/sample means)
		* i recommend exporting graphs as .svg's - most compatible/fastest way to retain high-quality graphics 
		histogram sample_mean, width(0.5) frequency title("Distribution of Sample Means (100 Samples of `sample_size' Rolls)") xtitle("Sample Average") ylab(0(5)20) xlab(2(2)18) xline(`mu') graphregion(color(white)) xlabels(`xlabels') xmtick(`xmlabels')
		graph export "${output}/figures/sampling_distribution_sampsize`sample_size'.svg", width(1600) fontface("Times New Roman") replace
		
	restore 
}

log close ci_demo
clear all 
