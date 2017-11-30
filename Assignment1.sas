/*
Assignment No.1
Name: Louis Nguyen
*/
LIBNAME assign1 'C:\445_695\Course_data';

*Question 1;
data work.newemps;
	input First_Name $ Last_Name $ 
		Job_Title $ Salary;
	*added a dollar sign in front of First_Name because the compiler thought that First_Name was a numeric variable instead of character;
	*also deleted the dollar sign after Salary, because it is a numerical value;
	format Salary dollar10.2;
	*a format statement is placed within the DATA step to permanently format the Salary;
	datalines;
	Steven Worton Auditor 40450
	Merle Hieds Trainee 24025
	John Smith Manager 35666
	;
	run;


*Question1b;
title "New employees";
proc print data=work.newemps;
run;


*Question1c;
proc contents data=work.newemps;
run;
*First_Name: Type=Character Length=8 Format=None;
*Job_Title: Type=Character Length=8 Format=None;
*Last_Name: Type=Character Length=8 Format=None;
*Salary: Type=Numeric Length=8 Format=DOLLAR10.2;

*Question2a;

proc format;
value $gender 'M'= 'Male'
			  'F'= 'Female';
value $ans '1'='Strongly agree'
		   '2'='Agree'
		   '3'='No opinion'
		   '4'='Disagree'
		   '5'='Strongly disagree'
		   ' '='Not answered';
run;

data Assign1.Survey2007;
infile datalines dlm='';
*added a blank delimiter to separate between a space & a blank Q1 answer;
input Age 1-2 Gender $ 4 Answer1 $ 6 Answer2 $ 7 Answer3 $ 8 Answer4 $ 9 Answer5 $ 10;
label Age = 'Age'
	Gender= 'Gender'
	Answer1= 'Q1 Answer'
	Answer2= 'Q2 Answer'
	Answer3= 'Q3 Answer'
	Answer4= 'Q4 Answer'
	Answer5= 'Q5 Answer';
format Gender $gender.
	Answer1-Answer5 $ans.; *we used our user created formats here;
datalines;
23 M  5243
30 F 11123
42 M 23555
48 F 55531
55 F 4 232
62 F 3333
68 M 4412 
;
run;

title "Survey 2007";
proc print data=Assign1.Survey2007 label; *label keyword is added at the end to make the labels appear in the output;
run;

*Question 2b;
data Assign1.SurveySubset;
set Assign1.Survey2007;
if Gender='F' and Age>40 and Answer1='5' and Answer3='5'; *to subset all the females older than 40 yrs old who answered '5' for Q1 & Q3 ;
run;

title "Subset of Survey 2007";
proc print data=assign1.SurveySubset;
run;

*Question3
a) True
b) True
c) False
d) True
e) False
f) False
g) True
h) False
i) True
j) True;

*Textbook questions;

*Question 3.6;
data Bank;
infile 'C:\445_695\Course_data\bankdata.txt'; *reads external raw data file;
input Name $ 1-15 
	Acct $ 16-20 
	Balance 21-26 
	Rate 27-30; *column input;
Interest=(Balance*Rate); *calculating the interest based on the balance & rate;
run;

title "Bank Account Data";
proc print data=Bank;
run;

*Question 3.8;

data Bank;
infile 'C:\445_695\Course_data\bankdata.txt';
input @1 Name $ 14.
	  @16 Acct $ 5.
	  @21 Balance 6.
	  @27 Rate 4.; *formatted input;
Interest=(Balance*Rate); *calculating the interest based on the balance & rate;
run;

proc print data=Bank;
run;

*Question 8.14;

data assign1.table;   
do Integer=1 to 100 until (Square gt 100); *repeat the loop for integer 1 to 100 until the square is greater than 100;
	Square=Integer*Integer; *operation to square an integer;
	output;
end;	
run;

title "Table of integers & squares";
proc print data=assign1.table;
run;


*Question 9.12;

data assign1.q9_12;
set assign1.Medical;
FollowDate= intnx('week',VisitDate, 5, 'sameday'); *finding the exact date 5 weeks from the visit date on the same day;
format VisitDate FollowDate date9.;
run;

title "5 weeks after the visit date";
proc print data=assign1.q9_12;
run;

*Question 10.10;

*we must sort both datasets by the common variable,Model, before match merging;
proc sort data=Assign1.Purchase out=Purchase;
by Model;
run; 

proc sort data=Assign1.Inventory out=Inventory;
by Model;
run; 

data Assign1.notPurchased;
merge 
	Purchase(in=Purchase)
	Inventory(in=Inventory);
by Model;
if Purchase=0 and Inventory=1; *filter out the observations that were not purchased but appear in Inventory;
keep Model Price; *retain only the model & the price;
run;

title "Models that were not purchased";
proc print data=Assign1.notPurchased;
run;
