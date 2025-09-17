CREATE OR ALTER TRIGGER trg_Exam_Corrective_Check
ON Exam
instead of INSERT
AS
BEGIN
   -- SET NOCOUNT ON;

    -- If the new exam is corrective and there is no previous normal exam for the same course
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.exam_type = 'corrective'
          AND NOT EXISTS (
              SELECT 1
              FROM Exam e
              WHERE e.crs_id = i.crs_id
                AND e.exam_type = 'normal'
          )
    )
    BEGIN
        RAISERROR('Cannot create corrective exam without a previous normal exam in this course.', 16, 1);
        RETURN; -- Stop trigger execution without inserting
    END

    -- If conditions are satisfied, proceed with the insert
    INSERT INTO Exam (exam_id,exam_name,exam_type, date,start_time,end_time,exam_grade,inst_id,crs_id)
    SELECT exam_id,exam_name,exam_type, date,start_time,end_time,exam_grade,inst_id,crs_id
    FROM inserted;
END;
