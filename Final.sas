/* 1. Import the data to SAS. */

%web_drop_table(WORK.NBAData);
FILENAME REFFILE '/home/u63048800/Exam02DataForPost.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=WORK.NBAData;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.NBAData;
RUN;

%web_open_table(WORK.NBAData);

/*2. Fit a multiple linear regression model using Wins (W) as the dependent variable and other variables (except team names) as predictors */
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.NBAData outdesign(addinputvars)=Work.reg_design;
	class Season Conference / param=glm;
	model W=Age SOS ORtg Pace FTr '3PAr'n 'eFG%'n 'TOV%'n 'ORB%'n 'FT/FGA'n 
		'OppeFG%'n 'OppTOV%'n 'DRB%'n 'OppFT/FGA'n Season Conference / showpvalues 
		selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Season is not missing and Conference is not missing;
	ods select ParameterEstimates DiagnosticsPanel ResidualPlot 
		ObservedByPredicted;
	model W=&_GLSMOD / vif;
	run;
quit;

proc delete data=Work.reg_design;
run;

/* 3. Fit a regression model using the stepwise selection procedure using Mallow’s C(p) as the selection criterion. */
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.NBAData outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	class Season Conference / param=glm;
	model W=Age SOS ORtg Pace FTr '3PAr'n 'eFG%'n 'TOV%'n 'ORB%'n 'FT/FGA'n 
		'OppeFG%'n 'OppTOV%'n 'DRB%'n 'OppFT/FGA'n Season Conference / showpvalues 
		selection=stepwise
   
   (select=cp);
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Season is not missing and Conference is not missing;
	ods select ParameterEstimates DiagnosticsPanel ResidualPlot 
		ObservedByPredicted;
	model W=&_GLSMOD / vif;
	run;
quit;

proc delete data=Work.reg_design;
run;