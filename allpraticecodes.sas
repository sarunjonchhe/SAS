*overview;
data myclass;
	set sashelp.class;
run;

proc print data=myclass;
run;

*accessing the datas;
proc contents data="path";
run;

*library;
libname libref engine "path";
libname mylib base "path/data";
proc contents data=mylib.class; *libref.table-name;
run;

3.
*to create library;
libname np xlsx "/folders/myfolders/coursefiles/EPG1V2/data/np_info.xlsx";
*to make the excel folow the naming convention of sas7;
options validvarname=v7;
*to read the parks table and display;
proc contents data=np.parks;
run;
*to clear Np library;
libname np clear; 

importing the datas
proc import datafile="/folders/myfolders/coursefiles/EPG1V2/data/storm_damage.tab"
            dbms=tab out=storm_damage_tab replace;
run; 



Lesson 3

/*list first 20 rows*/
proc print data=pg1.np_summary(obs=20);
    var Reg Type ParkName DayVisits TentCampers RVCampers;
run;

/*calculate summary statistics*/
proc means data=pg1.np_summary;
    var DayVisits TentCampers RVCampers;
run;

/*examine extreme values*/
proc univariate data=pg1.np_summary;
    var DayVisits TentCampers RVCampers;
run;

/*list unique values and frequency counts*/
proc freq data=pg1.np_summary;
    tables Reg Type;
run;

*where statement;
proc print data=pg1.storm_summary(obs=50);
	/*where MinPressure is missing; /*same as MinPressure = .
	where Type is not missing; /*same as Type ne " "
	where MaxWindMPH between 150 and 155;
	where Basin like "_I";*/
	where Name like "Z%";
run;
 
macrovariables
%let BasinCode=SP;

proc means data=pg1.storm_summary;
	where Basin="&BasinCode";
	var MaxWindMPH MinPressure;
run;

proc freq data=pg1.storm_summary;
	where Basin="&BasinCode";
	tables Type;
run;

proc print data=pg1.np_summary;
	var Type ParkName;
	*Add a WHERE statement;
	where ParkName like '%Preserve%';
run;

*  Activity 3.05                                          *;
*    1) Highlight the PROC PRINT step and run the         *;
*       selected code. Notice how the values of Lat, Lon, *;
*       StartDate, and EndDate are displayed in the       *;
*       report.                                           *;
*    2) Change the width of the DATE format to 7 and run  *;
*       the PROC PRINT step. How does the display of      *;
*       StartDate and EndDate change?                     *;
*    3) Change the width of the DATE format to 11 and run *;
*       the PROC PRINT step. How does the display of      *;
*       StartDate and EndDate change?                     *;
*    4) Highlight the PROC FREQ step and run the selected *;
*       code. Notice that the report includes the number  *;
*       of storms for each StartDate.                     *;
*    5) Add a FORMAT statement to apply the MONNAME.      *;
*       format to StartDate and run the PROC FREQ step.   *;
*       How many rows are in the report?                  *;
***********************************************************;

proc print data=pg1.storm_summary(obs=20);
	format Lat Lon 4. StartDate EndDate date11.;
run;

proc freq data=pg1.storm_summary order=freq;
	tables StartDate;
	*Add a FORMAT statement;
	format StartDate MONNAME.;
run;


***********************************************************;
*  Activity 3.06                                          *;
*    1) Modify the OUT= option in the PROC SORT statement *;
*       to create a temporary table named STORM_SORT.     *;
*    2) Complete the WHERE and BY statements to answer    *;
*       the following question: Which storm in the North  *;
*       Atlantic basin (NA or na) had the strongest       *;
*       MaxWindMPH?                                       *;
***********************************************************;

proc sort data=pg1.storm_summary out=storm_sort;
	where Basin in ("NA","na");
	by descending MaxWindMPH;
run;

***********************************************************;
*  LESSON 3, PRACTICE 8                                   *;
*    a) Modify the PROC SORT step to read PG1.NP_SUMMARY  *;
*       and create a temporary sorted table named         *;
*       NP_SORT.                                          *;
*    b) Add a BY statement to order the data by Reg and   *;
*       descending DayVisits.                             *;
*    c) Add a WHERE statement to select Type equal to NP. *;
*       Submit the program.                               *;
***********************************************************;

proc sort data=pg1.np_summary out=np_sort;
	by Reg descending DayVisits;
	where type="NP";

