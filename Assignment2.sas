/*
Assignment No.2
*/

LIBNAME assign2 'C:\445_695\Course_data';

*Question 1;
*The pdf files for the quiz results are uploaded along with this SAS file;

*Question 2;
*Before proceeding, put the files test.csv & train.csv in a separate folder. The path should be C:\445_695\bonus;

proc format;
value surv 0 = 'No'
			1= 'Yes';
value pcl	1 = '1st'
			2 = '2nd'
			3 = '3rd';
value $emb	'C' = 'Cherbourg'
			'Q' = 'Queenstown'
			'S' = 'Southampton';
run;



data train;
infile 'C:\445_695\bonus\train.csv' dsd firstobs=2;
input 	PassengerId	
		Survived	
		Pclass	
		Name	:$100.
		Sex	 $
		Age	
		SibSp	
		Parch	
		Ticket	:$20.
		Fare	
		Cabin	$	
		Embarked $;
format Embarked $emb.
		Pclass pcl.
		Survived surv.;
run;

title "Output for the train dataset";
proc print data= train; 
run;

data test;
infile 'C:\445_695\bonus\test.csv' dsd firstobs=2 ; 

input 	PassengerId 
		Pclass 				
		Name : $100.		
		Sex $ 		
		Age 
		SibSp 
		Parch 
		Ticket: $20. 
		Fare 
		Cabin $ 
		Embarked $;
format Embarked $emb.
		Pclass pcl.;
run;
title "Output for the test dataset";
proc print data = test;
run;

/*
data gender;
infile 'C:\445_695\gender_submission.csv' dsd firstobs=2;
input 	PassengerId	
		Survived	;
format Survived surv.;
run;

data test2;
merge test gender;
by PassengerId; 
run; 

proc print data = test2; 
run;
*/

data combinedset;
set train test;
run; 
 
title "Combining the test & train dataset";
proc print data = combinedset; 
run;

*Question 2 a);
proc freq data = combinedset;
tables survived*(Pclass sex);
run;
/*Based on Ticket Class, we see that First Class passengers have the highest chance
of survival (62.96%) which is almost three times higher than Third Class passengers
(only 24.24%). First class passengers have the highest chance of survival, followed
by 2nd class and then 3rd class. 
Therefore we can say being in First Class gives a higher chance of survival.
Based on sex, we see that female passengers have a considerably higher chance
of survival compared to male (74.20% compared to 18.89) 
This makes sense since it is a unwritten rule that females are prioritized for 
safety in case of emergency*/

*Question 2 b);
*LIFT = Prob(Survived and Ticket Class A)/(Prob(TicketClassA)*Prob(Survived))
 LIFT for Class 1 = 0.1526/((0.2424)*(0.3838)) = 1.6403
 LIFT for Class 2 = 0.0976/((0.2065)*(0.3838)) = 1.2315
 LIFT for Class 3 = 0.1336/((0.5511)*(0.3838)) = 0.6316
;

*Lift is a ratio of probabilities (meaning that LIFT is not itself a probability) 
 and can be interpretted as a way to measure which class has better chances of survival.
 Since the equation is Prob(Survived|A)/Prob(Survived), there will only be variations in the numerator.
 Thus, a higher number for LIFT will indicate a higher value of Prob(Survived|A).
 Hence, a higher number means that the there is a better chance of survival given that ticket class.
;

*Ticket Class 2 has a 94.98% better chance of survival compared to Class 3. Class 1 has a 33.19% better
 chance of survival compared to class 2. Class 1 has a 159.7% better chance of survival compared tp class
 3.
;

*Question 2 c);
proc freq data= combinedset nlevels ;
tables survived*(pclass sex) / missprint ;
run;
/*NLEVELs gives us the information of many variables at once, 
including missing or duplicated values.

MISSPRINT can be added to PROC FREQ in order to display the frequencies of missing values . 
However, it will not include these in computation of percentage or statistics 

MISSING: can also be added to PROC FREQ to consider missing values as valid nonmissing levels. 
It also displays these values in the tables and include them in computations and statistics*/

proc freq data= combinedset nlevels ;
tables survived*(pclass sex) / missing ;
run;



*Question 2 (d);
proc univariate data= combinedset;
	var age survived;
	histogram age;
	run;



*The histogram seems to follow somewhat of a normal distribution
with the exception of a sharp drop off when the age group was below 12 years old.
The distribution is not symmetric due to the sharp drop off in percentage under age 12.
This coincides with the problem since we would expect a smaller percentage of young children to
survive compared to the othter groups. We would also expect a continuously decreasing percentage
as the passengers became older. Which is what we obtain.;

*Question 2 (e);

*
The max value is age 80 and the min value is age 0.42. The mean is 29.88114 while the median is 28. There are 264 missing values.
;

*Question 3 (f);

proc format;
value age low-<21= 'Q1'
		21 -< 28 = 'Q2'
		28-<39 ='Q3'
		39-81 = 'Q4'
		;
		run;

