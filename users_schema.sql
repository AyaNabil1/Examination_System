------------------------------------------------------
-- 1) Create Schemas
------------------------------------------------------
GO
CREATE SCHEMA Academic;
GO
CREATE SCHEMA Exam;
GO
CREATE SCHEMA QuestionBank;
GO

-- Move tables to their appropriate schemas (edit table names if different)
ALTER SCHEMA Academic TRANSFER dbo.Student;
ALTER SCHEMA Academic TRANSFER dbo.Instructor;
ALTER SCHEMA Academic TRANSFER dbo.Course;

ALTER SCHEMA Exam TRANSFER dbo.Exam;
ALTER SCHEMA Exam TRANSFER dbo.Exam_Question;
ALTER SCHEMA Exam TRANSFER dbo.Student_Exam;
ALTER SCHEMA Exam TRANSFER dbo.Student_Exam_Question;
ALTER SCHEMA Exam TRANSFER dbo.Result;
ALTER SCHEMA Exam TRANSFER dbo.question_choice_answer;

ALTER SCHEMA QuestionBank TRANSFER dbo.Question;
ALTER SCHEMA QuestionBank TRANSFER dbo.Choice;

-- Move stored procedures to Exam schema
ALTER SCHEMA Exam TRANSFER dbo.CreateExam;
ALTER SCHEMA Exam TRANSFER dbo.sp_AddExamQuestions;
ALTER SCHEMA Exam TRANSFER dbo.sp_EnrollStudentsToExam;
ALTER SCHEMA Exam TRANSFER dbo.sp_AssignQuestionsToStudent;
ALTER SCHEMA Exam TRANSFER dbo.sp_SaveStudentAnswers;
ALTER SCHEMA Exam TRANSFER dbo.sp_CalculateFinalResult;
ALTER SCHEMA Exam TRANSFER dbo.sp_ShowStudentExam;

------------------------------------------------------
-- 2) Create Roles
------------------------------------------------------
CREATE ROLE AdminRole;
CREATE ROLE ManagerRole;
CREATE ROLE InstructorRole;
CREATE ROLE StudentRole;

------------------------------------------------------
-- 3) Create Users (with corresponding Logins)
------------------------------------------------------
-- Admin
CREATE LOGIN admin WITH PASSWORD = 'Admin@123';
CREATE USER admin FOR LOGIN admin;
ALTER ROLE AdminRole ADD MEMBER admin;

-- Manager
CREATE LOGIN manager WITH PASSWORD = 'Manager@123';
CREATE USER manager FOR LOGIN manager;
ALTER ROLE ManagerRole ADD MEMBER manager;

-- Instructor
CREATE LOGIN instructor WITH PASSWORD = 'Instructor@123';
CREATE USER instructor FOR LOGIN instructor;
ALTER ROLE InstructorRole ADD MEMBER instructor;

-- Student
CREATE LOGIN student WITH PASSWORD = 'Student@123';
CREATE USER student FOR LOGIN student;
ALTER ROLE StudentRole ADD MEMBER student;

------------------------------------------------------
-- 4) Assign Permissions
------------------------------------------------------

-- Admin: full control on the database
GRANT CONTROL ON DATABASE::examination_system TO AdminRole;

-- Manager: CRUD on Academic + Exam, read-only on QuestionBank
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Academic TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Exam TO ManagerRole;
GRANT SELECT ON SCHEMA::QuestionBank TO ManagerRole;

-- Instructor: access to exam procedures + read-only on QuestionBank
GRANT EXECUTE ON OBJECT::Exam.CreateExam TO InstructorRole;
GRANT EXECUTE ON OBJECT::Exam.sp_AddExamQuestions TO InstructorRole;
GRANT EXECUTE ON OBJECT::Exam.sp_EnrollStudentsToExam TO InstructorRole;
GRANT EXECUTE ON OBJECT::Exam.sp_AssignQuestionsToStudent TO InstructorRole;
GRANT EXECUTE ON OBJECT::Exam.sp_CalculateFinalResult TO InstructorRole;
GRANT SELECT ON SCHEMA::QuestionBank TO InstructorRole;
GRANT SELECT ON SCHEMA::Exam TO InstructorRole;
GRANT EXECUTE ON OBJECT::Exam.sp_SaveStudentAnswers TO InstructorRole;
GRANT SELECT ON OBJECT::Exam.question_choice_answer TO InstructorRole;
-- Student: can take exams, submit answers, and view results
GRANT EXECUTE ON OBJECT::Exam.sp_ShowStudentExam TO StudentRole;
GRANT EXECUTE ON OBJECT::Exam.sp_CalculateFinalResult TO StudentRole;