run;
	
	
***********************************************************;
*  LESSON 4, PRACTICE 1                                   *;
*    a) Open the PG1.EU_OCC table and examine the column  *;
*       names and values.                                 *;
*    b) Modify the code to create a temporary table named *;
*       EU_OCC2016 and read PG1.EU_OCC.                   *;
*    c) Complete the WHERE statement to select only the   *;
*       stays that were reported in 2016. Notice that     *;
*       YearMon is a character column and the first four  *;
*       positions represent the year.                     *;
*    d) Complete the FORMAT statement in the DATA step to *;
*       apply the COMMA17. format to the Hotel,           *;
*       ShortStay, and Camp columns.                      *;
*    e) Complete the DROP statement to exclude Geo from   *;
*       the output table.                                 *;
***********************************************************;

data  eu_occ2016;
	set  pg1.eu_occ;
	where YearMon like "2016%";
	format Hotel ShortStay Camp COMMA17.;
	drop Geo;
run;

***********************************************************;
*  Activity 4.04                                          *;
*    1) Add an assignment statement to create StormLength *;
*       that represents the number of days between        *;
*       StartDate and EndDate.                            *;
*    2) Run the program. In 1980, how long did the storm  *;
*       named Agatha last?                                *;
***********************************************************;

data storm_length;
	set pg1.storm_summary;
	drop Hem_EW Hem_NS Lat Lon;
	*Add assignment statement;
	StormLength=EndDate-StartDate;
run;

***********************************************************;
*  Activity 4.06                                          *;
*    1) Add a WHERE statement that uses the SUBSTR        *;
*       function to include rows where the second letter  *;
*       of Basin is P (Pacific ocean storms).             *;
*    2) Run the program and view the log and data. How    *;
*       many storms were in the Pacific basin?            *;
***********************************************************;
*  Syntax                                                 *;
*     SUBSTR (char, position, <length>)                   *;
***********************************************************;

data pacific;
	set pg1.storm_summary;
	drop Type Hem_EW Hem_NS MinPressure Lat Lon;
	*Add a WHERE statement that uses the SUBSTR function;
	where substr(Basin,2,1)="P";
run;

***********************************************************;
*  LESSON 4, PRACTICE 4                                   *;
*    a) Create a new column named SqMiles by multiplying  *;
*       Acres by .0015625.                                *;
*    b) Create a new column named Camping as the sum of   *;
*       OtherCamping, TentCampers, RVCampers, and         *;
*       BackcountryCampers.                               *;
*    c) Format SqMiles and Camping to include commas and  *;
*       zero decimal places.                              *;
*    d) Modify the KEEP statement to include the new      *;
*       columns. Run the program.                         *;
***********************************************************;

data np_summary_update;
    set pg1.np_summary;
    keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping;
    SqMiles=Acres*.0015625;
    Camping=sum(OtherCamping,TentCampers,
                RVCampers,BackcountryCampers);
    format SqMiles comma6. Camping comma10.;
run;

libname pg1 "/folders/myfolders/coursefiles/EPG1V2/data";
data storm_cat;
	set pg1.storm_summary;
	keep Name Basin MinPressure StartDate PressureGroup;
	*add ELSE keyword and remove final condition;
	if MinPressure=. then PressureGroup=.;
	else if MinPressure<=920 then PressureGroup=1;
	else PressureGroup=0;
run;

proc freq data=storm_cat;
	tables PressureGroup;
run;

*  Activity 4.08                                          *;
*    1) Run the program and examine the results. Why is   *;
*       Ocean truncated? What value is assigned when      *;
*       Basin='na'?                                       *;
*    2) Modify the program to add a LENGTH statement to   *;
*       declare the name, type, and length of Ocean       *;
*       before the column is created.                     *;
*    3) Add an assignment statement after the KEEP        *;
*       statement to convert Basin to uppercase. Run the  *;
*       program.                                          *;
*    4) Move the LENGTH statement to the end of the DATA  *;
*       step. Run the program. Does it matter where the   *;
*       LENGTH statement is in the DATA step?             *;
***********************************************************;
*  Syntax                                                 *;
*       LENGTH char-column $ length;                      *;
***********************************************************;

