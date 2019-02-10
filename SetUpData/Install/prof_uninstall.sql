--  Removes PL/SQL Profiler objects
--  Copyright (c) 1998-9 Quest Software.
--  All Rights reserved.
--
--  ** This script must be run under the user name
--

drop table plsql_profiler_data cascade constraints
/
drop table plsql_profiler_units cascade constraints
/
drop table plsql_profiler_runs cascade constraints
/
drop table sqln_prof_anb cascade constraints
/
drop table sqln_prof_units cascade constraints
/
drop table sqln_prof_unit_hash cascade constraints
/
drop table sqln_prof_runs cascade constraints
/
drop table sqln_prof_profiles cascade constraints
/
drop table sqln_prof_sess cascade constraints
/
drop sequence plsql_profiler_runnumber
/
drop sequence sqln_prof_number
/
