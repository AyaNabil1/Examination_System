-- Execute sp_CreateExam
EXEC sp_CreateExam   
     @Ex_id = 2030,
     @ex_name = 'ai',
     @ex_type = 'normal',
     @ex_grade = 100,
     @inst_id = 51,
     @Crs_ID = 205,
     @date = '5-9-2026',
     @start_time ='10:00',
     @end_time ='12:00'

-- Execute sp_AddExamQuestions (Manual mode)
EXEC sp_AddExamQuestions 
     @Ex_Id = 2030, 
     @Mode = 'Manual', 
     @QuestionIds = '209,210'

-- Execute sp_AddExamQuestions (Random mode)
EXEC sp_AddExamQuestions 
     @Ex_Id = 2030, 
     @Mode = 'Random', 
     @NumMCQ = 2, 
     @NumTF = 2


-- Execute sp_EnrollStudentsToExam (Normal exam)
EXEC sp_EnrollStudentsToExam 
     @Ex_Id = 2030

-- Execute sp_AssignQuestionsToStudent
EXEC sp_AssignQuestionsToStudent 
     @ex_id = 2030


-- Execute sp_SaveStudentAnswers
DECLARE @StudAnswers StudentAnswerTableType;

INSERT INTO @StudAnswers (Question_Id, Stud_Answer)
VALUES (209, 724),
       (210, 729)

EXEC sp_SaveStudentAnswers 
     @stud_id = 507, 
     @ex_id = 2030, 
     @Answers = @StudAnswers


-- Execute sp_CalculateFinalResult
EXEC sp_CalculateFinalResult
     @stud_id = 507, 
     @ex_id = 2030


-- Execute sp_ShowStudentExam
EXEC sp_ShowStudentExam 
     @Stud_Id = 506, 
     @Ex_Id = 2030

	select * 
	from result
------------------------------------------------------------------------------------------------------------------------------------------
-----test corrective exam------------------------
-- Execute sp_CreateExam
EXEC sp_CreateExam   
     @Ex_id = 2031,
     @ex_name = 'ai',
     @ex_type = 'corrective',
     @ex_grade = 100,
     @inst_id = 51,
     @Crs_ID = 205,
     @date = '10-9-2025',
     @start_time ='10:00',
     @end_time ='12:00'

-- Execute sp_AddExamQuestions (Manual mode)
EXEC sp_AddExamQuestions 
     @Ex_Id = 2031, 
     @Mode = 'Manual', 
     @QuestionIds = '209,210'

-- Execute sp_AddExamQuestions (Random mode)
EXEC sp_AddExamQuestions 
     @Ex_Id = 2027, 
     @Mode = 'Random', 
     @NumMCQ = 2, 
     @NumTF = 2

-- Execute sp_EnrollStudentsToExam (Corrective exam)
EXEC sp_EnrollStudentsToExam 
     @Ex_Id = 2031


-- Execute sp_AssignQuestionsToStudent
EXEC sp_AssignQuestionsToStudent 
     @ex_id = 2031


-- Execute sp_SaveStudentAnswers
DECLARE @StudAnswers StudentAnswerTableType;

INSERT INTO @StudAnswers (Question_Id, Stud_Answer)
VALUES (209, 724),
       (210, 729)

EXEC sp_SaveStudentAnswers 
     @stud_id = 507, 
     @ex_id = 2031, 
     @Answers = @StudAnswers


-- Execute sp_CalculateFinalResult
EXEC sp_CalculateFinalResult
     @stud_id = 507, 
     @ex_id = 2031


-- Execute sp_ShowStudentExam
EXEC sp_ShowStudentExam 
     @Stud_Id = 505, 
     @Ex_Id = 2027