data storm_summary2;
	set pg1.storm_summary;
	*Add a LENGTH statement;
	length Ocean $8;
	keep Basin Season Name MaxWindMPH Ocean;
	*Add assignment statement;
	Basin=upcase(Basin);
	
	OceanCode=substr(Basin,2,1);
	if OceanCode="I" then Ocean="Indian";
	else if OceanCode="A" then Ocean="Atlantic";
	else Ocean="Pacific";
run;

***********************************************************;

data front rear;
    set sashelp.cars;
    if DriveTrain="Front" then do;
        DriveTrain="FWD";
        output front;
        end;
    else if DriveTrain='Rear' then do;
        DriveTrain="RWD";
        output rear;
        end;
run;

  LESSON 4, PRACTICE 7                                   *;
*    a) Submit the program and view the generated output. *;
*    b) In the DATA step, use IF-THEN/ELSE statements to  *;
*       create a new column, ParkType, based on the value *;
*       of Type.                                          *;
*       NM -> Monument                                    *;
*       NP -> Park                                        *;
*       NPRE, PRE, or PRESERVE -> Preserve                *;
*       NS -> Seashore                                    *;
*       RVR or RIVERWAYS -> River                         *;
*    c) Modify the PROC FREQ step to generate a frequency *;
*       report for ParkType.                   
data park_type;
    set pg1.np_summary;
    length ParkType $ 8;
    if Type='NM' then ParkType='Monument';
    else if Type='NP' then ParkType='Park';
    else if Type in ('NPRE', 'PRE', 'PRESERVE') then
        ParkType='Preserve';
    else if Type in ('RVR', 'RIVERWAYS') then ParkType='River';
    else if Type='NS' then ParkType='Seashore';
run;

proc freq data=park_type;
    tables ParkType;
run;

title "Storm Analysis";
title2 "Summary Statistics for MaxWind and MinPressure";
proc means data=pg1.storm_final;
   var MaxWindMPH MinPressure;
run;
title2 "Frequency Report for Basin";
proc freq data=pg1.storm_final;
   tables BasinName;
run; 



***********************************************************;
*  Activity 5.03                                          *;
*    1) Modify the LABEL statement in the DATA step to    *;
*       label the Invoice column as Invoice Price.        *;
*    2) Run the program. Why do the labels appear in the  *;
*       PROC MEANS report but not in the PROC PRINT       *;
*       report? Fix the program and run it again.         *;
***********************************************************;

data cars_update;
    set sashelp.cars;
	keep Make Model MSRP Invoice AvgMPG;
	AvgMPG=mean(MPG_Highway, MPG_City);
	label MSRP="Manufacturer Suggested Retail Price"
          AvgMPG="Average Miles per Gallon";
          Invoice="Invoice Price";
run;

proc means data=cars_update min mean max;
    var MSRP Invoice;
run;

proc print data=cars_update label;
    var Make Model MSRP Invoice AvgMPG;
run;



title "Frequency Report for Basin and Storm Month";

proc freq data=pg1.storm_final order=freq noprint;
	tables StartDate / out= storm_count;
	format StartDate monname.;
run;



Write a PROC FREQ step to analyze rows from pg1.np_species.

Use the TABLES statement to generate a frequency table for Category.
Use the NOCUM option to suppress the cumulative columns.
Use the ORDER=FREQ option in the PROC FREQ statement to sort the results by descending frequency.
Use Categories of Reported Species as the report title.
Submit the program and review the results.

Solution:
title1 "Categories of Reported Species";
proc freq data=pg1.np_species order=freq;
    tables Category / nocum;
    
    
*Modify the PROC FREQ step to make the following changes:

Include only the rows where Species_ID starts with EVER and Category is not Vascular Plant.
Note: EVER represents Everglades National Park.
Turn on ODS Graphics before the PROC FREQ step and turn off the procedure title.
Add the PLOTS=FREQPLOT option to display frequency plots.
Add in the Everglades as a second title.
Submit the program and review the results.;

ods graphics on;
ods noproctitle;
title1 "Categories of Reported Species";
title2 "in the Everglades";
proc freq data=pg1.np_species order=freq;
    tables Category / nocum plots=freqplot;
    where Species_ID like "EVER%" and 
          Category ne "Vascular Plant";
run;
title;


