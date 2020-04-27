CREATE TABLE log_tables (
    action  VARCHAR2(10),
    actionAuthor VARCHAR2(60),
    action_date DATE,
    table_name VARCHAR2(60)
);
/*course_sections table*/

CREATE OR REPLACE TRIGGER cheking_update_cs
AFTER UPDATE ON course_sections 
BEGIN
    INSERT INTO log_tables VALUES('UPDATE', USER, SYSDATE, 'course_sections');
END;


CREATE OR REPLACE TRIGGER cheking_insert_cs
AFTER INSERT ON course_sections 
BEGIN
    INSERT INTO log_tables VALUES('INSERT', USER, SYSDATE, 'course_sections');
END;

CREATE OR REPLACE TRIGGER cheking_delete_cs
AFTER DELETE ON course_sections 
BEGIN
    INSERT INTO log_tables VALUES('DELETE', USER, SYSDATE, 'course_sections');
END;

/*course_selections table*/
CREATE OR REPLACE TRIGGER cheking__update_css
AFTER UPDATE ON course_selections
BEGIN
    INSERT INTO log_tables VALUES('UPDATE', USER, SYSDATE, 'course_selections');
END;


CREATE OR REPLACE TRIGGER cheking_insert_css
AFTER INSERT ON course_selections
BEGIN
    INSERT INTO log_tables VALUES('INSERT', USER, SYSDATE, 'course_selections');
END;


CREATE OR REPLACE TRIGGER cheking_delete_css
AFTER DELETE ON course_selections 
BEGIN
    INSERT INTO log_tables VALUES('DELETE', USER, SYSDATE, 'course_selections');
END;

/*course_schedule table*/
CREATE OR REPLACE TRIGGER cheking_update_csh
AFTER UPDATE ON course_schedule
BEGIN
    INSERT INTO log_tables VALUES('UPDATE', USER, SYSDATE, 'course_schedule');
END;


CREATE OR REPLACE TRIGGER cheking_insert_csh
AFTER INSERT ON course_schedule
BEGIN
    INSERT INTO log_tables VALUES('INSERT', USER, SYSDATE, 'course_schedule');
END;


CREATE OR REPLACE TRIGGER cheking_delete_csh
AFTER DELETE ON course_schedule
BEGIN
    INSERT INTO log_tables VALUES('DELETE', USER, SYSDATE, 'course_schedule');
END;