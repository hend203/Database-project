USE LibraryDB

-- Q2: Write a query to display the total number of Programming books available in the library with alias name ‘NO OF PROGRAMMING BOOKS’

SELECT COUNT(*) AS [NO OF PROGRAMMING BOOKS]
FROM Books B
JOIN Category C ON B.Cat_ID = C.Cat_ID
WHERE C.CatName = 'Programming';

-- Q5: Write a query to display book title, author name and display in the following format, ' [Book Title] is written by [Author Name]

SELECT B.Title + ' is written by ' + A.AuthName AS BookAuthorInfo
FROM Books B
JOIN Book_Author BA ON B.Book_ID = BA.Book_ID
JOIN Author A ON BA.Auth_ID = A.Auth_ID;

-- Q8: Write a query that displays the total amount of money that each user paid for borrowing books.

SELECT U.SSN, U.Name, SUM(Bo.Amount_Paid) AS TotalAmountPaid
FROM Users U
JOIN Borrow Bo ON U.SSN = Bo.SSN
GROUP BY U.SSN, U.Name;

--  Q11: Write a query to list the category and number of books in each category with the alias name 'Count Of Books'.

SELECT C.CatName, COUNT(B.Book_ID) AS [Count Of Books]
FROM Category C
LEFT JOIN Books B ON C.Cat_ID = B.Cat_ID
GROUP BY C.CatName;

-- Q14: Display Book Title and User Name to designate Borrowing that occurred within the period ‘3/1/2022’ and ‘10/1/2022’

SELECT B.Title AS [Book Title], U.Name AS [User Name]
FROM Borrow Bo
JOIN Books B ON Bo.Book_ID = B.Book_ID
JOIN Users U ON Bo.SSN = U.SSN
WHERE Bo.Date_Borrowed BETWEEN '2022-03-01' AND '2022-10-01';

-- Q17: Display max and min salary for Employees

SELECT MAX(Salary) AS MaxSalary, MIN(Salary) AS MinSalary
FROM Employees;
GO
-- Q20:  write a function that takes the phone of the user and displays Book Title , user-name, amount of money and due-date. 

CREATE FUNCTION dbo.fn_GetBorrowInfoByPhone (@Phone VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT B.Title AS BookTitle, U.Name AS UserName,
           Bo.Amount_Paid AS AmountOfMoney, Bo.Due_Date AS DueDate
    FROM User_Phones UP
    JOIN Users U   ON UP.SSN = U.SSN
    JOIN Borrow Bo ON U.SSN = Bo.SSN
    JOIN Books B   ON Bo.Book_ID = B.Book_ID
    WHERE UP.Phone = @Phone
);

-- usage:
SELECT * FROM dbo.fn_GetBorrowInfoByPhone('01011111111');

-- Q23: Create a stored procedure to show the number of books per Category.

CREATE PROCEDURE dbo.sp_BooksPerCategory
AS
BEGIN
    SELECT C.CatName, COUNT(B.Book_ID) AS NumberOfBooks
    FROM Category C
    LEFT JOIN Books B ON C.Cat_ID = B.Cat_ID
    GROUP BY C.CatName;
END
GO

-- usage:
EXEC dbo.sp_BooksPerCategory;

-- Q26: create a view "V2" That displays number of books per shelf

CREATE VIEW V2 AS
SELECT S.Code AS ShelfCode, COUNT(B.Book_ID) AS NumberOfBooks
FROM Shelf S
LEFT JOIN Books B ON S.Code = B.Shelf_Code
GROUP BY S.Code;
GO

-- usage:
SELECT * FROM V2;


-- Q29: In the Floor table insert new Floor With Number of blocks 2 , employee
-- with SSN = 20 as a manager for this Floor,The start date for this manager
-- is Now. Do what is required if you know that : Mr.Omar Amr(SSN=5)
-- moved to be the manager of the new Floor (id = 6), and they give Mr. Ali
-- Mohamed(his SSN =12) His position 
  
-- Step 0: add the missing employees
SET IDENTITY_INSERT Employees ON;
 
INSERT INTO Employees (Emp_ID, Fname, Lname, DateOfBirth)
VALUES (20, 'Test', 'Manager', '1990-01-01');
 
INSERT INTO Employees (Emp_ID, Fname, Lname, DateOfBirth)
VALUES (12, 'Ali', 'Mohamed', '1990-01-01');
 
SET IDENTITY_INSERT Employees OFF;
GO
 
-- Step 1: insert the new floor, manager = employee 20, hiring date = now
INSERT INTO Floors (NoOfBlocks, Manager_ID, HiringDate)
VALUES (2, 20, GETDATE());
 
-- Step 2: Omar Amr (Emp_ID = 5) becomes manager of the new floor
-- instead of employee 20
UPDATE Floors
SET Manager_ID = 5,
    HiringDate = GETDATE()
WHERE Manager_ID = 20;
 
-- Step 3: Ali Mohamed (Emp_ID = 12) takes Omar's old position
UPDATE Floors
SET Manager_ID = 12,
    HiringDate = GETDATE()
WHERE Manager_ID = 5
  AND Manager_ID <> 20;
GO

-- Q32: Testing Referential Integrity

-- A. Add a new User Phone Number with User_SSN = 50 in User_Phones table
INSERT INTO User_Phones (SSN, Phone) VALUES (50, '01099999999');
-- Result: FAILS with a Foreign Key violation.
-- User_Phones.SSN references Users.SSN, and SSN = 50 does not exist
-- in the Users table.
 
-- B. Modify the employee id 20 in the employee table to 21
UPDATE Employees SET Emp_ID = 21 WHERE Emp_ID = 20;
-- Result: FAILS.
-- Emp_ID is an IDENTITY column, so SQL Server does not allow updating
-- its value directly. Even if it weren't IDENTITY, it would still fail
-- because Emp_ID = 20 is referenced by other tables (e.g. Floors.Manager_ID)
-- through Foreign Keys with no ON UPDATE CASCADE.
 
-- C. Delete the employee with id = 1
DELETE FROM Employees WHERE Emp_ID = 1;
-- Result: FAILS with a Foreign Key violation.
-- Emp_ID = 1 is referenced as Supervisor_ID for other employees, as
-- Manager_ID in Floors, as Recorded_By in Users, and as Emp_ID in Borrow.
-- None of these Foreign Keys have ON DELETE CASCADE.
 
-- D. Delete the employee with id = 12
DELETE FROM Employees WHERE Emp_ID = 12;
-- Result: depends on whether Emp_ID = 12 has dependent rows.
-- If it exists and is not referenced anywhere (not a supervisor, not a
-- manager, not in Users.Recorded_By or Borrow.Emp_ID), the DELETE succeeds.
-- If Emp_ID = 12 does not exist, 0 rows are affected (no error).
 
-- E. Create an index on column (Salary) that allows clustering the data
CREATE CLUSTERED INDEX idx_Employees_Salary ON Employees(Salary);
-- Result: FAILS.
-- Employees already has a CLUSTERED index automatically built on its
-- PRIMARY KEY (Emp_ID). A table can only have ONE clustered index at a time.
-- To cluster by Salary instead, the primary key must first be changed to
-- NONCLUSTERED:
--
-- ALTER TABLE Employees DROP CONSTRAINT PK_Employees;  -- use the real constraint name
-- ALTER TABLE Employees ADD CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED (Emp_ID);
-- CREATE CLUSTERED INDEX idx_Employees_Salary ON Employees(Salary);
 