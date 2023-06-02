USE School_Management_System_DB
GO

--Select query and Insert values 
SELECT * FROM sm.Students
INSERT INTO sm.Students
	VALUES('Main Mahmud','2015-12-01','Male','Hasan Mahmud', 'Anwara Begum','01485 270 141','01485 260 344','Chittagong'),
			('Abir Mahmud','2016-10-01','Male','Ashraful Hasan', 'Jahanara Begum','01845 356 567','01685 780 344','Dhaka'),
			('Munna Islam','2017-12-21','Male','Azam Islam', 'Rokeya Ahmed','01785 700 231','01455 260 387','Chittagong'),
			('Israt Mahmud','2016-07-24','Female','Hasan Mahmud', 'Anwara Begum','01485 270 141','01485 260 344','Chittagong'),
			('Niloy Ahmed','2018-06-13','Male','Nur Hossain', 'Naima Alam','01985 470 156','01585 265 547','Rajshahi');
GO

SELECT * FROM sm.Teachers
INSERT INTO sm.Teachers
	VALUES('Jahed Islam','jahed.ctg@gmail.com','01532 142 010'),
			('Sourob Das','das.ctg@gmail.com','01554 4442 657'),
			('Foysal Hasan','hasan21@gmail.com','01762 562 770'),
			('Moin Islam','moin.ctg@gmail.com','01652 342 610'),
			('Karim Mia','karim540@gmail.com','01652 672 055');
GO

SELECT * FROM sm.Classes
INSERT INTO sm.Classes
	VALUES(NEXT VALUE FOR sq_Class,'CLASS 1'),(NEXT VALUE FOR sq_Class,'CLASS 2'),(NEXT VALUE FOR sq_Class,'CLASS 3'),(NEXT VALUE FOR sq_Class,'CLASS 4'),(NEXT VALUE FOR sq_Class,'CLASS 5');
GO

SELECT * FROM sm.Sections
INSERT INTO sm.Sections
	VALUES('A'),('B'),('C'),('D');
GO

SELECT * FROM sm.Subjects
INSERT INTO sm.Subjects
	VALUES('Bangla',1),('English',2),('Math',4),('Science',4),('Social Science',3),('Religion',5);
GO

--Insert with store procedure
EXEC sp_subjects 1,'Arts & Crafts',1,'Select','Subjects'
EXEC sp_subjects 1,'Arts & Crafts',1, 'Insert','Subjects'

--Insert with view
SELECT * FROM sm.Grades
SELECT * FROM vw_Grades

INSERT INTO vw_Grades
	VALUES('A+','80-100'),('A','70 – 79'),('A-','60 – 69'),('B','50 – 59'),('C','40 – 49'),('D','33 – 39'),('F','0 – 32');
GO

SELECT * FROM sm.Results
INSERT INTO sm.Results
	VALUES(1,1),(2,2),(3,4),(4,3),(5,2);
GO

SELECT * FROM sm.Payments
INSERT INTO sm.Payments
	VALUES(1,DEFAULT,1200),(2,DEFAULT,1000);
GO

SELECT * FROM sm.Teacher_Class
INSERT INTO sm.Teacher_Class
	VALUES(1,1),(2,2),(4,3),(5,4),(3,5);
GO

SELECT * FROM sm.Student_Class
INSERT INTO sm.Student_Class
	VALUES(1,3,2),(2,2,2),(3,1,1);
GO

INSERT INTO sm.Student_Class (StudentID, ClassID, SectionID)
	VALUES(4,2,1),(5,1,2);
GO
--Update
UPDATE sm.Teachers
SET MobileNo= '01554 442 657' WHERE TeacherID= 2

--Delete
DELETE FROM sm.Subjects WHERE SubjectID=7

--Distinct
SELECT DISTINCT  FatherName,StudentName, MotherName,ParentsMobileNo,MobileNo 
FROM sm.Students
GO

--Insert Into Copy Data From Another Table
SELECT * 
INTO #tempPayment
FROM sm.Payments
GO

SELECT * FROM #tempPayment
GO

--Truncate table
TRUNCATE TABLE #tempPayment
GO

--Inner Join
SELECT s.StudentID,StudentName,ClassID,SectionID,ParentsMobileNo,AmountPaid
FROM sm.Students s
JOIN sm.Student_Class sc
ON s.StudentID=sc.StudentID
JOIN sm.Payments p
ON s.StudentID=p.StudentID
GO

--Left Outer Join
SELECT *
FROM sm.Students S
LEFT JOIN sm.Payments P
ON s.StudentID=P.StudentID
GO

--Right Outer Join
SELECT *
FROM sm.Payments p
RIGHT JOIN sm.Students s
ON p.StudentID=s.StudentID
GO

--Full Outer Join
SELECT *
FROM sm.Student_Class sc
FULL JOIN sm.Students s
ON sc.StudentID=s.StudentID
GO

