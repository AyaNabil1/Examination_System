CREATE OR ALTER PROCEDURE sp_CreateExam
    @Ex_id INT,
    @ex_name VARCHAR(50), 
    @ex_type VARCHAR(10),
    @ex_grade INT,
    @inst_id INT,
    @Crs_ID INT,
    @date DATE,
    @start_time TIME,
    @end_time TIME
AS
BEGIN TRY
    -- Check if the course exists in the system
    IF NOT EXISTS (SELECT * FROM Course WHERE Crs_ID = @Crs_ID)
    BEGIN
        SELECT 'The course does not exist' AS 'ErrMessage'
    END

    -- Check if the given instructor is assigned to the specified course
    ELSE IF NOT EXISTS (
        SELECT 1 
        FROM Course 
        WHERE Crs_ID = @Crs_ID AND inst_id = @inst_id
    )
    BEGIN
        SELECT 'This course does not belong to the given instructor' AS 'ErrMessage'
    END

    -- Validate that the exam grade does not exceed the course maximum degree
    ELSE IF EXISTS (
        SELECT 1 
        FROM Course 
        WHERE Crs_ID = @Crs_ID AND @ex_grade > max_degree
    )
    BEGIN
        SELECT 'Exam grade cannot exceed the course maximum degree' AS 'ErrMessage'
    END
	  -- Validate that the exam start time does not exceed the end time

	 ELSE IF EXISTS (
        SELECT 1 
        FROM exam
        WHERE @start_time >= @end_time 
    )
    BEGIN
        SELECT 'end time must be greater than start time' AS 'ErrMessage'
    END

    -- If all validations pass, insert the exam record into the Exam table
    ELSE
    BEGIN
        INSERT INTO Exam (exam_id, exam_name, exam_type, exam_grade, inst_id, crs_id, date, start_time, end_time)
        VALUES (@Ex_id, @ex_name, @ex_type, @ex_grade, @inst_id, @Crs_ID, @date, @start_time, @end_time)
        -- Success message
        SELECT 'Exam created successfully' AS Message
    END
END TRY
BEGIN CATCH
    -- Catch any unexpected SQL errors and return the error message
    SELECT ERROR_MESSAGE() AS errorMessage
END CATCH
GO
------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_AddExamQuestions
    @Ex_Id INT,
    @Mode NVARCHAR(10),   -- 'Manual' OR 'Random'
    @QuestionIds NVARCHAR(MAX) = NULL, -- if Manual: "1,2,3"
    @NumMCQ INT = NULL,   -- if Random
    @NumTF INT = NULL     -- if Random
AS
BEGIN TRY
    -- Check if exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @Ex_Id)
    BEGIN
        SELECT 'The exam does not exist' AS 'ErrMessage'
        RETURN
    END

    -- Get course id of the exam
    DECLARE @crs_id INT
    SELECT @crs_id = crs_id FROM exam.Exam WHERE exam_id = @Ex_Id

    -- Manual mode (questions passed as IDs)
    IF @Mode = 'Manual'
    BEGIN
        -- Validate that all selected questions belong to the same course
        IF EXISTS (
            SELECT value
            FROM STRING_SPLIT(@QuestionIds, ',') s
            LEFT JOIN Question Q ON Q.question_id = s.value
            WHERE Q.crs_id <> @crs_id OR Q.crs_id IS NULL
        )
        BEGIN
            SELECT 'One or more questions do not belong to the same course as the exam' AS 'ErrMessage'
            RETURN
        END

        -- Insert manual questions into Exam_Question table
        INSERT INTO Exam_Question(exam_id, question_id)
        SELECT @Ex_Id, CAST(value AS INT)
        FROM STRING_SPLIT(@QuestionIds, ',')
    END

    -- Random mode (system selects questions randomly by type)
    ELSE IF @Mode = 'Random'
    BEGIN
        -- Select random MCQ questions
        INSERT INTO Exam_Question(exam_id, question_id)
        SELECT TOP(@NumMCQ) @Ex_Id, Q.question_id
        FROM Question Q
        WHERE Q.crs_id = @crs_id
          AND Q.question_type = 'MCQ'
        ORDER BY NEWID()

        -- Select random True/False questions
        INSERT INTO Exam_Question(exam_id, question_id)
        SELECT TOP(@NumTF) @Ex_Id, Q.question_id
        FROM Question Q
        WHERE Q.crs_id = @crs_id
          AND Q.question_type = 'True/False'
        ORDER BY NEWID()
    END

    -- Invalid mode (neither Manual nor Random)
    ELSE
    BEGIN
        RAISERROR('Invalid mode. Use Manual or Random',16,1)
    END
