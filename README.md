Table description.
Table: Course_schedule
DERS_KOD – course code (code of subject)
YEAR – year when subject was conducted
TERM – 1 – Fall, 2-Spring
DERS_S_ID –
SECTION –
MIN(START_TIME) – time of subject on week by schedule
Table: Course_sections
DERS_SOBE_ID –
DERS_KOD – course code (code of subject)
YEAR – year when subject was conducted
TERM – 1 – Fall, 2-Spring
SECTION –
TYPE – N,L – lection P- practice
EMP_ID – id teacher, instructor
MESSAGE – comment
WEEK_NUM – how many weeks
HOUR_NUM – how many hours for semester
PACKET_DERS – skip
ATTEND_TYPE – skip
PAID_SECTION – skip
EMP_ID_ENT – id teacher, instructor who can inter marks
LAST_MODIFIED – last marks modified time
Credits – number of credits
Table: Course_selections
STUD_ID – id student
DERS_KOD – course code (code of subject)
YEAR – year
TERM - 1 – Fall, 2-Spring
SECTION – section
LAB_SOBE_ID - skip
QIYMET_YUZ – total mark of the course
QIYMET_HERF - total mark of the course
GRADING_TYPE – PNP –pass no pass, N - standart
ATTENDED -skip
PRACTICE – practice teacher
REG_DATE – registration time

Issues
1. Find most popular courses for semester (You should pass a number of
semester and year, and output list of courses with teachers )
2. Find most popular teacher in section for semester (You should pass a
number of semester and year and code of subject, and output teacher
practice and lecture ) For example Programming technology lecture
instructors: Instructor1, Instructor2. Practice instructors : Teacher1,teacher2,
teacher3
3. Calculate GPA of student for the semester and total
4. Find students who didn’t register any subjects for one semester
5. Calculate how much money the student spent on retakes for the given
semester (included) and total spent.
6. Calculate the teachers’ “loading” (how many hours Teacher have for given
semester)
7. Design schedule of teacher on semester
8. Design schedule of student on semester
9. Display how many subjects and credits was selected by student
10. Find most clever flow of students by the average rating for the one subject in
one teacher.
11. Teachers rating for the semester(list)
12. Subject ratings for the semester (list)
13. Calculate total number of retakes for all time and display the profit.
Conditions:
For getting good mark for the project, you must include frontEnd, and have all
structures of PL/SQL, which we have studied:

 Functions,
 Procedures,
 Cursors,
 Packages,
 Transactions,
 triggers,
 Collections,
 records,
 Dynamic SQL
 etc.
Warning:

If the logical part will be similar to some other student it will be cheating because I
especially do not describe all issues in detail for your free-thinking and
implementation.# DatabaseOracleProject