proc freq data= combinedset  ;
tables survived*age ;
format age age.;

run;

*The results indicate that Q3 had the greatest number of survivors. Which is the followed in order by  Q1,Q4,Q2.
 The group that had the greatest chances of survival was Q1 and the group with the worst chances are Q4.

;


*Question 11-4;
*a);
data Evaluate; *creates a temporary data set called Evaluate;
set assign2.Psych;
if n(of Ques1-Ques10) >= 7 then 
	QuesAve=mean(of Ques1-Ques10); *the number of nonmissing variables must be greater or equal to 7 in order to compute QuesAve;
run;

title "Evaluating the Scores (QuesAve)";
proc print data=Evaluate;
run;

*b);
data Evaluate;
set assign2.Psych;
if n(of Ques1-Ques10) >= 7 then
	QuesAve=mean(of Ques1-Ques10); *the number of nonmissing variables must be greater or equal to 7 in order to compute QuesAve;
if cmiss(of Score1-Score5) = 0 then do 
	MinScore=min(of Score1-Score5);
	MaxScore=max(of Score1-Score5);
	SecondHighest=largest(2, of Score1-Score5); *the number of missing variables must be 0 in order to compute the minimum, maximum & 2nd largest scores;
end;
run;

title "Evaluating the Scores (MinScore, MaxScore, SecondHighest)";
proc print data=Evaluate;
run;

*Question 12.6;

*Without using the CAT function;
data Study; *creates a new temporary data set called Study;
set Assign2.Study;
length GroupDose $ 6; *the length of GroupDose must be  6 bytes;
GroupDose=trim(Group)||'-'||Dose; *trim function removes any trailing blanks from Group before concatenating with Dose ;
run;

title "Listing of temporary dataset Study";
proc print data=Study;
var Group Dose GroupDose;
run;

*proc contents data=Study;
*run;

*Using the CAT function;
data Study; *creates a new temporary data set called Study;
set Assign2.Study;
length GroupDose $ 6; *specify the length of the resulting variable;
GroupDose=catx('-',Group,Dose); *with catx, you can specify a separator before concatenating Group & Dose;
run;

proc print data=Study;
var Group Dose GroupDose;
run;


*Question 13.4;

proc contents data=Assign2.Survey2;
run;

data anyFive;*creates a temporary dataset named anyFive;
set Assign2.Survey2;
length Any5 $ 3;        *store a value large enough to contain both 'Yes' & 'No' strings;
array myvars{5} Q1-Q5;  *instantiate an array of 5 elements for Question 1 to 5;
Any5='No';              *the default value of Any5 is 'No';
do i=1 to 5;            *loop through each element of the array;
	if myvars{i}=5 then Any5='Yes'; *if the answer is 5 for a question, then Any5 becomes Yes;
end;
drop i; *drops the do loop counter;
run;

title "Listing of the anyFive dataset";
proc print data=anyFive;
run;

*Question 14.2;
proc sort data=Assign2.Sales out=Sales;
	by Region; *sort the Assign2.Sales dataset by Region into a new temporary data set Work.Sales;
run;

title 'Sale Figures from the SALES Data Set';
proc print data=Sales split='*' label noobs; *split was added to have the word Sales on another line from Total;
by Region; *group the observations by Region;
id Region; *set Region as the identifying variable;
var Quantity TotalSales; *keep the Quantity & TotalSales;
label Region="Region"
	  TotalSales="Total*Sales"
	  Quantity="Quantity";
sum Quantity TotalSales; *adding total & subtotals for Quantity & TotalSales;
run;

*Question 16.6;

proc means data=Assign2.College;
class SchoolSize; *for each value of SchoolSize;
var ClassRank GPA;
output out=Class_Summary
	   n=
	   mean= 
	   median= /autoname  ; *creates a summary dataset called Class_Summary containing n,mean & median for the variables specified in the VAR statement;
run; *the variables are named with the AUTONAME option;

title "Class Summary";
proc print data=Class_Summary noobs;
run;

*Question 18.4;
proc format; *formats the labels appearing in the table;
value rank low-70= 'Low to 70'
		   71-high='71 and higher';
value $gender 'F'='Female'
			  'M'='Male';
value $scholarship 'Y'='Yes'
				   'N'='No';
run; 

title "Demographics from COLLEGE Data Set";
proc tabulate data=Assign2.College format=6.; *creates a tabular report for the COLLEGE dataset ;
class Scholarship ClassRank Gender; *these variables appear in the table;
table Scholarship ALL, ClassRank*(Gender ALL); *Scholarship is displayed as rows & ClassRank and Gender as columns. Gender is nested within ClassRank;
format ClassRank rank. Gender $gender. Scholarship $scholarship.; *the user-defined formats are applied here;
keylabel ALL='Total'; *renames the keyword ALL to Total;
run;
