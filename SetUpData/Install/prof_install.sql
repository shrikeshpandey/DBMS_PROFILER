--  PL/SQL Profiler objects
--  Copyright (c) 1998-9,2001 Quest Software.
--  All Rights reserved.
--
--  ** This script must be run under the user name. If you intend to use these objects
--     globally please also run the PROF_GLOBAL_INSTALL.SQL script to create public grants and
--     synonyms. 
--
--     NOTE: If 'global' objects are used SQL Navigator's Profiler GUI will display all runs
--     regardless of the run owner. This may cause some inconvenience if the Profiler 
--     is used by multiple users. It is recommended to use 'local' objects in this case.
--

-- Table PLSQL_PROFILER_RUNS

CREATE TABLE plsql_profiler_runs
(
  runid           NUMBER PRIMARY KEY,  -- unique run identifier,
                                       -- from plsql_profiler_runnumber
  related_run     NUMBER,              -- runid of related run (for client/
                                       -- server correlation)
  run_owner       VARCHAR2(32),        -- user who started run
  run_date        DATE,                -- start time of run
  run_comment     VARCHAR2(2047),      -- user provided comment for this run
  run_total_time  NUMBER,              -- elapsed time for this run
  run_system_info VARCHAR2(2047),      -- currently unused
  run_comment1    VARCHAR2(2047),      -- additional comment
  spare1          VARCHAR2(256)        -- unused
);

-- Comments for PLSQL_PROFILER_RUNS

COMMENT ON TABLE plsql_profiler_runs IS 'Run-specific information for the PL/SQL profiler'
/

-- Table PLSQL_PROFILER_UNITS

create table plsql_profiler_units
(
  runid              NUMBER REFERENCES plsql_profiler_runs,
  unit_number        NUMBER,           -- internally generated library unit #
  unit_type          VARCHAR2(32),     -- library unit type
  unit_owner         VARCHAR2(32),     -- library unit owner name
  unit_name          VARCHAR2(32),     -- library unit name
  -- timestamp on library unit, can be used to detect changes to
  -- unit between runs
  unit_timestamp     DATE,                
  total_time         NUMBER DEFAULT 0 NOT NULL,
  spare1             NUMBER,           -- unused
  spare2             NUMBER,           -- unused
  --  
  PRIMARY KEY (runid, unit_number)
);

-- Comments for PLSQL_PROFILER_UNITS

COMMENT ON TABLE plsql_profiler_units IS 'Information about each library unit in a run'
/

-- Table PLSQL_PROFILER_DATA

