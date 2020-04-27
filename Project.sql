SET SERVEROUTPUT ON

SELECT * FROM course_sections WHERE ders_year = 2016 AND terms = 1
SELECT * FROM course_selections WHERE stud_id = '68B977F2ECAAFA5DEC30D9162413A2011E454C43' AND terms = 1
SELECT DISTINCT credits FROM course_sections WHERE ders_kod = 'CSS 303'
    INNER JOIN course_sections ON course_sections.section = course_selections.section 
    WHERE course_sections.ders_year = 2016 AND 
        course_sections.ders_kod = course_selections.ders_kod AND 
        emp_id = 10162 AND 
        course_sections.terms = 1;

/*3) Calculate GPA of student for the semester and total*/
CREATE OR REPLACE FUNCTION gpa_of_student_total(
    p_stud_id IN course_selections.stud_id%TYPE, 
    p_year IN course_selections.ders_year%TYPE) 
    RETURN NUMBER IS
    
    CURSOR cur_gpa IS 
        SELECT * FROM course_selections WHERE stud_id = p_stud_id AND ders_year = p_year;
    v_record    cur_gpa%ROWTYPE;
    v_total     NUMBER  := 0;
    v_gpa       NUMBER(3,2);
    v_count_subjects NUMBER := 0;
BEGIN
    OPEN cur_gpa;
        LOOP
            FETCH cur_gpa INTO v_record;
            EXIT WHEN cur_gpa%NOTFOUND;
            
            v_total := v_total + calculate_gpa(v_record.qiymet_yuz);
            v_count_subjects := v_count_subjects + 1;
        END LOOP;
    CLOSE cur_gpa;
    
    v_gpa := (v_total/v_count_subjects);
    RETURN v_gpa;
END gpa_of_student_total;

/*3) Calculate GPA of student for the semester and total*/
CREATE OR REPLACE FUNCTION gpa_of_student_semester(
    p_stud_id IN course_selections.stud_id%TYPE, 
    p_year IN course_selections.ders_year%TYPE,
    p_semester IN NUMBER) 
    RETURN NUMBER IS
    
    CURSOR cur_gpa IS 
        SELECT * FROM course_selections WHERE stud_id = p_stud_id AND ders_year = p_year AND terms = p_semester;
    v_record    cur_gpa%ROWTYPE;
    v_total     NUMBER  := 0;
    v_gpa       NUMBER(3,2);
    v_count_subjects NUMBER := 0;
BEGIN
    OPEN cur_gpa;
        LOOP
            FETCH cur_gpa INTO v_record;
            EXIT WHEN cur_gpa%NOTFOUND;
            
            v_total := v_total + calculate_gpa(v_record.qiymet_yuz);
            v_count_subjects := v_count_subjects + 1;
        END LOOP;
    CLOSE cur_gpa;
    
    v_gpa := (v_total/v_count_subjects);
    RETURN v_gpa;
END gpa_of_student_semester;

/*additional function for calculate each subject for gpa*/
CREATE OR REPLACE FUNCTION calculate_gpa(
    p_grade_point  course_selections.qiymet_yuz%TYPE) 
    RETURN NUMBER IS
    v_gpa NUMBER;
BEGIN
    v_gpa := (4.0 * p_grade_point)/100;
    RETURN v_gpa;
END calculate_gpa;

/*13) Calculate total number of retakes for all time and display the profit.*/
CREATE OR REPLACE FUNCTION num_retakes
    RETURN NUMBER IS 
    v_num_retake    NUMBER;
BEGIN
    SELECT COUNT(stud_id) INTO v_num_retake FROM course_selections 
        WHERE grading_type = 'PNP';    
    RETURN v_num_retake;
END;

/*4) Find students who didn’t register any subjects for one semester*/
CREATE OR REPLACE PROCEDURE didnt_register_subject(
    p_year IN NUMBER, 
    p_terms IN NUMBER) IS
    TYPE t_stud_id IS TABLE OF course_selections.stud_id%TYPE;
    TYPE t_ders IS TABLE OF course_selections.ders_kod%TYPE;
    v_stud_id_tab   t_stud_id;
    v_ders          t_ders;
