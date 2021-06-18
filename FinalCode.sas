							/*importing the data*/
FILENAME CSV "/home/u43000082/SAS Final Project/MyProject.csv" TERMSTR=CRLF;


PROC IMPORT DATAFILE=CSV
		    OUT=MyProject
		    DBMS=CSV
		    REPLACE;
RUN;

							/*Data Cleaning and Data Manipulation*/
							/* 1) The data has 50 columns and 101766 rows */
PROC contents data=MyProject;
RUN;

							/*Changing the type of variables as approriate*/
				/*changing the char length of below features*/
				
/*Changing the character length*/
Data MyProject;
Length acetohexamide $ 100 troglitazone $ 100 medicalspecialty $ 100 age $10 change $10 diabetesMed $14 diag1 $20 gender $14
insulin $14 race $19 readmitted $20;
set MyProject;
length readmitted $20;
run;							

							/* Lets find out data distribution of Weight column*/
proc sql;
  create table weight as
  select  weight,count(*) as COUNT
  from  MyProject
  group by weight;  
quit;
run;
					/* There is no data in weight column So we will drop this columns */

proc sql;
SELECT weight,COUNT(weight) as weightgroup FROM MyProject GROUP BY weight;
quit;
run;

data MyProject(drop=weight);
   set MyProject; 
run;


					/* Update the rows with payer_code='?' as payer_code ='NO DATA'*/
proc sql;
	update  MyProject
	set payercode = 'NO DATA'
	where payercode ='?';
run;

					/* Lets find out data distribution of payer_code column*/
proc sql;
  create table payercode as
  select  payercode,count(*) as COUNT
  from  MyProject
  group by payercode;  
quit;
run;
 
					/* There is no direct relation of payer code column with readmission and hence removed */

data MyProject(drop=payercode);
   set MyProject; 
run;


				/*There are rows with values "?" in "medical_specialty" column.  
				Updating the rows with medical_speciality="NO DATA"*/
				
proc sql;
	update  MyProject
	set medicalspecialty = 'NO DATA'
	where medicalspecialty ='?';
run;				


proc sql;
  create table medicalspecialty as
  select  medicalspecialty,count(*) as COUNT
  from  MyProject
  group by medicalspecialty;  
quit;
run;


				/* There is no direct relation of encounterid column with readmission and hence removed */

data MyProject(drop=encounterid);
   set MyProject; 
run;





				/*The below dropped features are represented in 'diabetesMed' feature and hence removed*/

data MyProject;
   set MyProject;
   drop 
    metformin repaglinide 
    nateglinide chlorpropamide glimepiride acetohexamide glipizide glyburide  
    tolbutamide	pioglitazone rosiglitazone acarbose	miglitol  
    troglitazone tolazamide examide citoglipton	glyburidemetformin 
   glipizidemetformin glimepiridepioglitazone metforminrosiglitazone metforminpioglitazone 
;
run;


			/*very few rows in Gender have value as Unknown, its a good idea to delete these rows.*/
proc sql;
   delete from MyProject where gender='Unknow';
run;



				/* Bucketing the age group into 3 groups-Young,Adult,Old Age -this can be help in predicting the readmission rate 
							as pet the 3 age groups instead of 10 age groups*/

										/*Before age bucketing*/
PROC SQL;
SELECT age,COUNT(age) FROM MyProject GROUP BY  age;
QUIT;
RUN;


/*Age bucketing*/
proc sql;
update MyProject 
set age = 'Young' 
	where age = '[0-10)';
quit;

proc sql;
update MyProject 
set age = 'Young' 
	where age = '[10-20)';
quit;

proc sql;
update MyProject 
set age = 'Adult' 
	where age = '[20-30)';
quit;

proc sql;
update MyProject 
set age = 'Adult' 
	where age = '[30-40)';

quit;

proc sql;
update MyProject 
set age = 'Adult' 
	where age = '[40-50)';
quit;

proc sql;
update MyProject 
set age = 'Adult' 
	where age = '[50-60)';
quit;

proc sql;
update MyProject 
set age = 'Old' 
	where age = '[60-70)';
quit;

proc sql;
update MyProject 
set age = 'Old' 
	where age = '[70-80)';
quit;

proc sql;
update MyProject 
set age = 'Old' 
	where age = '[80-90)';
quit;

proc sql;
update MyProject 
set age = 'Old' 
	where age = '[90-100)';
quit;


										/*After age bucketing*/