--Cross Join
SELECT *
FROM sm.Teachers t
CROSS JOIN sm.Teacher_Class tc

--Self join
SELECT t.TeacherID, tc.TeacherName
FROM sm.Teachers t, sm.Teachers tc
WHERE t.TeacherID<>tc.TeacherID
GO

--Six Clauses
SELECT StudentID, StudentName
FROM sm.Students
WHERE Gender='Male' 
GROUP BY StudentID, StudentName
HAVING Count(StudentID)>0

--Union 
SELECT StudentID 
FROM sm.Payments
WHERE AmountPaid=TotalFees
UNION
SELECT StudentID
FROM sm.Students
 
 --UNION ALL
 SELECT StudentID 
FROM sm.Payments
WHERE AmountPaid=TotalFees
UNION ALL
SELECT StudentID
FROM sm.Students

--Sub Query
SELECT * 
FROM sm.Payments
WHERE AmountPaid in (SELECT AmountPaid FROM sm.Payments WHERE AmountPaid=TotalFees)
GO

--CTE
WITH cte_Due
AS
(SELECT StudentID,AmountPaid, TotalFees FROM sm.Payments WHERE AmountPaid<TotalFees)
SELECT s.StudentID, s.StudentName,AmountPaid, TotalFees, s.ParentsMobileNo  
FROM sm.Students s 
JOIN cte_Due ON s.StudentID=cte_Due.StudentID
GO

--Cube
SELECT ClassID, SUM(StudentID) AS TotalStudent 
FROM sm.Student_Class
GROUP BY StudentID, ClassID WITH CUBE
GO

--Rollup
SELECT c.ClassName, SUM(StudentID) AS TotalStudent
FROM sm.Student_Class s JOIN sm.Classes C ON s.ClassID=C.ClassID
GROUP BY c.ClassName WITH ROLLUP
GO

--Grouping sets
SELECT ClassID, COUNT(StudentID) AS TotalStudent
FROM sm.Student_Class
GROUP BY GROUPING SETS (ClassID, StudentID)
GO

--Case
SELECT StudentID, TotalGradePoints,
	CASE TotalGradePoints
		WHEN 1 THEN 'Best'
		WHEN 2THEN 'Better'
		WHEN 3 THEN 'Good'
		ELSE 'Bad' 
	END AS Remarks
FROM sm.Results

--Between
SELECT * 
FROM sm.Teachers
WHERE TeacherID BETWEEN 3 AND 5
GO

--Select Query  with AND 
SELECT * 
FROM sm.Students
WHERE BirthDate='1992-12-21' AND Gender='Male'

--Select Query with OR 
SELECT * 
FROM sm.Students
WHERE BirthDate='1992-12-21' OR BirthDate='1990-10-01'

--Select Query with IN 
SELECT * 
FROM sm.Students
WHERE [Address] IN ('Dhaka')
GO
--Select Query with NOT IN 
SELECT * 
FROM sm.Students
WHERE [Address] NOT IN ('Dhaka')
GO

--TOP
SELECT TOP 3 r.StudentID, StudentName, GradePoint, TotalGradePoints
FROM sm.Results r JOIN sm.Students s ON r.StudentID=s.StudentID
JOIN sm.Grades g ON r.TotalGradePoints=g.GradeID
ORDER BY TotalGradePoints 
GO


--WildCard & Like
SELECT * 
FROM sm.Students
WHERE StudentName LIKE 'Ma__ Ma%'
GO

--While Loop
DECLARE @x int
SET @x=5
WHILE @x<=10
BEGIN
		PRINT 'Value : ' + CAST(@x AS varchar)
		SET @x=@x+1
END
GO

--IIF
SELECT PaymentID, TotalFees, AmountPaid,
	IIF(AmountPaid>=1200, 'Paid', 'Due') AS Balance
FROM sm.Payments
GO

--Choose
SELECT PaymentID, TotalFees, AmountPaid,
	CHOOSE(PaymentID, 'Paid', 'Due') AS Balance
FROM sm.Payments
WHERE TotalFees-AmountPaid>0
GO

--Isnull
SELECT PaymentID, TotalFees, AmountPaid,
	ISNULL(AmountPaid, 'Due') AS Balance
FROM sm.Payments

--Coalesce
SELECT PaymentID, TotalFees, AmountPaid,
	COALESCE(AmountPaid, 'Due') AS Balance
FROM sm.Payments

--Ranking Functions
SELECT ROW_NUMBER() OVER(PARTITION BY [Address] ORDER BY StudentID) AS RowNumbr, StudentName, StudentID
FROM sm.Students

SELECT RANK() OVER(PARTITION BY [Address] ORDER BY StudentID) AS Rank, StudentName, StudentID
FROM sm.Students

