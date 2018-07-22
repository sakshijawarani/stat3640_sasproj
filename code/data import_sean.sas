*
code for objective 1
;

* Read in all files, skipping headers;

filename assn "~/stat3640_sasproj/data/Assignments.csv";
data assign;
infile assn dsd firstobs=2;
input Consultant $ ProjNum;
run;

filename corr "~/stat3640_sasproj/data/Corrections.csv";
data corrections;
infile corr dsd firstobs=2;
retain projnum;
length date $10;
input ProjNum Date $ Hours Stage;
run;

filename mstr "~/stat3640_sasproj/data/Master.csv";
data master;
infile mstr dsd firstobs=2;
retain Consultant ProjNum;
length date $10;
input Consultant $ ProjNum Date $ Hours Stage Complete;
run;

filename newf "~/stat3640_sasproj/data/NewForms.csv";
data newfiles;
infile newf dsd firstobs=2;
retain ProjNum;
length date $10;
input ProjNum Date $ Hours Stage Complete;
run;

filename pjc "~/stat3640_sasproj/data/ProjClass.csv";
data projclass;
infile pjc dsd firstobs=2;
length Type $20;
input Type $ ProjNum;
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
data newmaster;
merge newmaster projclass;
by projnum;
run;

* Add corrections to newmaster;

proc sort data = newmaster;
by projnum date;
run;

proc sort data = corrections;
by projnum date;
run;

data newmaster2;
merge newmaster (rename=(hours=hours_old stage=stage_old)) corrections;
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

* write data out to csv;

filename out "~/stat3640_sasproj/data/newmaster.csv";
data _NULL_;
set newmaster5;
file out dsd;
put Consultant ~ projnum date complete type ~ hours stage corrected;
run;

* create permanent sas file;

libname sasproj "~/stat3640_sasproj/data";

data sasproj.newmaster;
set newmaster5;
run;