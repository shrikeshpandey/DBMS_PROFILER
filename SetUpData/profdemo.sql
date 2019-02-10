Rem
Rem  NAME
Rem    profdemo.sql - Demo program for PL/SQL profiler.
Rem
Rem  DESCRIPTION
Rem
Rem    Demo for collecting PL/SQL profiler data for constructs like packages,
Rem    procedures, ADTs, triggers etc.
Rem
Rem  REQUIREMENTS
Rem
Rem    o Package DBMS_OUTPUT is installed for the database.
Rem
Rem  NOTES ON EXECUTING THIS DEMO PROGRAM
Rem
Rem    o Load profiler package by running profload.sql after connecting
Rem      as user SYS. 
Rem
Rem    o Create profiler related data collection schema using proftab.sql 
Rem      after connecting as the user under which this demo will be run. 
Rem
Rem    profload.sql and proftab.sql exist in ORACLE_HOME/plsql/admin directory.
Rem

Rem  Create objects for which profiler demo.

create table profdemo_tab_1 ( col date );
create table profdemo_tab_2 ( col date );

create or replace type profdemo_type as object (
    atr date,
    static function profdemo_type_static_method  return date,
    member function profdemo_type_regular_method return date,
    map member function profdemo_type_map_method return date
);
/
show errors

create or replace type body profdemo_type is
    static function profdemo_type_static_method  return date is
    begin
         return (sysdate);
    end;

    member function profdemo_type_regular_method return date is
    begin
         return (atr); 
    end;

    map member function profdemo_type_map_method return date is
    begin
         return (atr);
    end;
end;
/
show errors

create or replace trigger profdemo_trigger 
          after insert on profdemo_tab_1 for each row
begin
     insert into profdemo_tab_2 values (:new.col);
end;
/
show errors

create or replace package profdemo_pack is 
    earliest_date CONSTANT DATE := profdemo_type.profdemo_type_static_method;
    procedure profdemo_p1;
end profdemo_pack;
/
show errors

create or replace package body profdemo_pack is
   procedure profdemo_p1 is
     d1 profdemo_type := profdemo_type(earliest_date);
     d2 profdemo_type := profdemo_type(earliest_date+1);
     d3 date;
   begin
     for i in 1..5 loop
       d3 := d1.profdemo_type_regular_method()+i;
       insert into profdemo_tab_1 values (d3);
     end loop;

     if d1 > d2 then
       insert into profdemo_tab_1 values (d1.atr);
     else
       insert into profdemo_tab_1 values (d2.atr);
     end if;

     raise value_error;

     exception when value_error then
             NULL;
   end;
end profdemo_pack;
/
show errors

Rem  Start profiling.

declare
  status number;
begin
  status := dbms_profiler.start_profiler('PROFILER DEMO');
end;
/

execute profdemo_pack.profdemo_p1;

Rem  Stop profiling data.

declare
  status number;
begin
  status := dbms_profiler.stop_profiler;
end;
/

Rem  Generate reports using profsum script.

@profsum