PROC SQL;
SELECT age,COUNT(age) AS agegroups FROM MyProject GROUP BY  age;
QUIT;
RUN;


										/*Race-Missing values in the feature has been replaced with 'Nodata' */

proc sql;
SELECT race,COUNT(race) as racegroup FROM MyProject GROUP BY race;
quit;
run;

proc sql;
	update  MyProject
	set race = 'NoData'
	where race ='?';
run;

									/* Check after updating race variable */
proc sql;
SELECT race,COUNT(race) as racegroup FROM MyProject GROUP BY race;
quit;
run;

			/*Some rows in race have value as blank, its a good idea to delete these rows.*/
proc sql;
   delete from MyProject where race=' ';
run;


	/*Secondary dignosis and Additional secondary diagnosis are not not directly related to readmission rate */
	
	
data MyProject(drop=diag2);
   set MyProject; 
run;

data MyProject(drop=diag3);
   set MyProject; 
run;

			/*This feature is the glucose serum test and more than 80% patients are not tested and do not have results*/
data MyProject(drop=maxgluserum);
   set MyProject; 
run;

proc print data=MyProject;
run;


				/*Descriptive Analysis*/		
						
proc means data=MyProject;
run;	

PROC UNIVARIATE DATA=MyProject;
RUN; 					


    
                                /*Decriptive statistics of Numeric features*/
proc means Data=MyProject maxdec=2 n nmiss mean stderr median Min Max ;
Title 'Descriptive statistics';
run;



                                /*identify char,change length,give statitics*/
            /*For character variables, we can use proc freq to display the number of missing values in each variable.*/


proc freq data = MyProject;
  tables medicalspecialty age change diabetesMed diag1  gender
insulin  race readmitted ;
run;





						/*STATISTICAL TEST-Talk about statistical test at this point*/
						
									/*DATA VISUALIZATIONS*/
	/* 1. By Gender */
title'Distribution of Diabetics patient by Gender ';
Proc SGPLOT data=MyProject;
vbar gender/  stat=mean
			group=readmitted groupdisplay=stack
			 barwidth=0.5
           categoryorder= respdesc
           ; 
where gender='Male' or gender='Female';
run;

/* 2. By Race */
title'Distribution of Diabetics patient by RACE';
Proc SGPLOT data=MyProject;
vbar race/  stat=mean 
			group=readmitted groupdisplay=stack
			 barwidth=0.5
           categoryorder= respdesc
           ; 
run;

 
/* 3. By Age group */
title'Distribution of Diabetics patient by Age';
Proc SGPLOT data=MyProject;
vbar age/ stat=mean 
			group=readmitted groupdisplay=stack
			barwidth=0.5
           categoryorder= respdesc
           ; 
run;

/* 4. By Number of Days Patient Spent in Hospital*/
title'Distribution of Number of Days Patient Spent in Hospital';
Proc SGPLOT data=MyProject;
vbar timeinhospital/ stat=mean 
             group=readmitted groupdisplay=stack
			barwidth=0.5
          
          ; 
run;
								
		
	
	
/* 5. By Diabetes Med in Hospital*/
title'Distribution of Diabetes Med in Hospital';
Proc SGPLOT data=MyProject;
vbar diabetesMed/ stat=mean 
             group=readmitted groupdisplay=stack
			barwidth=0.5
          
          ; 
run;



/* 6. By Readmission in Hospital*/
title'Distribution of Readmitted in Hospital';
Proc SGPLOT data=MyProject;
vbar readmitted/ stat=mean 
             groupdisplay=stack
			barwidth=0.5
          
          ; 
run;


			/*HISTOGRAM*/
PROC UNIVARIATE DATA = MyProject;
HISTOGRAM  numlabprocedures nummedications timeinhospital  numberoutpatient numberinpatient numberofdiagnoses / normal;
RUN;

            /*CORRELATION CHECK*/
	
proc corr data=MyProject;
var patientnbr admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient  
					numprocedures nummedications  
					numberofdiagnoses  ;
title 'Diabetics Readmission Classification-Correlation';
run;
			
proc reg data=MyProject;
model readmitted =timeinhospital;
run;
								/*EXPLORATORY DATA ANALYSIS*/
			


									/* DATA MANIPULATION */

				/*Medical Speciality feature reduced to 2 value based on whther the medical speciality is
           	 		related to diabetics*/
           	 	
  
proc sql;
  update MyProject 
  set medicalspecialty=case when medicalspecialty in ('Family/GeneralPractice','Endocrinology','Podiatry',
  'Dentistry','Endocrinology-Metabolism','Ophthalmology') then '1'
  								else '0' end;