SELECT DENSE_RANK() OVER(PARTITION BY [Address] ORDER BY StudentID) AS DenseRank, StudentName, StudentID
FROM sm.Students

SELECT NTILE(1) OVER(PARTITION BY [Address] ORDER BY StudentID) AS Tile, StudentName, StudentID
FROM sm.Students

--Analytical functions
SELECT FIRST_VALUE(StudentName) OVER(PARTITION BY [Address] ORDER BY StudentID) AS FirstName, StudentName, StudentID
FROM sm.Students

SELECT LAST_VALUE(StudentName) OVER(PARTITION BY [Address] ORDER BY StudentID) AS LastName, StudentName, StudentID
FROM sm.Students

SELECT PERCENT_RANK() OVER(PARTITION BY [Address] ORDER BY StudentID) AS PctRank, StudentName, StudentID
FROM sm.Students

SELECT CUME_DIST() OVER(PARTITION BY StudentID ORDER BY StudentID) AS CumeDist, StudentName, StudentID
FROM sm.Students


SELECT PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY StudentID)  OVER(PARTITION BY StudentID) AS PercentileCont, StudentName, StudentID
FROM sm.Students


SELECT PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY StudentID)  OVER(PARTITION BY StudentID) AS PercentileDisc, StudentName, StudentID
FROM sm.Students

--Ceiling, Floor, Round
SELECT CEILING(11.75) AS [Ceiling Value];
GO
SELECT FLOOR(55.50) AS [Floor Value];
GO
SELECT ROUND(23.65,0) AS [Round Value];
GO
SELECT ABS(-23.65) AS [Absolute Value];
GO
SELECT RAND(-23.65) AS [Random Value];
GO
SELECT ISNUMERIC('A') AS [IS NUMERIC?];
GO

--Aggregate functions
SELECT COUNT(PaymentID) Payments, SUM(AmountPaid) TotalAmount, AVG(AmountPaid) [AVG]
FROM sm.Payments
GO

SELECT COUNT(*) Classes
FROM sm.Classes
GO

SELECT MIN(AmountPaid) [Min Amount]
FROM sm.Payments
GO

SELECT MAX(AmountPaid) [Max Amount]
FROM sm.Payments
GO
--Mathematical Operator
SELECT 10+2 as [Sum]
GO
SELECT 10-2 as [Substraction]
GO
SELECT 10*3 as [Multiplication]
GO
SELECT 10/2 as [Divide]
GO
SELECT 10%3 as [Remainder]
GO

--Cast, Convert, Concatenation
SELECT 'Today : ' + CAST(GETDATE() as varchar)
Go

SELECT 'Today : ' + CONVERT(varchar,GETDATE(),1)
SELECT 'Today : ' + CONVERT(varchar,GETDATE(),2)
SELECT 'Today : ' + CONVERT(varchar,GETDATE(),3)
SELECT 'Today : ' + CONVERT(varchar,GETDATE(),4)
SELECT 'Today : ' + CONVERT(varchar,GETDATE(),5)
SELECT 'Today : ' + CONVERT(varchar,GETDATE(),6)
GO

--Isdate
SELECT ISDATE('2030-05-21')
--Datepart
SELECT DATEPART(MONTH,'2030-05-21')
--Datename
SELECT DATENAME(MONTH,'2030-05-21')
--Sysdatetime
SELECT Sysdatetime()
--UTC
SELECT GETUTCDATE()

--Datediff
SELECT StudentID,
	DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age
FROM sm.Students

--All
SELECT s.StudentID,StudentName,ClassID,SectionID
FROM sm.Students s
JOIN sm.Student_Class sc ON s.StudentID=sc.StudentID
WHERE ClassID> ALL
	(SELECT ClassID FROM sm.Student_Class WHERE ClassID=2);
GO
--ANY
SELECT s.StudentID,StudentName,ClassID,SectionID
FROM sm.Students s
JOIN sm.Student_Class sc ON s.StudentID=sc.StudentID
WHERE ClassID< ANY
	(SELECT ClassID FROM sm.Student_Class WHERE ClassID=2);
GO
--Some
SELECT s.StudentID,StudentName,ClassID,SectionID
FROM sm.Students s
JOIN sm.Student_Class sc ON s.StudentID=sc.StudentID
WHERE ClassID< SOME
	(SELECT ClassID FROM sm.Student_Class WHERE ClassID=2);
GO
--Exists
SELECT StudentID, StudentName
FROM sm.Students s
WHERE NOT EXISTS
 (SELECT * FROM sm.Payments p WHERE s.StudentID=p.StudentID);

 --String functions
 SELECT StudentName,
	LEFT(StudentName, CHARINDEX(' ', StudentName) -1) AS FIRST,
	RIGHT(StudentName, LEN(StudentName)-CHARINDEX(' ', StudentName)) AS LAST
 FROM sm.Students;




