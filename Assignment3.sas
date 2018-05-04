/*
Assignment No.3
*/

Options MPRINT  FULLSTIMER;
LIBNAME assign3 'C:\445_695\Course_data';

*Question 23.2;
proc sort data=assign3.Narrow out=narrow; *the first step is to sort by subject & time;
	by Subj Time; *the dataset assign3.narrow is already sorted that way, we simply added this step to make it general;
run;

data Stretch;*make a temporary dataset called stretch;
	set Narrow; *this uses the values from the dataset Narrow;
	by Subj Time;
	array S{5}; *the number of index for the array is 5 because each subject visits 5 times;
	retain S1-S5; *the values from the array must be retained since they don't come from the dataset;
	if first.Subj then call missing(of Dx1-Dx5); *during the first visit for each subject, set the five values of dx to missing;
	S{Time}=Score; *assigns the values of score to the correct position in the array;
	if last.Subj then output; *output only after the control flow reaches the last visit of the subject;
	keep Subj S1-S5;
run;

title "Converting the dataset Narrow, which contains one observation per subject to a dataset with multiple observations per subject";
proc print data=Stretch;
run;


*Question 23.4;
proc transpose data=assign3.Narrow prefix=Dx out=Stretch2 (drop=_NAME_);
by Subj; *each row will be a subject;
id Time; *the values of Time will correspond the values of Dx in the columns;
var Score;
run;

title "Converting with PROC TRANSPOSE the dataset Narrow, which contains one observation per subject to a dataset with multiple observations per subject";
proc print data=Stretch2;
run;

*Question 24.6;
proc sort data=assign3.Dailyprices out=Dailyprices;
by Symbol Date;
run;

data priceDiff;
set Dailyprices;
by Symbol; *creates two temporary SAS variable called first.Symbol and last.Symbol;
if first.Symbol and last.Symbol then delete; *omits stocks with only one observation;
if first.Symbol or last.Symbol then do;
	Diff_Price=Price-lag(Price); *calculates the price of the last day minus the price of the first day;
end;
if last.Symbol then output; *upon reaching the last day, output the observation;
run;

title "Computing the difference between the price on the last day minus the price on the first day";
proc print data=priceDiff;
run;

*Question 25.4;
proc contents data=assign3.bicycles;
run;

title "Statistics from data set learn.bicycles";
%macro STATS(Dsn,Class,Vars); *creates a macro called STATS with 3 positional arguments: dsn, class, var;
	proc means data=&Dsn n mean min max maxdec=1; *perform a proc means statement while referencing the argument dsn;
	class &Class; *references the argument class in a class statement;
	var &Vars; *references the argument vars in a var statement;
run;
%mend STATS;

%STATS(Assign3.bicycles, Country, Units TotalSales); *calling the macro STATS with the appropriate arguments;


*Question 25.5;
proc means data=assign3.Fitness noprint;
var TimeMile RestPulse MaxPulse;
output out=means mean= M_TimeMile M_RestPulse M_MaxPulse; *compute the means of TimeMile, RestPulse and MaxPulse in a output dataset called means;
run;

data _null_;
set means;
call symput('AveTimeMile',M_TimeMile); *creates a macrovariable representing the mean of TimeMile;
call symput('AveRestPulse',M_RestPulse); *creates a macrovariable representing the mean of RestPulse;
call symput('AveMaxPulse',M_MaxPulse); *creates a macrovariable representing the mean of MaxPulse;
run;

data FitnessPercentages;
set assign3.Fitness;
P_TimeMile=TimeMile/&AveTimeMile;    *calculate the percentage of the means for TimeMile;
P_RestPulse=RestPulse/&AveRestPulse; *calculate the percentage of the means for RestPulse;
P_MaxPulse=MaxPulse/&AveMaxPulse;    *calculate the percentage of the means for MaxPulse;
format P_TimeMile P_RestPulse P_MaxPulse percent8.; *percent format adds a % sign and multiplies by 100;
run;

title "Computing the percentage values for TimeMile, RestPulse and MaxPulse";
proc print data=FitnessPercentages;
run;

*Question 26.4;

title "Using PROC SQL to list all purchased item from the dataset Purchase (including the total cost)";
proc sql;
select Purchase.CustNumber,
	   Purchase.Model, 
       Purchase.Quantity,
	   Inventory.Price*Purchase.Quantity as Cost
from assign3.Inventory, assign3.Purchase
where Purchase.Model=Inventory.Model; *output only the models which appear in both purchase and inventory;
quit;

*Question 26.8;

data Blood; *this step was added because the Blood dataset in course_data was corrupted;
infile "C:\445_695\course_data\blood.txt";
input Obs Gender $ BloodType $ AgeGroup $ WBC RBC Cholesterol;
run;

title "Listing the values of RBC, WBC & their percentage of the mean values";
proc sql;
select RBC, WBC, 
	   (RBC/mean(RBC))*100 as Percent_RBC,
	   (WBC/mean(WBC))*100 as Percent_WBC
from Blood; *lists the RBC, WBC from the Blood dataset and calculates their percentage of the means;
quit;