END TRY
BEGIN CATCH
    -- Catch and show any error message
    SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH
GO
--------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_EnrollStudentsToExam
    @Ex_Id INT
AS
BEGIN TRY
    -- 1) Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @Ex_id)
    BEGIN
        SELECT 'The exam does not exist' AS 'ErrMessage'
        RETURN
    END

    -- Declare variables to store course ID and exam type
    DECLARE @Crs_Id INT, @Ex_Type VARCHAR(20)
    SELECT @Crs_Id = crs_id, @Ex_Type = exam_type
    FROM Exam WHERE exam_id = @Ex_id

    -- 2) Case: exam type = normal
    IF @Ex_Type = 'normal'
    BEGIN
        -- Enroll student if:
        -- - He is registered in the course
        -- - He has not taken any exam for this course before
        INSERT INTO Student_Exam(stud_id, exam_id)
        SELECT SC.stud_id, @Ex_Id
        FROM Student_Course SC
        WHERE SC.crs_id = @Crs_Id
          AND NOT EXISTS (
              SELECT 1
              FROM Student_Exam SE
              JOIN Exam E ON SE.exam_id = E.exam_id
              WHERE SE.stud_id = SC.stud_id
                AND E.crs_id = @Crs_Id
          )
    END

    -- 3) Case: exam type = corrective
    ELSE IF @Ex_Type = 'corrective'
    BEGIN
        -- Enroll students who scored < 60% in a normal exam for this course
        INSERT INTO Student_Exam(stud_id, exam_id)
        SELECT SC.stud_id, @Ex_Id
        FROM Student_Course SC
        WHERE SC.crs_id = @Crs_Id
          AND EXISTS (
              SELECT 1
              FROM Student_Exam SE
              JOIN Exam E ON SE.exam_id = E.exam_id
              WHERE SE.stud_id = SC.stud_id
                AND E.crs_id = @Crs_Id
                AND E.exam_type = 'normal'
                AND (
                      SELECT (CAST(SUM(Stud_Score) AS DECIMAL(5,2)) / COUNT(*)) * 100
                      FROM Student_Exam_Question
                      WHERE stud_id = SE.stud_id
                        AND exam_id = SE.exam_id
                    ) < 60
          )

        -- Validation after insertion
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'This student already passed with >= 60% and cannot enroll in corrective exam' AS Message
        END
        ELSE
        BEGIN
            SELECT 'Students enrolled in corrective exam' AS Message
        END
    END
END TRY
BEGIN CATCH
    -- Catch any SQL error and return its message
    SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH
GO
--------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_AssignQuestionsToStudent
    @ex_id INT
AS
BEGIN TRY
    -- 1) Validate that the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @Ex_id)
    BEGIN
        SELECT 'The exam does not exist' AS 'ErrMessage'
        RETURN
    END

    -- 2) Insert questions into Student_Exam_Question for each student enrolled in the exam
    INSERT INTO Student_Exam_Question(stud_id, exam_id, question_id)
    SELECT 
        se.stud_id, 
        se.exam_id, 
        eq.question_id
    FROM Exam_Question eq
    JOIN Student_Exam se 
        ON se.exam_id = eq.exam_id
    WHERE se.exam_id = @ex_id
      AND NOT EXISTS (
            SELECT 1 
            FROM Student_Exam_Question seq
            WHERE seq.stud_id = se.stud_id 
              AND seq.exam_id = se.exam_id 
              AND seq.question_id = eq.question_id
      )
END TRY
BEGIN CATCH
    -- Return error if assignment fails
    SELECT ERROR_MESSAGE() AS errorMessage
