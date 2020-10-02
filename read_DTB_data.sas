/*****************************************************************************
	read_CBO_data.sas
	Ian M. Schmutte

	2019 August
	DESCRIPTION: Read CBO classification data
*****************************************************************************/

******************************
**Libraries
******************************;

LIBNAME CLEAN  "./clean";

******************************
**Options
******************************;
options obs=MAX fullstimer symbolgen mprint LRECL=600 linesize=120;
ods listing; /*needed on shawshank for some mysterious reason*/


          /**********************************************************************

          ***********************************************************************/
             data BR_GEOG_2019    ;
             %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
             infile './DTB_2019/RELATORIO_DTB_BRASIL_MUNICIPIO.csv' delimiter = ',' MISSOVER DSD lrecl=600 firstobs=2 ;
                informat UF $2. ;
                informat UF_NAME $30.;
                informat MESOREGION $2.;
                informat MESOREGION_NAME $30.;
                informat MICROREGION $3.;
                informat MICROREGION_NAME $30.;
                informat muni_suffix $5.;
                informat muni_code_full $7.;
                informat muni_name $30.;
                format UF $2. ;
                format UF_NAME $30.;
                format MESOREGION $2.;
                format MESOREGION_NAME $30.;
                format MICROREGION $3.;
                format MICROREGION_NAME $30.;
                format muni_suffix $5.;
                format muni_code_full $7.;
                format muni_name $30.;

             input
                         UF $
                         UF_NAME $     
                         MESOREGION $       
                         MESOREGION_NAME $
                         MICROREGION $
                         MICROREGION_NAME $
                         muni_suffix $
                         muni_code_full $
                         muni_name $
             ;
             if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
             run;

proc contents data = BR_GEOG_2019;
run;


/* proc print data = BR_GEOG_2019;
run; */

data CLEAN.BR_GEOG_2019;
  set BR_GEOG_2019;
  length muni $ 6;
  muni = trim(left(substr(muni_code_full,1,6)));
  microreg_code_full = UF||MESOREGION||MICROREGION;
  mesoreg_code_full = UF||MESOREGION;
run;

proc freq data = CLEAN.BR_GEOG_2019 nlevels;
  tables muni muni_code_full microreg_code_full mesoreg_code_full / noprint;
run;

/*ASSERT NUMBER OF MUNIS = NUM of MUNI_CODE_FULL*/
proc sort data = CLEAN.BR_GEOG_2019;
  by muni muni_code_full;
run;


/*check to make sure 6 digit muni code is not missing anything important*/
data temp (keep=count);
  set CLEAN.BR_GEOG_2019;
  by muni;
  retain count;
  if first.muni then count=0;
  count = count+1;
  if last.muni then output;
run;

proc freq data = temp;
  tables count;
run;