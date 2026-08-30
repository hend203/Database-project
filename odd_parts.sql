-- 1 - Write a query that displays Full name of an employee who has more than 3 letters in his/her First Name.
select Fname , Lname as [Full name]
from Employees 
where len(Fname)>3

-- 5 - Write a query to display book title, author name and display in the following format,' [Book Title] is written by [Author Name].
select Title + ' is written by ' + AuthName as [Book Details]
from Books B join Book_Author BA on B.Book_ID = BA.Book_ID
join Author A on A.Auth_ID = BA.Auth_ID  

-- 7 - Write a query that display user SSN who makes the most borrowing 
select top 1 SSN 
from Borrow 
group by SSN 
order by count(*) desc 

-- 11 - Write a query to list the category and number of books in each category with the alias name 'Count Of Books'. 
select C.CatName , count(B.Book_ID) as [Count Of Books]
from Category C left join Books B ON C.Cat_ID = B.Cat_ID
group by CatName

-- 13 - Write a query that displays the floor number , Number of Blocks and number of employees working on that floor.
select F.Floor_ID , F.NoOfBlocks , count(E.Emp_ID) as [Number of Employees]
from Floors F left join Employees E
on F.Floor_ID = E.Floor_ID 
group by F.Floor_ID , F.NoOfBlocks

-- 17 - Display max and min salary for Employees
select max(Salary) as [Max Salary] , min(Salary) as [Min Salary]
from Employees

-- 19 - write a function that take category name and display Title of books in that category 
create function get_books_by_category(@catname varchar(50))
returns table
as 
return (
	select C.CatName , B.Title 
	from Category C join Books B
	on C.Cat_ID = B.Cat_ID
	where C.CatName = @catname	
)

-- 23 - Create a stored procedure to show the number of books per Category.
create procedure books_per_category 
as 
begin 
	select count(B.Book_ID) as [Number of books] , C.CatName 
	from Category C left join Books B 
	on C.Cat_ID = B.Cat_ID 
	group by C.CatName
end 

-- 25 - Create a view AlexAndCairoEmp that displays Employee data for users who live in Alex or Cairo.
create view AlexAndCairoEmp as
select * 
from Employees 
where Address IN ('Cairo','Alex')

-- 29 - In the Floor table insert new Floor With Number of blocks 2 , employee
--with SSN = 20 as a manager for this Floor,The start date for this manager
--is Now. Do what is required if you know that : Mr.Omar Amr(SSN=5)
--moved to be the manager of the new Floor (id = 6), and they give Mr. Ali
--Mohamed(his SSN =12) His position . 

-- 1. Assign Mr. Ali Mohamed (Emp_ID = 12) as the manager of Floor 2 replacing Mr. Omar Amr
UPDATE Floors
SET Manager_ID = 12, 
    HiringDate = GETDATE()
WHERE Floor_ID = 2;

-- 2. Enable IDENTITY_INSERT for Floors table, create Floor 6, and assign Mr. Omar Amr (Emp_ID = 5) as its manager
SET IDENTITY_INSERT Floors ON;
INSERT INTO Floors (Floor_ID, NoOfBlocks, Manager_ID, HiringDate)
VALUES (6, 2, 5, GETDATE());
-- Add Floor 7 for the new employee (Emp_ID = 20)
INSERT INTO Floors (Floor_ID, NoOfBlocks, Manager_ID, HiringDate)
VALUES (7, 2, 20, GETDATE());
SET IDENTITY_INSERT Floors OFF;
-- 3. Update the Floor_ID for employees in the Employees table to reflect their new locations
UPDATE Employees SET Floor_ID = 6 WHERE Emp_ID = 5;
UPDATE Employees SET Floor_ID = 2 WHERE Emp_ID = 12;
UPDATE Employees SET Floor_ID = 7 WHERE Emp_ID = 20;

-- 31 - Create a trigger to prevent anyone from Modifying or Delete or Insert in the Employee table ( Display a message for user to tell him that he can’t
-- take any action with this Table) 
CREATE TRIGGER trg_PreventEmpChanges
ON Employees
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR ('You are not allowed to modify, insert, or delete in the Employees table.', 16, 1);
END;



