*
code for objective 1
;

* Read in all files, skipping headers;

filename assn "~/stat6430_sasproj/data/Assignments.csv";
data assign;
infile assn dsd firstobs=2;
input Consultant $ ProjNum;
run;

filename corr "~/stat6430_sasproj/data/Corrections.csv";
data corrections;
infile corr dsd firstobs=2;
retain projnum;
length date $10;
input ProjNum Date $ Hours Stage;
run;

filename mstr "~/stat6430_sasproj/data/Master.csv";
data master;
infile mstr dsd firstobs=2;
retain Consultant ProjNum;
length date $10;
input Consultant $ ProjNum Date $ Hours Stage Complete;
run;

filename newf "~/stat6430_sasproj/data/NewForms.csv";
data newfiles;
infile newf dsd firstobs=2;
retain ProjNum;
length date $10;
input ProjNum Date $ Hours Stage Complete;
run;

filename pjc "~/stat6430_sasproj/data/ProjClass.csv";
data projclass;
infile pjc dsd firstobs=2;
length Type $20;
input Type $ ProjNum;
run;

* Review imported raw files;

proc contents data = assign;
run;

proc freq data=assign;
run;

proc freq data=corrections;
run;

proc freq data=master;
run;

proc freq data=newfiles;
run;

proc freq data=projclass;
run;

* Join the files;

* First, stack the master file with the new files;
data newmaster;
set master newfiles;
run;

proc sort data = newmaster;
by projnum;
run;

proc sort data = projclass;
by projnum;
run;

/*
* This block checks the merge between master and projclass; 
data newmaster one two;
merge newmaster(in=in1) projclass(in=in2);
by projnum;
if in1 and in2 then output newmaster;
else if in1 then output one;
else output two;
run;
*/

* Merge in projclass;
data newmaster1b;
merge newmaster projclass;
by projnum;
run;

* Consolidate rows in corrections file before merging;

proc sort data = corrections;
by projnum date;
run;

data corrections2;
set corrections;
by projnum date;
retain hours2 stage2;
if first.date then hours2 = hours;
if last.date then output;
run;

data corrections2 (drop=hours2);
set corrections2;
hours = hours2;
run;

* Add corrections to newmaster;

proc sort data = newmaster1b;
by projnum date;
run;

proc sort data = corrections2;
by projnum date;
run;

data newmaster2;
merge newmaster1b (rename=(hours=hours_old stage=stage_old)) corrections2;
by projnum date;
run;

data newmaster3;
set newmaster2;
if missing(hours) then do;
	hours = hours_old;
	corrected = 0;
	end;
else corrected = 1;
if missing(stage) then do;
	stage = stage_old;
	end;
else corrected = 1;
drop hours_old stage_old;
run;

* Add in missing values for Consultant variable from Assignments;

proc sort data = newmaster3;
by projnum;
run;

proc sort data = assign;
by projnum;
run;

data newmaster4;
merge newmaster3 (rename=(consultant=consultant_old)) assign;
by projnum;
run;

* note that some rows still do not have a consultant assigned after this step;
data newmaster5;
set newmaster4;
if not missing(consultant_old) and missing(consultant) then 
	consultant_new = consultant_old;
else if missing(consultant_old) and not missing(consultant) then 
	consultant_new = consultant;
consultant = consultant_new;
drop consultant_new consultant_old;
run;

* Check business logic of project completion;
data good bad ugly;
set newmaster5;
if (stage >= 4 and complete = 1) or (stage < 4 and complete = 0) then output good; * these are valid;
if stage < 4 and complete = 1 then output bad; * these are invalid;
if stage >= 4 and complete = 0 then output ugly; * these aren't necessarily wrong, but need checking;
run;

data good_miss;
set good;
if missing(stage) then output;
run;

* projects with missing stages:
439, 452, 458, 464, 473, 489, 496
;

data test2;
set good;
if projnum in (439, 452, 458, 464, 489, 496, 473) then output;
run;

proc sort data = test2;
by projnum date;
run;

* Fill in missing 'stage' value with logically sound assumptions where possible.
Here we only assume that missing values can be filled in, we assume that non-missing
values are correct.
;