BEGIN
    SELECT DISTINCT stud_id BULK COLLECT INTO v_stud_id_tab FROM course_selections;
    FOR i IN v_stud_id_tab.FIRST .. v_stud_id_tab.LAST LOOP
        SELECT ders_kod BULK COLLECT INTO v_ders FROM course_selections WHERE stud_id = TO_CHAR(v_stud_id_tab(i)) AND ders_year = p_year AND terms = p_terms;
        
        IF (SQL%ROWCOUNT = 0) THEN
            DBMS_OUTPUT.PUT_LINE(v_stud_id_tab(i));
        END IF;
    END LOOP;
END didnt_register_subject;

/*6. Calculate the teachers’ “loading” (how many hours Teacher have for given semester)*/
CREATE OR REPLACE FUNCTION teacher_loading(
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN NUMBER IS
    CURSOR cur_teacher IS 
        SELECT * FROM course_sections WHERE emp_id = 10112 AND terms = p_terms AND ders_year = p_year;
    v_hours     NUMBER := 0;
BEGIN
    FOR v_record IN cur_teacher LOOP
        v_hours := v_hours + v_record.hour_num;
    END LOOP;
    RETURN v_hours;
END teacher_loading;

/*update information about credits*/
CREATE OR REPLACE PROCEDURE update_credits IS
    v_credits NUMBER;
BEGIN
    UPDATE course_sections SET credits = 3
        WHERE credits IS NULL;
END update_credits;

BEGIN
    update_credits;
END;

/*5) Calculate how much money the student spent on retakes for the given
semester (included) and total spent.*/
CREATE OR REPLACE FUNCTION retake_money_semester(
        p_stud_id   course_selections.stud_id%TYPE,
        p_year      NUMBER,
        p_terms     NUMBER ) RETURN NUMBER IS
    CURSOR cur_sub IS 
        SELECT sec.credits FROM course_selections sel 
            INNER JOIN course_sections sec ON sec.section = sel.section AND sec.ders_kod = sel.ders_kod
            WHERE qiymet_yuz < 50 AND stud_id = p_stud_id AND sec.ders_year = p_year AND sec.terms = p_terms;           
    v_credits   course_sections.credits%TYPE;
    v_total_money NUMBER := 0;
BEGIN
    OPEN cur_sub;
        LOOP
            FETCH cur_sub INTO v_credits;
            EXIT WHEN cur_sub%NOTFOUND;
            calculate_credits(v_credits);
            v_total_money := v_total_money + v_credits;
        END LOOP;
    CLOSE cur_sub;
    
    RETURN v_total_money;
END retake_money_semester;

CREATE OR REPLACE FUNCTION retake_money_total(
        p_stud_id   course_selections.stud_id%TYPE,
        p_year      NUMBER ) RETURN NUMBER IS
    CURSOR cur_sub IS 
        SELECT sec.credits FROM course_selections sel 
            INNER JOIN course_sections sec ON sec.section = sel.section AND sec.ders_kod = sel.ders_kod
            WHERE qiymet_yuz < 50 AND stud_id = p_stud_id AND sec.ders_year = p_year;
    v_credits   course_sections.credits%TYPE;
    v_total_money NUMBER := 0;
BEGIN
    OPEN cur_sub;
        LOOP
            FETCH cur_sub INTO v_credits;
            EXIT WHEN cur_sub%NOTFOUND;
            calculate_credits(v_credits);
            v_total_money := v_total_money + v_credits;
        END LOOP;
    CLOSE cur_sub;
    
    RETURN v_total_money;
END retake_money_total;

CREATE OR REPLACE PROCEDURE calculate_credits(
        p_credits IN OUT  NUMBER) IS
    c_sum_credit CONSTANT NUMBER := 25000; --tg
BEGIN
    p_credits := p_credits * c_sum_credit;
END calculate_credits;


/*9. Display how many subjects and credits was selected by student*/
CREATE OR REPLACE PACKAGE c_stud_information IS
    FUNCTION total_subject(
        p_stud_id IN course_selections.stud_id%TYPE) 
        RETURN NUMBER;
    
    FUNCTION total_credits(
        p_stud_id IN course_selections.stud_id%TYPE)
        RETURN NUMBER;
END c_stud_information;

CREATE OR REPLACE PACKAGE BODY c_stud_information IS
    /*return total subject*/
    FUNCTION total_subject(
        p_stud_id IN course_selections.stud_id%TYPE) 
        RETURN NUMBER IS
        
        CURSOR cur_stud IS
            SELECT DISTINCT cs.ders_kod, cs.credits FROM course_selections sel
                INNER JOIN course_sections cs ON cs.ders_kod = sel.ders_kod AND cs.section = sel.section
                WHERE sel.stud_id = p_stud_id;
        v_record    cur_stud%ROWTYPE;
        v_count_subject     NUMBER := 0;
    BEGIN
        OPEN cur_stud;
            LOOP
                FETCH cur_stud INTO v_record;
                EXIT WHEN cur_stud%NOTFOUND;
                v_count_subject := v_count_subject + 1;
            END LOOP;
        CLOSE cur_stud;
        
        RETURN v_count_subject;
    END total_subject;    
    
    /*return total credits*/
    FUNCTION total_credits(
        p_stud_id IN course_selections.stud_id%TYPE)
        RETURN NUMBER IS
            CURSOR cur_stud IS
            SELECT DISTINCT cs.ders_kod, cs.credits FROM course_selections sel
                INNER JOIN course_sections cs ON cs.ders_kod = sel.ders_kod AND cs.section = sel.section
                WHERE sel.stud_id = p_stud_id;
        v_record    cur_stud%ROWTYPE;
        v_count_credits       NUMBER := 0;
    BEGIN
        OPEN cur_stud;
            LOOP
                FETCH cur_stud INTO v_record;
                EXIT WHEN cur_stud%NOTFOUND;
                            
                v_count_credits := v_count_credits + v_record.credits;
            END LOOP;
        CLOSE cur_stud;
        
        RETURN v_count_credits;   
    END total_credits;
END c_stud_information;


/*
7. Design schedule of teacher on semester
8. Design schedule of student on semester*/
CREATE OR REPLACE PACKAGE my_schedule IS
    TYPE s_schedule IS RECORD (
        stud_id     course_selections.stud_id%TYPE,
        ders_kod    course_schedule.ders_kod%TYPE,
        section     course_schedule.section%TYPE,
        ders_time   VARCHAR2(60)
    );
    TYPE t_schedule IS RECORD (
        emp_id      course_sections.emp_id%TYPE, 
        ders_year   course_schedule.ders_year%TYPE, 
        ders_kod    course_schedule.ders_kod%TYPE,
        terms       course_schedule.terms%TYPE,
        section     course_schedule.section%TYPE,
        ders_time   VARCHAR2(60),
        ders_type   course_sections.ders_type%TYPE
    );
    TYPE stud_schedule IS TABLE OF s_schedule;
    TYPE schedule IS TABLE OF t_schedule;
    
    FUNCTION f_schedule_teacher(
        p_teacher_id IN NUMBER,
        p_year  IN NUMBER,
        p_terms IN NUMBER) 
        RETURN schedule PIPELINED;    
    
    FUNCTION f_schedule_student (
        p_stud_id IN course_selections.stud_id%TYPE,
        p_year  IN NUMBER,
        p_terms IN NUMBER)
        RETURN stud_schedule PIPELINED;
END my_schedule;

CREATE OR REPLACE PACKAGE BODY my_schedule IS
    FUNCTION f_schedule_teacher(
        p_teacher_id IN NUMBER,
        p_year  IN NUMBER,
        p_terms IN NUMBER) RETURN schedule PIPELINED IS
        v_collection    schedule;
    BEGIN
        SELECT DISTINCT cs.emp_id, csh.ders_year, csh.ders_kod, csh.terms, csh.section, TO_CHAR(csh.min_start_time, 'DD-MM-YY HH24:MI:SS'), cs.ders_type BULK COLLECT INTO v_collection FROM course_schedule csh 
        INNER JOIN course_sections cs ON 
            csh.section = cs.section AND 
            cs.ders_kod = csh.ders_kod AND 
            cs.ders_year = csh.ders_year 
        WHERE cs.ders_year = p_year AND 
            cs.terms = p_terms AND 
            cs.emp_id = p_teacher_id
        ORDER BY TO_CHAR(csh.min_start_time, 'DD-MM-YY HH24:MI:SS');
        
        FOR i IN v_collection.FIRST.. v_collection.LAST LOOP
            PIPE ROW(v_collection(i));
        END LOOP;
        
        RETURN;
    --    FOR i IN v_collection.FIRST .. v_collection.LAST LOOP
    --        DBMS_OUTPUT.PUT_LINE(v_collection(i).ders_time);
    --    END LOOP;
    END f_schedule_teacher;
    
    FUNCTION f_schedule_student(
        p_stud_id IN course_selections.stud_id%TYPE,
        p_year  IN NUMBER,
        p_terms IN NUMBER) RETURN stud_schedule PIPELINED IS
        v_collection    stud_schedule;
    BEGIN
       SELECT DISTINCT cs.stud_id, csh.ders_kod ,csh.section, TO_CHAR(csh.min_start_time, 'DD-MM-YY HH24:MI:SS') BULK COLLECT INTO v_collection FROM course_schedule csh 
            INNER JOIN course_selections cs ON 
                csh.section = cs.section AND 
                cs.ders_kod = csh.ders_kod AND 
                cs.ders_year = csh.ders_year 
            WHERE cs.ders_year = p_year AND 
                cs.terms = p_terms AND
                cs.stud_id = p_stud_id
            ORDER BY TO_CHAR(csh.min_start_time, 'DD-MM-YY HH24:MI:SS');
        
        FOR i IN v_collection.FIRST.. v_collection.LAST LOOP
            PIPE ROW(v_collection(i));
        END LOOP;
        
        RETURN;
    --    FOR i IN v_collection.FIRST .. v_collection.LAST LOOP
    --        DBMS_OUTPUT.PUT_LINE(v_collection(i).ders_time);
    --    END LOOP;
    END f_schedule_student;
END my_schedule;

/* Testing
SELECT * FROM TABLE(my_schedule.f_schedule_teacher(10088, 2016, 1));
SELECT * FROM TABLE(my_schedule.f_schedule_student('5A32EA748ECC7AD82077AAF9875135A16AC94F51', 2016, 1));
*/

/*11. Teachers rating for the semester(list)
12. Subject ratings for the semester (list)*/
CREATE OR REPLACE PACKAGE ratings IS
    TYPE demo IS RECORD (
        emp_id  course_sections.emp_id%TYPE,
        rating  NUMBER
    );
    TYPE teacher_rating IS TABLE OF demo;
    
    TYPE demo_sub IS RECORD (
        ders_kod course_sections.ders_kod%TYPE,
        rating NUMBER
    );
    TYPE subject_rating IS TABLE OF demo_sub;
    
    FUNCTION calc_rating(p_emp_id IN NUMBER,
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN NUMBER;
        
    FUNCTION get_emp_rating(
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN teacher_rating PIPELINED;
    
    FUNCTION calc_rating_subject(
        p_ders_kod IN course_sections.ders_kod%TYPE,
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN NUMBER;
    
    FUNCTION get_rating_subject(
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN subject_rating PIPELINED;
END ratings;

/**/
CREATE OR REPLACE PACKAGE BODY ratings IS
    -- calculate rating for teacher
    --
    --    
    FUNCTION calc_rating(p_emp_id IN NUMBER,
                        p_year IN NUMBER,
                        p_terms IN NUMBER) RETURN NUMBER IS
        v_students_count    NUMBER;
        v_count_selected    NUMBER;
        v_rating            NUMBER(8,3);
    BEGIN
        SELECT COUNT(stud_id) INTO v_students_count FROM (SELECT DISTINCT stud_id FROM course_selections WHERE ders_year = p_year AND terms = p_terms);
        SELECT COUNT(stud_id) INTO v_count_selected FROM (
            SELECT DISTINCT csh.stud_id, cs.ders_kod, cs.section, cs.emp_id FROM course_selections csh
                    INNER JOIN course_sections cs ON
                    cs.ders_kod = csh.ders_kod AND
                    cs.section = csh.section
                    WHERE emp_id = p_emp_id);
          
        v_rating := (5 * v_count_selected)/v_students_count;
        
        RETURN v_rating;
    END calc_rating;
    
    --   getting list of teacher ratings 
    --
    --
    FUNCTION get_emp_rating( 
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN teacher_rating PIPELINED IS
        v_table teacher_rating;
    BEGIN
        SELECT emp_id, calc_rating(emp_id, p_year, p_terms) BULK COLLECT INTO v_table FROM course_sections WHERE ders_year = p_year AND terms = p_terms;
        
        FOR i IN v_table.FIRST.. v_table.LAST LOOP
            PIPE ROW(v_table(i));
        END LOOP;
        RETURN;
    END get_emp_rating;
    
    --    
    -- calculate rating of subject
    --
    FUNCTION calc_rating_subject(
        p_ders_kod IN course_sections.ders_kod%TYPE,
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN NUMBER IS
         
        v_students_count    NUMBER;
        v_count_selected_s    NUMBER;
        v_rating            NUMBER(8,3);
    BEGIN
        SELECT COUNT(stud_id) INTO v_students_count FROM (SELECT DISTINCT stud_id FROM course_selections WHERE ders_year = p_year AND terms = p_terms);
        SELECT COUNT(ders_kod) INTO v_count_selected_s FROM course_selections WHERE ders_kod = p_ders_kod;
        
         v_rating := (5 * v_count_selected_s)/v_students_count;
        
        RETURN v_rating;
    END calc_rating_subject;
    
    FUNCTION get_rating_subject(
        p_year IN NUMBER,
        p_terms IN NUMBER) RETURN subject_rating PIPELINED IS
        v_table subject_rating;
    BEGIN
        SELECT ders_kod, calc_rating_subject(ders_kod, p_year, p_terms) BULK COLLECT INTO v_table FROM course_selections WHERE ders_year = p_year AND terms = p_terms;
        
        FOR i IN v_table.FIRST.. v_table.LAST LOOP
            PIPE ROW(v_table(i));
        END LOOP;
        RETURN;  
    END get_rating_subject;
END ratings;
/* Testing
SELECT * FROM TABLE(ratings.get_emp_rating(2016,1));
*/

/**/
CREATE OR REPLACE FUNCTION get_clever_flow(
    p_emp_id IN NUMBER,
    p_ders_kod IN course_selections.ders_kod%TYPE) RETURN course_sections.section%TYPE IS

    TYPE t_type IS RECORD (
        v_ders_kod  course_sections.ders_kod%TYPE,
        v_section   course_sections.section%TYPE,
        v_emp_id    course_sections.emp_id%TYPE,
        v_stud_id   course_selections.stud_id%TYPE,
        v_grade     course_selections.qiymet_yuz%TYPE
    );
    
    TYPE t_count_sel IS TABLE OF t_type;
    CURSOR cur_sections IS 
        SELECT DISTINCT section FROM course_sections WHERE ders_kod = p_ders_kod AND emp_id = p_emp_id;
        
    v_selection     t_count_sel;
    v_max_section   course_selections.ders_kod%TYPE;
    v_avg      NUMBER;
    v_max           NUMBER := 0;
    
    v_sum NUMBER := 0;
    v_count NUMBER := 0;
BEGIN
    FOR v_record IN cur_sections LOOP
        SELECT DISTINCT cs.ders_kod, cs.section, cs.emp_id, csh.stud_id, csh.qiymet_yuz BULK COLLECT INTO v_selection 
                FROM course_sections cs INNER JOIN course_selections csh ON cs.ders_kod = csh.ders_kod AND cs.terms = csh.terms
            WHERE cs.ders_kod = p_ders_kod AND cs.emp_id = p_emp_id AND cs.section = v_record.section;
        
        FOR i IN v_selection.FIRST .. v_selection.LAST LOOP
            v_sum := v_sum + v_selection(i).v_grade;    
            v_count := v_count + 1;
        END LOOP;

        v_avg := v_sum/v_count;        
        
        IF (v_avg > v_max) THEN
            v_max := v_avg;
            v_max_section := v_record.section;
        END IF;
    END LOOP;
    
    RETURN v_max_section;
END;

/*
TESTING
BEGIN 
    DBMS_OUTPUT.PUT_LINE(get_clever_flow(10284, 'RUS 101'));
END;
*/

/*1) Find most popular courses for semester (You should pass a number of
semester and year, and output list of courses with teachers )*/
CREATE OR REPLACE PROCEDURE pro_top_subject(
    p_ders_year IN NUMBER,
    p_term  IN NUMBER) IS
    CURSOR cur_top IS 
        SELECT * FROM (
            SELECT ders_kod, emp_id, COUNT(stud_id) as counts FROM (
                SELECT DISTINCT cs.ders_kod, cs.emp_id, csh.stud_id, csh.section FROM course_sections cs
                    INNER JOIN course_selections csh ON csh.section = cs.section AND csh.ders_kod = cs.ders_kod
                    WHERE csh.ders_year = p_ders_year AND cs.ders_year = p_ders_year AND csh.terms = p_term)
            GROUP BY ders_kod, emp_id
            ORDER BY counts DESC)
        WHERE ROWNUM <= 3;
BEGIN
    FOR v_record IN cur_top LOOP
        DBMS_OUTPUT.PUT_LINE('Ders: ' || v_record.ders_kod || ', Teacher: ' || v_record.emp_id || ', Count: ' || v_record.counts);
    END LOOP;
END;

/* TESTING
BEGIN
    pro_top_subject(2016,1);
END;
*/

/*
2) Find most popular teacher in section for semester (You should pass a
number of semester and year and code of subject, and output teacher
practice and lecture ) For example Programming technology lecture
instructors: Instructor1, Instructor2. Practice instructors : Teacher1,teacher2,
teacher3
*/
CREATE OR REPLACE PROCEDURE top_teachers(
    p_ders_year IN NUMBER,
    p_terms IN NUMBER,
    p_ders_type IN course_sections.ders_type%TYPE) IS
    CURSOR cur_top IS 
        SELECT * FROM (
            SELECT ders_kod, emp_id, ders_type, COUNT(stud_id) as counts FROM (
                SELECT DISTINCT cs.ders_kod, cs.emp_id, csh.stud_id, csh.section, cs.ders_type FROM course_sections cs
                    INNER JOIN course_selections csh ON csh.section = cs.section AND csh.ders_kod = cs.ders_kod
                    WHERE csh.ders_year = p_ders_year AND cs.ders_year = p_ders_year AND csh.terms = p_terms AND cs.ders_type = p_ders_type)
            GROUP BY ders_kod, emp_id, ders_type
            ORDER BY counts DESC)
        WHERE ROWNUM <= 3;    
BEGIN
    FOR v_record IN cur_top LOOP
        DBMS_OUTPUT.PUT_LINE('Ders: ' || v_record.ders_kod || ', Teacher: ' || v_record.emp_id || ', Ders type: ' || v_record.ders_type || ', Count: ' || v_record.counts);
    END LOOP;
END;

/* TESTING
BEGIN
    top_teachers(2016,1,'P');
END;
*/

