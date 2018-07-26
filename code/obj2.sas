*
code for objective 2
;

libname sasproj "~/stat6430_sasproj/data";

ods pdf file="~/stat6430_sasproj/obj2_report.pdf";

title 'Analytical Consulting Lab';
title2 'Progress Reports';
title3 'Ongoing Projects as of Nov 4, 2010';

data newmaster;
set sasproj.newmaster (where = (date <= '4NOV2010'd));
run;

proc means data = newmaster noprint;
class projnum;
var complete;
output out=ongoing1 max(complete)=complete;
run;

data ongoing2;
set ongoing1 (where = ((complete = 0) and (_type_ ^= 0)));
run;

proc print data=ongoing2 noobs label;
var projnum;
label projnum='Project Number';
run;

ods pdf close;