END CATCH
GO
---------------------------------------------------------------------------------------------------------------------------------------------

-- Define a Table Type for student answers
CREATE TYPE StudentAnswerTableType AS TABLE
(
    Question_Id INT,
    Stud_Answer INT
)
GO

CREATE OR ALTER PROCEDURE sp_SaveStudentAnswers
    @stud_id INT,
    @ex_id INT,
    @Answers StudentAnswerTableType READONLY
AS
BEGIN TRY
    -- Step 1: Update student's answers in Student_Exam_Question
    UPDATE SEQ
    SET SEQ.stud_answer = A.Stud_Answer
    FROM Student_Exam_Question SEQ
    INNER JOIN @Answers A 
        ON SEQ.question_id = A.Question_Id
    WHERE SEQ.stud_id = @stud_id
      AND SEQ.exam_id = @ex_id

    -- Step 2: Calculate score for each question
    UPDATE SEQ
    SET Stud_Score = CASE WHEN C.Is_Correct = 'true' THEN 1 ELSE 0 END
    FROM Student_Exam_Question SEQ
    INNER JOIN @Answers A 
        ON SEQ.question_id = A.Question_Id
    INNER JOIN Choice C 
        ON SEQ.Question_id = C.question_id
       AND A.Stud_Answer = C.choice_id
    WHERE SEQ.exam_id = @ex_id
      AND SEQ.stud_id = @stud_id
END TRY
BEGIN CATCH
    -- Return the error message if any exception occurs
    SELECT ERROR_MESSAGE() AS errorMessage
END CATCH
GO
----------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_CalculateFinalResult
    @stud_id INT,
    @ex_id INT
AS
BEGIN TRY
    DECLARE 
        @TotalQuestions INT, 
        @TotalScore INT, 
        @Percentage DECIMAL(5,2)

    -- Get total number of questions in the exam for this student
    SELECT @TotalQuestions = COUNT(*)
    FROM Student_Exam_Question
    WHERE stud_id = @stud_id 
      AND exam_id = @ex_id

    -- Get student's total score (sum of Stud_Score values: 0 or 1)
    SELECT @TotalScore = SUM(Stud_Score)
    FROM Student_Exam_Question
    WHERE stud_id = @stud_id 
      AND exam_id = @ex_id

    -- Calculate percentage
    IF @TotalQuestions > 0
        SET @Percentage = (CAST(@TotalScore AS DECIMAL(5,2)) / 
                           CAST(@TotalQuestions AS DECIMAL(5,2))) * 100
    ELSE
        SET @Percentage = 0

    -- Return result details
    SELECT 
        @stud_id AS StudentID,
        @ex_id AS ExamID,
        @TotalScore AS StudentScore,
        @TotalQuestions AS TotalQuestions,
        @Percentage AS Percentage

    -- Insert into Result table
    INSERT INTO Result(stud_id, exam_id, Percentage)
    VALUES (@stud_id, @ex_id, @Percentage)
END TRY
BEGIN CATCH
    -- Return error message if any exception occurs
    SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH
GO
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_ShowStudentExam
    @Stud_Id INT,
    @Ex_Id INT
AS
BEGIN
    -- Step 1: Check if the student is enrolled in the exam
    IF NOT EXISTS (
        SELECT 1 FROM student_exam
        WHERE stud_id = @Stud_Id AND exam_id = @Ex_Id
    )
    BEGIN
        RAISERROR('Student not enrolled in this exam', 16, 1)
        RETURN
    END

    -- Step 2: Retrieve exam questions with choices
    SELECT 
        Q.question_id,        -- Question ID
        Q.question_text,      -- Question text
        Q.question_type,      -- Question type (MCQ, True/False)
        C.choice_id,          -- Choice ID
        C.choice_text         -- Choice text
    FROM Exam_Question EQ
    JOIN Question Q 
        ON EQ.question_id = Q.question_id
    LEFT JOIN Choice C 
        ON Q.question_id = C.question_id
    WHERE EQ.exam_id = @Ex_Id
    ORDER BY Q.question_id, C.choice_id
END
GO