quit;


								/*Updating values of "race" column from No, Ch to 0,1 respectively*/
								
proc sql;
  update MyProject 
  set race=case when race in ('NoData','Other') then '0'
               when race in ('Caucasian','Hispanic') then '1'
               else '2' end;     
quit;	


						/*A1c result has 4 groups patient encounters  */
						
proc sql;
	update  MyProject
	set A1Cresult = '0'
	where A1Cresult ='None';
run;

proc sql;
	update  MyProject
	set A1Cresult = '1'
	where A1Cresult ='Norm';
run;

proc sql;
	update  MyProject
	set A1Cresult = '2'
	where A1Cresult ='>7';
run;

proc sql;
	update  MyProject
	set A1Cresult = '4'
	where A1Cresult ='>8';
run;

					/*Updating values of "gender" column from No, Ch to 0,1 respectively*/

proc sql;
	update  MyProject
	set gender = '1'
	where gender ='Male';
run;

proc sql;
	update  MyProject
	set gender = '0'
	where gender ='Female';
run;
							
						
						/*Target Variable-readmitted, the categories are not ideal*/


proc sql;
	update  MyProject
	set readmitted = '0'
	where readmitted ='NO';
run;

proc sql;
	update  MyProject
	set readmitted = '1'
	where readmitted ='YE';
run;

 proc sql;
  create table readmitted as
  select  readmitted,count(*) as COUNT
  from  MyProject
  group by readmitted;  
quit;
run;

					/*Updating values of "change" column from No, Ch to 0,1 respectively*/
proc sql;
	update  MyProject
	set change = '1'
	where change ='Ch';
run;

proc sql;
	update  MyProject
	set change = '0'
	where change ='No';
run;

					/*Updating values of "diabetesMed" column from No, Yes to 0,1 respectively*/
proc sql;
	update  MyProject
	set diabetesMed = '1'
	where diabetesMed ='Yes';
run;

proc sql;
	update  MyProject
	set diabetesMed = '0'
	where diabetesMed ='No';
run;

					/*Updating values of "insulin" column from No, Up,Down,Normal to 0,1,2,3 respectively*/
proc sql;
	update  MyProject
	set insulin = '1'
	where insulin ='Up';
run;

proc sql;
	update  MyProject
	set insulin = '0'
	where insulin ='No';
run;

proc sql;
	update  MyProject
	set insulin = '2'
	where insulin ='Down';
run;

proc sql;
	update  MyProject
	set insulin = '3'
	where insulin ='Steady';
run;
                       /*Updating values of "diag1" column from otherdisease, diabeticsmellitus to 0,1 respectively*/

proc sql;
	update  MyProject
	set diag1 = '1'
	where diag1 ='diabeticsmellitus';
run;

proc sql;
	update  MyProject
	set diag1 = '0'
	where diag1 ='otherdisease';
run;

 				/*Updating values of "age" column from yound  adult old to 0,1,2 respectively*/

proc sql;
	update  MyProject
	set age = '1'
	where age ='Adult';
run;

proc sql;
	update  MyProject
	set age = '0'
	where age ='Young';
run;

proc sql;
	update  MyProject
	set age = '2'
	where age ='Old';
run;


										
								/*Decriptive statistics of Numeric features*/
proc means Data=MyProject maxdec=2 n nmiss mean stderr median Min Max ;
Title 'Descriptive statistics';
run;


								/*identify char,change length,give statitics*/
			/*For character variables, we can use proc freq to display the number of missing values in each variable.*/

proc freq data = MyProject;
  tables medicalspecialty age change diabetesMed diag1  gender
insulin  race readmitted ;
run;


								/*Converting character types to numeric*/
								
/*Converting readmitted to numerical type*/
data MyProject;
   set MyProject;
  	insulin10=input(insulin,best4.);   /*should drop insulin*/
  	race10=input(race,best4.);        /*should drop race*/
  	 gender10=input(gender,best4.);    /*should drop gender*/
  	 age10=input(age,best4.); 			/*should drop age*/
  	 diag10=input(diag1,best4.);    /*should drop diag1*/
  	 change10=input(change,best4.);    /*should drop change*/
  	 A1Cresult10=input(A1Cresult,best4.);   /*should drop A1cresult*/
  	 diabetesMed10=input(diabetesMed,best4.);  /*should drop diabetesMed*/
  	 medicalspecialty10=input(medicalspecialty,best4.);   /*should drop medicalspeciality*/
run;

data MyProject;
   set MyProject;
   readmitted10=input(readmitted,best4.);
