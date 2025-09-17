create view question_choice_answer
as
select q.question_id,q.question_text , q.question_type , q.inst_id  ,q.crs_id , c.choice_id , c.choice_text , c.is_correct from choice c join question q
on c.question_id= q.question_id

select *from question_choice_answer

---------------------------------------------------------------------------------
create view student_course
as
select stud_id , ct.crs_id , c.inst_id
from student s join course_track ct
on s.track_id = ct.track_id
join course c 
on ct.crs_id=c.crs_id

select * from student_course
order by stud_id
-----------------------------------------------------------------------------------------
create or alter view vw_stud_crs_result
as 
select r.exam_id,r.stud_id,r.percentage,e.crs_id,e.inst_id,e.exam_type
from result r join exam e
on e.exam_id=r.exam_id

select *
from vw_stud_crs_result

---------------------------------------------------------------------------------------
/*create view vw_ExamSchedule
as
select 
    E.exam_id,
    E.exam_type,
    E.exam_grade,
    E.start_time,
    E.end_time,
    C.crs_name,
    I.inst_id,
    i.f_name

from Exam E
inner join Course C 
    on E.crs_id = C.crs_id
inner join Instructor I 
    on E.inst_id = I.inst_id
inner join course_track TC 
    on C.crs_id = TC.crs_id


where E.start_time > getdate() 
GROUP BY 
    E.exam_id, E.exam_type, E.exam_grade,
    E.start_time, E.end_time, 
    C.crs_id, C.crs_name,
    I.inst_id, i.f_name;
go
select * from vw_ExamSchedule
*/