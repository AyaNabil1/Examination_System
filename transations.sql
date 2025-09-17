BEGIN TRY
    BEGIN TRANSACTION;

    -- 1) Create a new exam
    EXEC sp_CreateExam   
         @Ex_id = 2077,
         @ex_name = 'data base ex',
         @ex_type = 'normal',
         @ex_grade = 100,
         @inst_id = 50,
         @Crs_ID = 201,
         @date = '10-10-2025',
         @start_time = '15:00',
         @end_time = '17:00'

    -- 2) Add questions to the exam (Manual mode)
    EXEC sp_AddExamQuestions 
         @Ex_Id = 2077, 
         @Mode = 'Manual', 
         @QuestionIds = '7,8'

    -- 3) Enroll students to the exam (Normal exam)
    EXEC sp_EnrollStudentsToExam 
         @Ex_Id = 2077

    -- Commit transaction if everything is successful
    COMMIT TRANSACTION;
    PRINT 'Transaction completed successfully.';

END TRY
BEGIN CATCH
    -- Rollback transaction in case of any error
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