run;



							/*LOGISTIC REGRESSION ASSUMPTION CHECK*/
							/*MULTICOLLINEARITY*/
proc reg data=MyProject;
model readmitted10=patientnbr admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient numlabprocedures 
					numprocedures nummedications insulin10 race10 gender10 age10 diag10 change10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;

					/*p value is high as 0.8 for numberof labprocedures and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10=patientnbr admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient  
					numprocedures nummedications insulin10 race10 gender10 age10 diag10 change10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;

					/*p value is high as 0.7 for change10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10=patientnbr admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient  
					numprocedures nummedications insulin10 race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;


					/*p value is high as 0.7 for patientnbr and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient  
					numprocedures nummedications insulin10 race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;

					/*p value is high as 0.6 for insulin10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient  
					numprocedures nummedications  race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;

					/*p value is high as 0.59 for numberemergency and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient  numberinpatient  
					numprocedures nummedications  race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;


					/*p value is high as 0.47 for timeinhospital and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid admissionsourceid 
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;


					/*p value is high as 0.43 for admissionsourceid and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10 gender10 age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;


					/*p value is high as 0.28 for gender10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10  age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10/vif;
run;

					/*p value is high as 0.26 for medicalspecialty10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10  age10 diag10 A1Cresult10
					numberofdiagnoses diabetesMed10  /vif;
run;

					/*p value is high as 0.21 for diabetesMed10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10  age10 diag10 A1Cresult10
					numberofdiagnoses   /vif;
run;


					/*p value is high as 0.21 for numberofdiagnoses and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					numprocedures nummedications  race10  age10 diag10 A1Cresult10
					   /vif;
run;

				/*p value is high as 0.13 for numprocedures and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					 nummedications  race10  age10 diag10 A1Cresult10
					   /vif;
run;


				/*p value is high as 0.06 for race10 and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10= admissiontypeid dischargedispositionid  
					 numberoutpatient  numberinpatient  
					 nummedications  age10 diag10 A1Cresult10
					   /vif;
run;


				/*p value is high as 0.12 for admissiontypeid and hence removing from model*/
					
proc reg data=MyProject;
model readmitted10=  dischargedispositionid  
					 numberoutpatient  numberinpatient  
					 nummedications  age10 diag10 A1Cresult10
					   /vif;
run;


			/*Check for present of Non linearity between independent variables to the logit of the dependent
									using Box tidwell method*/
/*We have 4 continuous variables at this point.*/
data MyProject;
set MyProject;
ln_dischargedispositionid=log(dischargedispositionid);
ln_numberoutpatient=log(numberoutpatient);
ln_numberinpatient=log(numberinpatient);
ln_nummedications=log(nummedications);
run;

proc logistic data=MyProject;
model readmitted= dischargedispositionid  
					 numberoutpatient  numberinpatient  
					 nummedications  age10 diag10 A1Cresult10 ln_dischargedispositionid ln_numberoutpatient 
					 ln_numberinpatient ln_nummedications;
title 'Myopic Predictors-Logistic Linearity of Logit';
run;

				/*Check for Outliers using PROC REG studentized residuals */
/*If the data is 3 standard deviations away we can consider it as an outlier*/
/*Most of the data is within 3 standard deviations with some exception*/
/*However the outliers are not extreme enough and we can go ahead and confirm the assumption of outliers*/


										/*MODEL BUILDING*/
/*proc logistic data=MyProject;
model readmitted= patientnbr admissiontypeid dischargedispositionid admissionsourceid 
					timeinhospital numberoutpatient numberemergency numberinpatient numlabprocedures 
					numprocedures nummedications insulin10 race10 gender10 age10 diag10 change10 A1Cresult10
					numberofdiagnoses diabetesMed10  medicalspecialty10 ;
title 'diabetic Predictors-Logistic Linearity of Logit';
run;*/

proc logistic data=MyProject;
model readmitted= dischargedispositionid  
					numberoutpatient  numberinpatient  
					 nummedications  age10 diag10 A1Cresult10 ;
title 'diabetic Predictors-Logistic Linearity of Logit';
run;


proc logistic data=MyProject descending;
model readmitted= dischargedispositionid  
				   numberinpatient  
				  nummedications  age10 diag10 A1Cresult10  /rsquare; /*This is how you generate a Lemeshow-Hosmer GOF test,
											this is not necessarily appropriate for the data but shown for exposure */
	































	

           	 	

		





      















						
						
						


				
								

						


				





	

