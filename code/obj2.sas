*
code for objective 2,3
;

libname sasproj "~/stat6430_sasproj/data";

ods pdf file="~/stat6430_sasproj/obj2_report.pdf";

title 'Analytical Consulting Lab';
title2 'Progress Reports';
title3 'Ongoing Projects as of Nov 4, 2010';

data newmaster;
set sasproj.newmaster (where = (complete = 0));
run;

/*
proc freq data = newmaster;
table projnum / nofreq nocol nopercent nocum;
run;
*/

proc print data=newmaster noobs label;
var projnum;
label projnum='Project Number';
run;

ods pdf close;

