USE LibraryDB

-- Q2: Write a query to display the total number of Programming books available in the library with alias name ‘NO OF PROGRAMMING BOOKS’

SELECT COUNT(*) AS [NO OF PROGRAMMING BOOKS]
FROM Books B
JOIN Category C ON B.Cat_ID = C.Cat_ID
WHERE C.CatName = 'Programming';

-- Q4: Write a query to display the User SSN and name, date of borrowing and
-- due date of the User whose due date is before July 2022. 

SELECT U.SSN, U.Name, Bo.Date_Borrowed, Bo.Due_Date
FROM Users U
JOIN Borrow Bo ON U.SSN = Bo.SSN
WHERE Bo.Due_Date < '2022-07-01';


-- Q8: Write a query that displays the total amount of money that each user paid for borrowing books.

SELECT U.SSN, U.Name, SUM(Bo.Amount_Paid) AS TotalAmountPaid
FROM Users U
JOIN Borrow Bo ON U.SSN = Bo.SSN
GROUP BY U.SSN, U.Name;

-- Q10: write a query that displays the email of an employee if it's not found,
-- display address if it's not found, display date of birthday.

SELECT Emp_ID, Fname, Lname,
       COALESCE(Email, Address, CONVERT(VARCHAR(20), DateOfBirth, 23)) AS ContactInfo
FROM Employees;


-- Q14: Display Book Title and User Name to designate Borrowing that occurred within the period ‘3/1/2022’ and ‘10/1/2022’

SELECT B.Title AS [Book Title], U.Name AS [User Name]
FROM Borrow Bo
JOIN Books B ON Bo.Book_ID = B.Book_ID
JOIN Users U ON Bo.SSN = U.SSN
WHERE Bo.Date_Borrowed BETWEEN '2022-03-01' AND '2022-10-01';

-- Q16: Employee name and salary, but if no salary then display bonus

SELECT Fname + ' ' + Lname AS EmployeeName,
       COALESCE(Salary, Bonus) AS SalaryOrBonus
FROM Employees;


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

-- Q22: .Create a scalar function that takes date and Format to return Date With That Format.

CREATE FUNCTION dbo.fn_FormatDate (@InputDate DATE, @Format VARCHAR(20))
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN FORMAT(@InputDate, @Format);
END

 
-- usage:
SELECT dbo.fn_FormatDate(GETDATE(), 'dd-MM-yyyy');
SELECT dbo.fn_FormatDate(GETDATE(), 'dddd MMMM yyyy');

-- Q26: create a view "V2" That displays number of books per shelf

CREATE VIEW V2 AS
SELECT S.Code AS ShelfCode, COUNT(B.Book_ID) AS NumberOfBooks
FROM Shelf S
LEFT JOIN Books B ON S.Code = B.Shelf_Code
GROUP BY S.Code;


-- usage:
SELECT * FROM V2;


-- Q28: Create table ReturnedBooks, then a trigger that runs INSTEAD OF
--      INSERT: if the return date is later than the due date, the user
--      pays a fee = 20% of the amount they originally paid for that book.

CREATE TABLE ReturnedBooks
(
    SSN         INT     NOT NULL,
    Book_ID     INT     NOT NULL,
    Due_Date    DATE    NOT NULL,
    Return_Date DATE    NOT NULL,
    Fees        MONEY   NULL,
    CONSTRAINT fk_returned_user FOREIGN KEY (SSN) REFERENCES Users(SSN),
    CONSTRAINT fk_returned_book FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);
GO
 
CREATE TRIGGER trg_ReturnedBooks_InsteadOfInsert
ON ReturnedBooks
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
 
    INSERT INTO ReturnedBooks (SSN, Book_ID, Due_Date, Return_Date, Fees)
    SELECT
        i.SSN,
        i.Book_ID,
        i.Due_Date,
        i.Return_Date,
        CASE
            WHEN i.Return_Date > i.Due_Date THEN
                (SELECT TOP 1 Bo.Amount_Paid * 0.20
                 FROM Borrow Bo
                 WHERE Bo.SSN = i.SSN AND Bo.Book_ID = i.Book_ID
                 ORDER BY Bo.Date_Borrowed DESC)
            ELSE 0
        END AS Fees
    FROM inserted i;
END
GO
 
-- usage:
INSERT INTO ReturnedBooks (SSN, Book_ID, Due_Date, Return_Date)
VALUES (20001, 1, '2022-02-05', '2022-02-10');  

-- Q32: Testing Referential Integrity

-- A. Add a new User Phone Number with User_SSN = 50
INSERT INTO User_Phones (SSN, Phone)
VALUES (50, '01099999999');
-- Result:
-- Fails
-- Because User_Phones.SSN is a Foreign Key referencing Users.SSN, and there is no user with SSN = 50.
 
-- B. Modify employee ID 20 to 21
UPDATE Employees
SET Emp_ID = 21
WHERE Emp_ID = 20;
-- Result: 0 rows affected because Emp_ID = 20 does not exist in the current Employees table.
 
-- C. Delete the employee with ID = 1
DELETE FROM Employees
WHERE Emp_ID = 1;

-- Result: Fails with a Foreign Key violation because Employee 1 is referenced by other records, 
-- such as Supervisor_ID, Manager_ID, Recorded_By, and Borrow.Emp_ID.
 
-- D. Delete the employee with id = 12
DELETE FROM Employees
WHERE Emp_ID = 12;

-- Result: 0 rows affected because Employee 12 does not exist in the current Employees table.
 
-- E. Create an index on column (Salary) that allows clustering the data
CREATE CLUSTERED INDEX IX_Employees_Salary
ON Employees(Salary);

-- Result: Fails because the Employees table already has a clustered index on its Primary Key Emp_ID. A table can have only one clustered index.
 
