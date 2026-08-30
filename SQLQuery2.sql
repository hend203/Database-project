-- 3. Write a query to display the number of books published by (HarperCollins) with the alias name 'NO_OF_BOOKS'.
select count(b.book_id) as no_of_books
from books b inner join publisher p
on b.pub_id = p.pub_id
where p.pubname = 'HarperCollins'
go

-- 6. Write a query to display the name of users who have letter 'A' in their names.
select name
from users
where name like '%A%'
go

-- 9. write a query that displays the category which has the book that has the minimum amount of money for borrowing.
select top 1 c.catname
from borrow br inner join books b 
on br.book_id = b.book_id
inner join category c 
on b.cat_id = c.cat_id
order by br.amount_paid asc
go

-- 12. Write a query that display books id which is not found in floor num = 1 and shelf-code = A1.
select book_id
from books
where book_id not in (
    select b.book_id
    from books b inner join shelf s 
    on b.shelf_code = s.code
    where s.floor_id = 1 and s.code = 'A1'
)
go

-- 15. Display Employee Full Name and Name Of his/her Supervisor as Supervisor Name.
select e.fname + ' ' + e.lname as [employee full name],
       s.fname + ' ' + s.lname as [supervisor name]
from employees e left outer join employees s
on e.supervisor_id = s.emp_id
go

-- 18. Write a function that take Number and display if it is even or odd
go
create or alter function dbo.checkevenodd(@num int)
returns varchar(10)
as
begin
    declare @result varchar(10)
    if @num % 2 = 0
        set @result = 'Even'
    else
        set @result = 'Odd'
    return @result
end
go

-- Test 18:
select dbo.checkevenodd(4)
go

-- 21. Write a function that take user name and check if it's duplicated
go
create or alter function dbo.checkusername(@username varchar(100))
returns varchar(200)
as
begin
    declare @count int
    declare @msg varchar(200)
    
    select @count = count(*) 
    from users 
    where name = @username
    
    if @count = 0
        set @msg = @username + ' is Not Found'
    else if @count = 1
        set @msg = @username + ' is not duplicated'
    else
        set @msg = @username + ' is Repeated ' + cast(@count as varchar(10)) + ' times'
        
    return @msg
end
go

-- test 21:
select dbo.checkusername('Ahmed Nabil') as [test result]
go

-- 24. Create a stored procedure to update floor table manager
go
create or alter procedure sp_updatefloormanager
    @oldempid int,
    @newempid int,
    @floornum int
as
begin
    update floors
    set manager_id = @newempid
    where floor_id = @floornum and manager_id = @oldempid
end
go

-- test 24:
exec sp_updatefloormanager @oldempid = 1, @newempid = 2, @floornum = 1
go

-- 27. create a view "V3" That display the shelf code that have maximum number of books using the previous view "V2"
go
create or alter view v2
as
    select shelf_code, count(book_id) as bookcount
    from books
    group by shelf_code
go

create or alter view v3
as
    select shelf_code
    from v2
    where bookcount = (select max(bookcount) from v2)
go

-- test 27:
select * from v3
go

-- 30. Create view name (v_2006_check)
go
create or alter view v_2006_check
as
    select manager_id, floor_id, noofblocks, hiringdate
    from floors
    where hiringdate between '2022-03-01' and '2022-12-31'
    with check option
go

-- Test Insertions & Explanation:
insert into v_2006_check 
values (2, 6, 2, '2023-08-07')
-- Row 1 fails because the hiringdate ('2023-08-07') is outside the date range allowed by with check option.

insert into v_2006_check 
values (4, 7, 1, '2022-08-04')
-- Row 2 satisfies the date condition, but will fail if manager_id = 4 violates foreign key constraint or if floor_id is identity column.