***********************************************************;
*  Activity 5.05                                          *;
*    1) Add options to include N (count), MEAN, and MIN   *;
*       statistics. Round each statistic to the nearest   *;
*       integer.                                          *;
*    2) Add a CLASS statement to group the data by Season *;
*       and Ocean. Run the program.                       *;
*    3) Modify the program to add the WAYS statement so   *;
*       that separate reports are created for Season and  *;
*       Ocean statistics. Run the program.                *;
*       Which ocean had the lowest mean for minimum       *;
*       pressure?                                         *;
*       Which season had the lowest mean for minimum      *;
*       pressure?                                         *;
***********************************************************;

proc means data=pg1.storm_final maxdec=0 n mean min;
    var MinPressure;
    where Season >=2010;
    class Season Ocean;
run;





**************************************************;
*  Activity 5.07                                 *;
*    Run the program and examine the results to  *;
*    see examples of other procedures that       *;
*    analyze and report on the data.             *;
**************************************************;

%let Year=2016;
%let basin=NA;

**************************************************;
*  Creating a Map with PROC SGMAP                *;
*   Requires SAS 9.4M5 or later                  *;
**************************************************;

*Preparing the data for map labels;
data map;
	set pg1.storm_final;
	length maplabel $ 20;
	where season=&year and basin="&basin";
	if maxwindmph<100 then MapLabel=" ";
	else maplabel=cats(name,"-",maxwindmph,"mph");
	keep lat lon maplabel maxwindmph;
run;

*Creating the map;
title1 "Tropical Storms in &year Season";
title2 "Basin=&basin";
footnote1 "Storms with MaxWind>100mph are labeled";

proc sgmap plotdata=map;
    *openstreetmap;
    esrimap url='http://services.arcgisonline.com/arcgis/rest/services/World_Physical_Map';
            bubble x=lon y=lat size=maxwindmph / datalabel=maplabel datalabelattrs=(color=red size=8);
run;
title;footnote;

**************************************************;
*  Creating a Bar Chart with PROC SGPLOT         *;
**************************************************;
title "Number of Storms in &year";
proc sgplot data=pg1.storm_final;
	where season=&year;
	vbar BasinName / datalabel dataskin=matte categoryorder=respdesc;
	xaxis label="Basin";
	yaxis label="Number of Storms";
run;

**************************************************;
*  Creating a Line PLOT with PROC SGPLOT         *;
**************************************************;
title "Number of Storms By Season Since 2010";
proc sgplot data=pg1.storm_final;
	where Season>=2010;
	vline Season / group=BasinName lineattrs=(thickness=2);
	yaxis label="Number of Storms";
	xaxis label="Basin";
run;

**************************************************;
*  Creating a Report with PROC TABULATE          *;
**************************************************;

proc format;
    value count 25-high="lightsalmon";
    value maxwind 90-high="lightblue";
run;

title "Storm Summary since 2000";
footnote1 "Storm Counts 25+ Highlighted";
footnote2 "Max Wind 90+ Highlighted";

proc tabulate data=pg1.storm_final format=comma5.;
	where Season>=2000;
	var MaxWindMPH;
	class BasinName;
	class Season;
	table Season={label=""} all={label="Total"}*{style={background=white}},
		BasinName={LABEL="Basin"}*(MaxWindMPH={label=" "}*N={label="Number of Storms"}*{style={background=count.}} 
		MaxWindMPH={label=" "}*Mean={label="Average Max Wind"}*{style={background=maxwind.}}) 
		ALL={label="Total"  style={vjust=b}}*(MaxWindMPH={label=" "}*N={label="Number of Storms"} 
		MaxWindMPH={label=" "}*Mean={label="Average Max Wind"})/style_precedence=row;
run;
title;
footnote;

***********************************************************;
*  Activity 7.03                                          *;
*    1) Define aliases for STORM_SUMMARY and              *;
*       STORM_BASINCODES in the FROM clause.              *;
*    2) Use one table alias to qualify Basin in the       *;
*       SELECT clause.                                    *;
*    3) Complete the ON expression to match rows when     *;
*       Basin is equal in the two tables. Use the table   *;
*       aliases to qualify Basin in the expression. Run   *;
*       the step.                                         *;
***********************************************************;
*  Syntax                                                 *;
*     FROM table1 AS alias1 INNER JOIN table2 AS alias2   *;
*     ON alias1.column = alias2.column                    *;
***********************************************************;

proc sql;
select Season, Name, u.Basin, BasinName, MaxWindMPH 
    from pg1.storm_summary as u inner join pg1.storm_basincodes as t
		on  upcase(u.basin)=t.basin
    order by Season desc, Name;
quit;