--Create Database using default location
USE master
GO

IF DB_ID ('School_Management_System_DB') IS NOT NULL
DROP DATABASE School_Management_System_DB;

DECLARE @data_path nvarchar(256);
SET @data_path = ( SELECT SUBSTRING(physical_name,1, CHARINDEX(N'master.mdf', LOWER(physical_name))-1)
	FROM master.sys.master_files
	WHERE database_id=1 AND file_id=1
);

EXECUTE ('CREATE DATABASE School_Management_System_DB
ON PRIMARY (NAME=School_Management_System_DB_data, FILENAME='''+@data_path+'School_Management_System_DB_data.mdf'', SIZE=20MB, MAXSIZE=Unlimited, FILEGROWTH=5%)
LOG ON (NAME=School_Management_System_DB_log, FILENAME='''+@data_path+'School_Management_System_DB_log.ldf'', SIZE=10MB, MAXSIZE=100MB, FILEGROWTH=2MB)
');
GO

USE School_Management_System_DB
GO

--Alter Database to Modify size

ALTER DATABASE School_Management_System_DB 
MODIFY FILE (Name=School_Management_System_DB_data, SIZE= 25MB);
GO

-- Schema Creation
CREATE SCHEMA sm
GO

--Create Tables 

USE School_Management_System_DB
CREATE TABLE sm.Teachers
(
	TeacherID int NOT NULL IDENTITY PRIMARY KEY,
	TeacherName varchar(40) NOT NULL,
	Email varchar(40)  NULL,
	MobileNo varchar(15) NOT NULL
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Students
(
	StudentID int NOT NULL IDENTITY PRIMARY KEY,
	StudentName	varchar(25) NOT NULL,
	BirthDate date NOT NULL,
	Gender varchar(10) NOT NULL,
	FatherName	varchar(25) NOT NULL,
	MotherName varchar(25) NOT NULL,
	MobileNo varchar(15) CHECK ((MobileNo Like '[0][1][0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]')) NULL, 
	ParentsMobileNo varchar(15) CHECK ((ParentsMobileNo Like '[0][1][0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]')) NOT NULL,
	[Address] nvarchar(40) NOT NULL
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Classes
(
	ClassID int NOT NULL PRIMARY KEY,
	ClassName varchar(10) NOT NULL
);
GO

CREATE TABLE sm.Sections
(
	SectionID int IDENTITY PRIMARY KEY,
	SectionName varchar(10)
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Student_Class
(
	StudentID int FOREIGN KEY REFERENCES sm.Students(StudentID),
	ClassID int FOREIGN KEY REFERENCES sm.Classes(ClassID),
	SectionID int FOREIGN KEY REFERENCES sm.Sections(SectionID)
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Teacher_Class
(
	TeacherID int FOREIGN KEY REFERENCES sm.Teachers(TeacherID),
	ClassID int FOREIGN KEY REFERENCES sm.Classes(ClassID),
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Subjects
(
	SubjectID int NOT NULL IDENTITY PRIMARY KEY,
	SubjectName varchar(30) NOT NULL,
	TeacherID int FOREIGN KEY REFERENCES sm.Teachers(TeacherID),
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Grades
(
	GradeID int IDENTITY PRIMARY KEY,
	GradePoint char(2) NOT NULL,
	[Range] varchar(10) NOT NULL
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Results
(
	StudentID int FOREIGN KEY REFERENCES sm.Students(StudentID),
	TotalGradePoints int FOREIGN KEY REFERENCES sm.Grades(GradeID)
);
GO

USE School_Management_System_DB
CREATE TABLE sm.Payments
(
	PaymentID int IDENTITY,
	StudentID int FOREIGN KEY REFERENCES sm.Students(StudentID),
	TotalFees money DEFAULT '1200',
	AmountPaid money NOT NULL
);
GO

--Local & global temporary table
CREATE TABLE #Guardian
(
	GuardianID int IDENTITY PRIMARY KEY,
	StudentID int NOT NULL,
	GuardianName varchar(30) NOT NULL,
	Phone varchar(15) NOT NULL,
	Email varchar(30) NULL
);
GO

CREATE TABLE ##Courses 
(
	CourseID int IDENTITY PRIMARY KEY,
	StudentID int NOT NULL,
	SubjectID int SPARSE NULL,
	Grade int
);
GO

--Drop tables
DROP TABLE #Guardian
GO

DROP TABLE ##Courses
GO

--Alter table:add and drop column
ALTER TABLE sm.Teachers
ADD DEFAULT 'N/A' FOR Email

ALTER TABLE sm.Students
ADD Picture varbinary(max) 
GO

ALTER TABLE sm.Students
DROP COLUMN Picture
GO

--Created Clustered Index and NonClustered Index
CREATE CLUSTERED INDEX CI_PayID ON sm.Payments(PaymentID)
GO

CREATE NONCLUSTERED INDEX NCI_Mobile ON sm.Students(MobileNo)
GO

--Create sequence
USE School_Management_System_DB
CREATE SEQUENCE sq_Class
AS bigint
START WITH 01
INCREMENT BY 1
MINVALUE 1
MAXVALUE 10
NO CYCLE
CACHE 10
GO

--Create View 
CREATE VIEW vw_Classes
AS
SELECT ClassID,ClassName
FROM sm.Classes
GO

--Create View With Encryption
CREATE VIEW vw_Teachers
WITH ENCRYPTION
AS
SELECT TeacherID,TeacherName 
FROM sm.Teachers
GO

--Create View With Schemabinding
CREATE VIEW vw_Grades
WITH SCHEMABINDING
AS
SELECT GradeID,GradePoint,[Range]
FROM sm.Grades
GO

--Create Procedure
CREATE proc sp_subjects
@subjectid int,
@subjectname varchar(30),
@teacherid int,
@operationname varchar(30),
@tablename varchar(30)
AS
BEGIN
	IF (@tablename= 'Subjects' and @operationname='Insert')
		BEGIN
			INSERT INTO sm.Subjects VALUES(@subjectname,@teacherid)
		END
	IF (@tablename='Subjects' and @operationname='Update')
		BEGIN
			UPDATE sm.Subjects SET TeacherID=@teacherid WHERE SubjectID=@subjectid
		END
	IF (@tablename='Subjects' and @operationname='Delete')
		BEGIN
			DELETE FROM sm.Subjects WHERE SubjectID=@subjectid
		END
	IF (@tablename='Subjects' and @operationname='Select')
		BEGIN
			SELECT * FROM sm.Subjects
		END
END
GO

--Transaction(Commit, Rollback, Try, Catch) with Procedure
CREATE PROC sp_AdmissionDetails
@paymentid int,
@studentid int,
@totalfees money,
@amountpaid money,
@message varchar(30) output	 
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO sm.Payments
			VALUES (@studentid,@totalfees,@amountpaid)
			SET @message='Data Inserted Successfully'
			PRINT @message
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION	
		PRINT 'Something goes wrong !!!!!'
	END CATCH
END
GO

CREATE TABLE sm.Teachers_Tr
(
	TeacherID int, 
	TeacherName varchar(40),
	Email varchar(40),
	MobileNo varchar(15),
	AauditAction varchar(50),
	ActionTime datetime
);
GO

--Create After Trigger
CREATE TRIGGER tr_After_Insert_Course ON sm.Teachers
FOR INSERT
AS
DECLARE @teacherid int, @teachername varchar(40), @email varchar(40), @mobileno varchar(11), @auditaction varchar(30) 
SELECT @teacherID=i.TeacherID from inserted as i;
SELECT @teachername=i.TeacherName from inserted as i;
SELECT @email=i.Email from inserted i;
SELECT @mobileno=i.MobileNo from inserted as i;
SET @auditaction='Row has been Inserted in Teachers Table';
INSERT INTO sm.Teachers_Tr
VALUES (@teacherid, @teachername, @email, @mobileno, @auditaction, GETDATE());
PRINT 'After Trigger Fired For Insert'
GO

--Create Instead Of Trigger For Setting Limit of 1 Row Update and Delete at a time
CREATE TRIGGER trg_update_delete ON sm.Teachers_tr
INSTEAD OF UPDATE, DELETE
AS
DECLARE @rowcount int
SET @rowcount=@@ROWCOUNT
IF(@rowcount>1)
				BEGIN
				RAISERROR('You cannot Update or Delete more than 1 Record',16,1)
				END
ELSE 
	PRINT 'Update or Delete Successful'
GO

--Create Tabular Function
CREATE FUNCTION fn_tabular_Pmdue()
RETURNS TABLE
AS
RETURN
(
	SELECT s.StudentID, s.StudentName, s.MobileNo, s.FatherName, s.ParentsMobileNo , s.[Address], p.PaymentID, p.AmountPaid, p.TotalFees
	FROM sm.Students s
	JOIN sm.Payments p
	ON s.StudentID=p.StudentID
	WHERE p.AmountPaid=p.TotalFees
)
GO

SELECT * FROM dbo.fn_tabular_Pmdue()
GO

--Create Scalar Function
CREATE FUNCTION fn_TotalAmount_Get()
RETURNS money
AS
BEGIN
	RETURN
	(
	SELECT Sum(AmountPaid) AS [Total Amount Get]
	FROM sm.Payments
	)
END
GO

PRINT dbo.fn_TotalAmount_Get()
GO

