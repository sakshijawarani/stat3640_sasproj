*
code for objective 2
;

libname sasproj "~/stat6430_proj/data";

*ods pdf file="~/stat6430_proj/obj2_report.pdf";

data newmaster;
set sasproj.newmaster; * (where = (date >= ''));
run;

data test;
set newmaster;
newdate = input(date, MMDDYY10.);
run; 

proc 
run;
quit;

ods pdf close;