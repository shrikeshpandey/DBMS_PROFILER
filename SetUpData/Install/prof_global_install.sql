--  PL/SQL Profiler objects
--  Copyright (c) 1998-9,2000 Quest Software.
--  All Rights reserved.
--
--  ** This script must be run under the user SYS
--

GRANT SELECT,INSERT, DELETE,UPDATE ON plsql_profiler_data 	 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON plsql_profiler_runs 	 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON plsql_profiler_units 	 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_anb 		 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_profiles 	 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_runs 		 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_unit_hash 	 TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_units 	         TO PUBLIC;
GRANT SELECT,INSERT, DELETE,UPDATE ON sqln_prof_sess 		 TO PUBLIC;
GRANT SELECT ON plsql_profiler_runnumber   TO PUBLIC;
GRANT SELECT ON sqln_prof_number 	   TO PUBLIC;


CREATE PUBLIC SYNONYM plsql_profiler_data  	FOR plsql_profiler_data;
CREATE PUBLIC SYNONYM plsql_profiler_runs  	FOR plsql_profiler_runs;
CREATE PUBLIC SYNONYM plsql_profiler_units 	FOR plsql_profiler_units;
CREATE PUBLIC SYNONYM sqln_prof_anb        	FOR sqln_prof_anb;
CREATE PUBLIC SYNONYM sqln_prof_profiles   	FOR sqln_prof_profiles;
CREATE PUBLIC SYNONYM sqln_prof_runs       	FOR sqln_prof_runs;
CREATE PUBLIC SYNONYM sqln_prof_unit_hash  	FOR sqln_prof_unit_hash;
CREATE PUBLIC SYNONYM sqln_prof_units      	FOR sqln_prof_units;
CREATE PUBLIC SYNONYM sqln_prof_sess       	FOR sqln_prof_sess;
CREATE PUBLIC SYNONYM plsql_profiler_runnumber  FOR plsql_profiler_runnumber;
CREATE PUBLIC SYNONYM sqln_prof_number 	        FOR sqln_prof_number;