create table plsql_profiler_data
(
  runid           NUMBER,           -- unique (generated) run identifier
  unit_number     NUMBER,           -- internally generated library unit #
  line#           NUMBER not null,  -- line number in unit
  total_occur     NUMBER,           -- number of times line was executed
  total_time      NUMBER,           -- total time spent executing line
  min_time        NUMBER,           -- minimum execution time for this line
  max_time        NUMBER,           -- maximum execution time for this line
  spare1          NUMBER,           -- unused
  spare2          NUMBER,           -- unused
  spare3          NUMBER,           -- unused
  spare4          NUMBER,           -- unused
  --
  PRIMARY KEY (runid, unit_number, line#),
  FOREIGN KEY (runid, unit_number) REFERENCES plsql_profiler_units
);

-- Comments for PLSQL_PROFILER_DATA

COMMENT ON TABLE plsql_profiler_data IS 'Accumulated data from all profiler runs'
/

-- Table SQLN_PROF_PROFILES

CREATE TABLE sqln_prof_profiles
 (
  proj_id                    NUMBER NOT NULL PRIMARY KEY,
  proj_name                  VARCHAR2(2047),
  proj_comment               VARCHAR2(2047)
 )
/

-- Table SQLN_PROF_RUNS

CREATE TABLE sqln_prof_runs
 (
  proj_id                    NUMBER NOT NULL,
  runid                      NUMBER NOT NULL,
  --
  PRIMARY KEY (proj_id,runid),
  FOREIGN KEY (runid)   REFERENCES PLSQL_PROFILER_RUNS(runid),
  FOREIGN KEY (proj_id) REFERENCES SQLN_PROF_PROFILES (proj_id)
 )
/

-- Table SQLN_PROF_UNITS

CREATE TABLE sqln_prof_units
 (
  proj_id                    NUMBER NOT NULL,
  unit_name                  VARCHAR2(30) NOT NULL,
  --
  PRIMARY KEY (proj_id,unit_name),
  FOREIGN KEY (proj_id) REFERENCES SQLN_PROF_PROFILES(proj_id)
 )
/

-- Table SQLN_PROF_UNIT_HASH

CREATE TABLE sqln_prof_unit_hash
 (
  runid                      NUMBER NOT NULL,
  unit_number                NUMBER NOT NULL,
  hash                       VARCHAR2(32),
  --
  PRIMARY KEY (runid,unit_number),
  FOREIGN KEY (runid,unit_number) REFERENCES PLSQL_PROFILER_UNITS (runid,unit_number)
 )
/

-- Comments for SQLN_PROF_UNIT_HASH

COMMENT ON TABLE sqln_prof_unit_hash IS 'Hash of unit source code (1:1 with PLSQL_PROFILER_UNITS)'
/

-- Table SQLN_PROF_ANB

CREATE TABLE sqln_prof_anb
 (
  runid                      NUMBER NOT NULL,
  unit_number                NUMBER NOT NULL,
  line#                      NUMBER NOT NULL,
  text                       VARCHAR2(2048),
  --
  PRIMARY KEY (runid,unit_number,line#),
  FOREIGN KEY (runid,unit_number) REFERENCES PLSQL_PROFILER_UNITS (runid,unit_number)
 )
/

-- Comments for SQLN_PROF_ANB

COMMENT ON TABLE sqln_prof_anb IS 'Annonymous block source'
/

-- Column Comments for SQLN_PROF_ANB

COMMENT ON COLUMN sqln_prof_anb.runid IS 'PLSQL_PROFILER_RUNS'
/
COMMENT ON COLUMN sqln_prof_anb.unit_number IS 'PLSQL_PROFILER_UNITS'
/

-- Table SQLN_PROF_SESS

CREATE TABLE sqln_prof_sess
 (
  runid                      NUMBER NOT NULL,
  stat_id                    NUMBER NOT NULL,
  value                      NUMBER,
  --
  PRIMARY KEY (runid, stat_id),
  FOREIGN KEY (runid) REFERENCES PLSQL_PROFILER_RUNS (runid)
 )
/

-- Comments for SQLN_PROF_SESS

COMMENT ON TABLE sqln_prof_sess IS 'Session Statistics Info For a Run'
/

-- Column Comments for SQLN_PROF_SESS

COMMENT ON COLUMN sqln_prof_sess.runid IS 'PLSQL_PROFILER_RUNS'
/
COMMENT ON COLUMN sqln_prof_sess.stat_id IS 'STATISTIC# from V$STATNAME'
/
COMMENT ON COLUMN sqln_prof_sess.value IS 'VALUE from V$SESSTAT for a session SID and STATISTIC#'
/
-- Sequence PLSQL_PROFILER_RUNNUMBER

CREATE SEQUENCE plsql_profiler_runnumber START WITH 1 NOCACHE 
/

-- Sequence SQLN_PROF_NUMBER

CREATE SEQUENCE sqln_prof_number CACHE 20
/

-- Trigger PLSQL_PROFILER_RUN_OWNER_TRG

CREATE OR REPLACE TRIGGER plsql_profiler_run_owner_trg
  BEFORE INSERT OR UPDATE OF run_owner
  ON plsql_profiler_runs
  FOR EACH ROW
  WHEN (new.run_owner IS NULL)
BEGIN
  :new.run_owner := user;
END;
/
