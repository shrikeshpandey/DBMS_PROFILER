Rem
Rem $Header: profsum.sql 13-apr-98.19:17:28 astocks Exp $
Rem
Rem profsum.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      profsum.sql
Rem
Rem    DESCRIPTION
Rem      Example of usage of profiler data. A miscellany of potentially
Rem      useful adhoc queries, and calls to the prof_report_utilities
Rem      package.
Rem
Rem    NOTES
Rem      You must connect before running this script.  Calls to the long 
Rem      reports can be commented out.
Rem

/* Script to dump lots of reports from ordts long performance run */

set echo off
@profrep
set serveroutput on

REM set echo on
REM spool profsum.out

/* Clean out rollup results, and recreate */
update plsql_profiler_units set total_time = 0;

execute prof_report_utilities.rollup_all_runs;

/* Total time */
select 
    to_char(grand_total/1000000000, '999999.99') as grand_total
  from plsql_profiler_grand_total;

/* Total time spent on each run */

select 
    runid, substr(run_comment,1, 30) as run_comment, 
    run_total_time/1000000000 as seconds 
  from plsql_profiler_runs 
  where run_total_time > 0 
  order by runid asc;


/* Percentage of time in each module, for each run separately */

select 
    p1.runid,
    substr(p2.run_comment, 1, 20) as run_comment,
    p1.unit_owner,
    decode(p1.unit_name, '', '<anonymous>', substr(p1.unit_name,1, 20)) as unit_name, 
    TO_CHAR(p1.total_time/1000000000, '99999.99') as seconds, 
    TO_CHAR(100*p1.total_time/p2.run_total_time, '999.9') as percentage 
  from plsql_profiler_units p1, plsql_profiler_runs p2 
  where 
    p1.runid=p2.runid and 
    p1.total_time > 0 and p2.run_total_time > 0 and  
    (p1.total_time/p2.run_total_time)  >= .01
  order by p1.runid asc, p1.total_time desc;

/* Percentage of time in each module, summarized across runs */

select p1.unit_owner,
    decode(p1.unit_name, '', '<anonymous>', substr(p1.unit_name,1, 25)) as unit_name, 
    TO_CHAR(p1.total_time/1000000000, '99999.99') as seconds, 
    TO_CHAR(100*p1.total_time/p2.grand_total, '99999.99') as percentage 
  from 
    plsql_profiler_units_cross_run p1, 
    plsql_profiler_grand_total p2 
  order by p1.total_time DESC;


Rem Analyze min/max/average time anomalies -
Rem
Rem This report finds lines where the minimum time for the query is either 
Rem greater than the average time (which indicates a data collection
Rem problem), or significantly less than the average (which indicates high
Rem variablility in the timing of a single line). It can take a long time to
Rem run, so it should only be used if the data is suspected to have problems.
Rem Normally, this query should produce no output.
Rem
select 
    p1.runid, p2.unit_owner, substr(p2.unit_name,1,25), 
    to_char(p1.line#,'9999') as line,
    p1.total_occur,
    to_char(p1.total_time/1000,'9999999.99') as microS, 
    to_char(p1.total_time/(1000*p1.total_occur),'9999999.99') as "Ave Micro",
    to_char(p1.min_time/1000,'9999999.99') as min_time, 
    to_char(p1.max_time/1000,'999999999.99') as max_time, 
    to_char(p1.max_time/p1.min_time,'999999.99') as "Max/min",
    to_char(p1.total_time/(p1.total_occur*p1.min_time),'99999.99')as "Ave/min",
    p3.text
  from 
    plsql_profiler_data p1, 
    plsql_profiler_units p2, 
    all_source p3
  where 
    ((p1.total_time > 1000*(p1.total_occur*p1.min_time)) OR
     (p1.total_time < (p1.total_occur*p1.min_time))) AND
    p1.runID=p2.runID and p2.unit_number = p1.unit_number AND
    ((p3.type='PACKAGE BODY') OR (p3.type = 'PROCEDURE')) and 
    p3.line = p1.line# and 
    (p3.owner = p2.unit_owner)   AND 
    (p3.name=p2.unit_name)
  order by "Ave/min" asc;

/* Lines taking more than 1% of the total time, each run separate */
select 
    p1.runid as runid,
    to_char(p1.total_time/1000000000, '99999.9') as seconds, 
    substr(p2.unit_owner, 1, 20) as owner,
    decode(p2.unit_name, '', '<anonymous>', substr(p2.unit_name,1, 20)) as unit_name, 
    p1.line#, 
    p3.text 
  from 
    plsql_profiler_data p1, 
    plsql_profiler_units p2, 
   all_source p3, plsql_profiler_grand_total p4 
  where 
    (p1.total_time >= p4.grand_total/100) AND 
    p1.runID = p2.runid and 
    p2.unit_number=p1.unit_number and 
    p3.type='PACKAGE BODY' and 
    p3.owner = p2.unit_owner and 
    p3.line = p1.line# and 
    p3.name=p2.unit_name 
  order by p1.total_time desc;

/* Most popular lines (more than 1%), summarize across all runs */
select 
    to_char(p1.total_time/1000000000, '99999.9') as seconds,
    substr(p1.unit_owner, 1, 20) as unit_owner, 
    decode(p1.unit_name, '', '<anonymous>', substr(p1.unit_name,1, 20)) as unit_name, 
    p1.line#,
    p3.text 
  from 
    plsql_profiler_lines_cross_run p1, 
    all_source p3, 
    plsql_profiler_grand_total p4
  where 
    (p1.total_time >= p4.grand_total/100) AND 
    ((p3.type='PACKAGE BODY') OR (p3.type = 'PROCEDURE')) and 
    (p3.line = p1.line#) and 
    (p3.owner = p1.unit_owner) AND
    (p3.name = p1.unit_name)
  order by p1.total_time desc;

Rem Get coverage information 
execute prof_report_utilities.rollup_all_runs; 

Rem Number of lines actually executed in different units (by unit_name) 
select 
    p1.unit_owner, p1.unit_name, 
    count(p1.line#) as lines_executed 
  from plsql_profiler_lines_cross_run p1 
  where 
    (p1.unit_type = 'PACKAGE BODY' OR 
    p1.unit_type = 'TYPE BODY')  AND 
    p1.total_occur != 0 
  group by p1.unit_owner, p1.unit_name; 
 
Rem Total number of lines in different units ( by unit_name) 
select 
    p1.unit_owner, p1.unit_name, 
    count(p1.line#) as lines_present 
  from plsql_profiler_lines_cross_run p1 
  where 
    (p1.unit_type = 'PACKAGE BODY' OR 
    p1.unit_type = 'TYPE BODY') 
    group by p1.unit_owner, p1.unit_name; 
 
Rem Number of lines actually executed for all units 
select 
    count(p1.line#) as lines_executed 
  from plsql_profiler_lines_cross_run p1 
  where 
    (p1.unit_type = 'PACKAGE BODY' OR 
     p1.unit_type = 'TYPE BODY')  AND 
    p1.total_occur > 0; 
 
 
Rem Total number of lines in all units 
select 
    count(p1.line#) as lines_present 
  from plsql_profiler_lines_cross_run p1 
  where 
    (p1.unit_type = 'PACKAGE BODY' OR 
     p1.unit_type = 'TYPE BODY')  ; 

/* Full reports */ 
execute prof_report_utilities.Print_Detailed_Report;
execute prof_report_utilities.Print_Summarized_Report;

REM spool off
REM exit