data newmaster6;
set newmaster5;
if projnum = 439 and date =	'5/27/2010' then stage = 3;
if projnum = 439 and date in ('6/7/2010','6/8/2010') then stage = 3;
if projnum = 452 and date = '7/2/2010' then stage = 3;
if projnum = 464 and date = '7/26/2010' then stage = 2;
if projnum = 489 and date = '9/13/2010' then stage = 3;
if projnum = 496 and date = '9/27/2010' then stage = 3;
if projnum = 473 and date = '8/11/2010' then stage = 4;
run;

* look into missing consultants;

data test3;
set newmaster6;
if missing(consultant) then output;
run;

proc freq data = test3;
table projnum;
run;

data test4;
set newmaster6;
if projnum in (458
,470
,481
,482
,485
,486
,488
,489
,490
,496
,498
,499
,501
,504
,505
,507
,509
,513) then output;
run;

proc freq data = test4;
table projnum*consultant / nocol nocum nopercent nofreq;
run;

* fill in missing consultant names;

data newmaster7;
set newmaster6;
if projnum in (470, 481, 482, 496, 505, 507, 513) and missing(consultant) then consultant = "Jones";
if projnum in (488, 490, 498) and missing(consultant) then consultant = "Smith";
if projnum in (458, 485, 486, 489, 499, 501, 504, 509) and missing(consultant) then consultant = "Brown";
run;

* format date as date;
data newmaster8;
set newmaster7;
newdate = date;
run;

data newmaster9;
set newmaster8 (drop=date);
date = input(newdate, MMDDYY10.);
format date date9.;
run;


* write data out to csv;

filename out "~/stat6430_sasproj/data/newmaster.csv";
data _NULL_;
set newmaster9 (drop=newdate);
file out dsd;
put Consultant ~ projnum date complete type ~ hours stage corrected;
run;

* create permanent sas file;

libname sasproj "~/stat6430_sasproj/data";

data sasproj.newmaster;
set newmaster9 (drop=newdate);
run;




*
code for objective 2
;

libname sasproj "~/stat6430_sasproj/data";

ods pdf file="~/stat6430_sasproj/all_reports_group27.pdf";

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




*objective 3;

* Consultant 1 - Smith;

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

title 'Analytical Consulting Lab';
title2 'Progress Report as of Nov 4th 2010' ;
title3 'Consultant: Smith';

proc print data=check (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;

* Consultant 2 - Brown  ;


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

title 'Analytical Consulting Lab';
title2 'Progress Report as of Nov 4th 2010' ;
title3 'Consultant: Brown';

proc print data=checkbrown (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;


* Consultant 2 - Jones  ;


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

title 'Analytical Consulting Lab';
title2 'Progress Report as of Nov 4th 2010' ;
title3 'Consultant: Jones';

proc print data=checkjones (where=(_type_=3)) noobs  label;
var projnum startdate lastdate total_hours completed ;
label projnum='Project Number' startdate='Start Date' lastdate='Last Date' total_hours='Total Hours' completed='Completed' ;
run;



*
code for objective 4
;

ods escapechar='^';

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

data misshr;
set newmaster (where=(missing(hours) or missing(stage)));
keep projnum consultant hours stage date complete;
run;

title2 'Bad Data Report: Missing Field(Hours)';
proc print data = misshr (where=(missing(hours)));
run;

ods startpage=no;

* Used pdf text here instead of title since title only works once per page of output;
ods pdf text = "^{style [just=center font=(Arial) fontsize=11pt fontweight=bold] Bad Data Report: Missing Field(Stage)}";

proc print data = misshr (where=(missing(stage)));
run;

ods pdf text="^{style [just=center font=(Arial)] Note: Missing data that could be inferred from non-missing data was imputed 
during data cleaning. Missing data that could not be inferred is presented here so that 
it can be added by the relevant consultants at a later date.}";

ods startpage=yes;

* Another report: distribution of project hours;

proc means data = newmaster noprint;
class projnum;
var hours;
output out=projhrs sum(hours)=tot_hrs max(complete)=projcomplete;
run;

title2 'Trend in Project Effort over Time';
/*
proc reg data = projhrs (where=(_type_ = 1 and projcomplete = 1))
	plots(only)=(fitplot);
model tot_hrs = projnum;
run;
*/

proc sgplot data=projhrs (where=(_type_ = 1 and projcomplete = 1));
reg x=projnum y=tot_hrs;
xaxis label = "Project Number";
yaxis label = "Total Hours";
run;

ods pdf close;

