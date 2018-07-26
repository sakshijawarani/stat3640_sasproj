*
code for objective 1
;

libname sasproj "~/stat6430_sasproj/data";

* Create stalled project report including projects
that have not been updated for at least one month
that are not completed.;

title 'Analytical Consulting Lab';

data newmaster;
set sasproj.newmaster;
run;


* Report on the number of hours worked per employee;

data monthly;
set newmaster;
yr = year(date);
mo = month(date);
run;

title2 'Consultant Productivity';
title3 'Hours Logged by Month';

proc sgplot data = monthly; 
vbar mo / group=consultant stat=sum response=hours groupdisplay=cluster;
xaxis label = 'Month';* values=("01NOV2010"d to "01NOV2010"d by month);
yaxis label = 'Hours Logged';
yaxis display=(noline noticks) grid;
run;

* Another report: rows with missing hour counts;

data misshr;
set newmaster (where=(missing(hours)));
keep projnum consultant hours date complete;
run;

title2 'Bad Data Report: Missing Field(Hours)';
proc print data = misshr;
run;

* Another report: distribution of project hours;

proc means data = newmaster noprint;
class projnum;
var hours;
output out=projhrs sum(hours)=tot_hrs max(complete)=projcomplete;
run;

title2 'Trend in Project Effort over Time';
proc reg data = projhrs (where=(_type_ = 1 and projcomplete = 1))
	plots(only)=(fitplot) ;
model tot_hrs = projnum;
run;

/*
proc univariate data = projhrs (where=(_type_ = 1));
var tot_hrs;
histogram tot_hrs;
run;

proc sgplot data = projhrs (where=(_type_ = 1));
histogram tot_hrs;
run;
*/

