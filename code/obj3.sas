
*objective 3;

* Consultant 1 - Smith;

ods pdf file="~/stat6430_sasproj/obj3_smith_report.pdf";

data smith;
set sasproj.newmaster (where = (consultant = 'Smith'));
by projnum;
run;

proc sort data = smith;
by projnum date;
run;

data smith2;
set smith ;
by projnum ;
if first.projnum then start_date=date ;
if last.projnum then last_date=date ;
format start_date last_date date9. ;
run;

proc means data=smith2 noprint;
class projnum type;
var projnum start_date last_date hours complete ; 
output out=check mean(projnum)=ProjectNumber max(start_date)=startdate max(last_date)=lastdate
sum(hours)=total_hours max(complete)=completed;
run;

title 'Progress Report as of Nov 4th 2010' ;
title2 'Consultant: Smith';

proc print data=check (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;

ods pdf close;

* Consultant 2 - Brown  ;

ods pdf file="~/stat6430_sasproj/obj3_brown_report.pdf";

data brown;
set sasproj.newmaster (where = (consultant = 'Brown')) ;
by projnum;
run;

proc sort data = brown;
by projnum date;
run;

data brown2;
set brown ;
by projnum ;
if first.projnum then start_date=date ;
if last.projnum then last_date=date ;
format start_date last_date date9. ;
run;

proc means data=brown2 noprint;
class projnum type;
var projnum start_date last_date hours complete ; 
output out=checkbrown mean(projnum)=ProjectNumber max(start_date)=startdate max(last_date)=lastdate
sum(hours)=total_hours max(complete)=completed;
run;

title 'Progress Report as of Nov 4th 2010' ;
title2 'Consultant: Brown';

proc print data=checkbrown (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;

ods pdf close;

* Consultant 2 - Jones  ;

ods pdf file="~/stat6430_sasproj/obj3_jones_report.pdf";

data jones;
set sasproj.newmaster (where = (consultant = 'Jones')) ;
by projnum;
run;

proc sort data = jones;
by projnum date;
run;

data jones2;
set jones ;
by projnum ;
if first.projnum then start_date=date ;
if last.projnum then last_date=date ;
format start_date last_date date9. ;
run;

proc means data=jones2 noprint;
class projnum type;
var projnum start_date last_date hours complete ; 
output out=checkjones mean(projnum)=ProjectNumber max(start_date)=startdate max(last_date)=lastdate
sum(hours)=total_hours max(complete)=completed;
run;

title 'Progress Report as of Nov 4th 2010' ;
title2 'Consultant: Jones';

proc print data=checkjones (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;

ods pdf close;