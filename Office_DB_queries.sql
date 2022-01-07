use office;
-- find all employees
select * from employee;

-- Find all clients
select * from client;

-- Find all employees ordered by salary
select * 
from employee order by salary;
select *
from employee order by salary desc;

-- Find all employees ordered by sex then name
select * from employee
order by sex, first_name, last_name;

-- Find the first 5 employees in the table
select * from employee
limit 5;

-- Find the first and last names of all employees
select first_name, last_name
from employee;

-- Find the forename and surnames names of all employees(keyword as used)
select first_name as forename, last_name as surname
from employee;

-- Find out all the different genders (keyword distinct used)
select distinct sex
from employee;

-- Find all male employees
select * 
from employee
where sex = 'M';

-- Find all employees at branch 2
select * from employee
where branch_id = 2;

-- Find all employee's id's and names who were born after 1969
select emp_id, first_name, last_name from employee where birth_day >= '1970-01-01';

-- Find all female employees at branch 2
select * from employee
where sex = 'F' and branch_id = 2;

-- Find all employees who are female & born after 1969 or who make over 80000
select * from employee
where birth_day >= '1970-01-01' and sex = 'F'  or salary > 80000 and sex = 'F';

-- Find all employees born between 1970 and 1975(keyword used between)
SELECT *
FROM employee
WHERE birth_day BETWEEN '1970-01-01' AND '1975-01-01';

-- Find all employees named Jim, Michael, Johnny or David
SELECT *
FROM employee
WHERE first_name IN ('Jim', 'Michael', 'Johnny', 'David');

-- SQL functions
-- Find the number of employees
select count(super_id)
from employee;

-- Find the average of all employee's salaries
select avg(salary)
from employee
where sex = 'M';

-- Find the sum of all employee's salaries
SELECT SUM(salary)
FROM employee;

-- Find out how many males and females there are
select count(sex), sex
from employee
group by sex ;

-- Find the total sales of each salesman
select sum(total_sales), emp_id
from works_with
group by emp_id;

-- Find the total amount of money spent by each client
select sum(total_sales), client_id
from works_with
group by client_id;

-- % = any no. of characters, _ = one character (wildcards)

-- Find any client's who are an LLC
select *
from client
where client_name like '%LLC';

-- Find any branch suppliers who are in the label business
select * 
from branch_supplier
where supplier_name like '% Labels';

-- Find any employee born in october
select * 
from employee
where birth_day like '____-10%';

-- Find any employee born on the 10th day of the month
select * from employee
where birth_day like '____-__-15';

-- Find any clients who are schools
select * from client
where client_name like '%School';

-- Find a list of employee and branch names: Union
select employee.first_name as Employee_Branch_Names
from employee
union
select branch.branch_name 
from branch;

-- Find a list of all clients & branch suppliers' names
select client_name as Non_Employee_Entities, client.branch_id as Branch_ID
from client
union
select branch_supplier.supplier_name, branch_supplier.branch_id
from branch_supplier;

-- Join inner, left, right
INSERT INTO branch VALUES(4, "Buffalo", NULL, NULL);
-- Find all the branches and the names of their managers
select employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
from employee
inner join branch on employee.emp_id = branch.mgr_id;

select employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
from employee
left join branch on employee.emp_id = branch.mgr_id;

select employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
from employee
right join branch on employee.emp_id = branch.mgr_id;

select employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
from employee
left join branch on employee.emp_id = branch.mgr_id
union
select employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
from employee
right join branch on employee.emp_id = branch.mgr_id;

select * from employee
cross join branch;

-- nested queries
-- Find names of all employees who have sold over 50,000
select employee.first_name, employee.last_name
from employee
where employee.emp_id in ( 
	select works_with.emp_id
	from works_with
	where works_with.total_sales > 50000);

-- Find all clients who are handled by the branch that Michael Scott manages
-- Assume you know Michael's ID
SELECT client.client_id, client.client_name
FROM client
WHERE client.branch_id = (
	SELECT branch.branch_id
    FROM branch
    WHERE branch.mgr_id = 102);

 -- Find all clients who are handles by the branch that Michael Scott manages
 -- Assume you DONT'T know Michael's ID
SELECT client.client_id, client.client_name
FROM client
WHERE client.branch_id = (
	SELECT branch.branch_id
    FROM branch
    WHERE branch.mgr_id = ( 
			select employee.emp_id
			from employee
			where employee.first_name = 'Michael' and employee.last_name = 'Scott'
            limit 1 ));
            
-- Find the names of employees who work with clients handled by the scranton branch
SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
                         SELECT works_with.emp_id
                         FROM works_with
                         )
AND employee.branch_id = 2;

-- Find the names of all clients who have spent more than 100,000 dollars
select client.client_name
from client
where client.client_id in (
							select client_id
							from(
									select sum(works_with.total_sales) as total
									from works_with group by client_id) as total_client_sales
							where total > 100000
                           );
						
-- on delete deleting entries in database when they have foreign keys associated with them
-- on delete set null
-- on delete cascade

-- Triggers
--     TRIGGER `event_name` BEFORE/AFTER INSERT/UPDATE/DELETE
--     ON `database`.`table`
--     FOR EACH ROW BEGIN
-- 		trigger body
-- 		this code is applied to every
-- 		inserted/updated/deleted row
--     END

create table trigger_test (
    message VARCHAR(100)
);


DELIMITER $$
CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('added new employee');
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(109, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);


DELIMITER $$
CREATE
    TRIGGER my_trigger1 BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES(NEW.first_name);
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(110, 'Kevin', 'Malone', '1978-02-19', 'M', 69000, 106, 3);


DELIMITER $$
CREATE
    TRIGGER my_trigger2 BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
         IF NEW.sex = 'M' THEN
               INSERT INTO trigger_test VALUES('added male employee');
         ELSEIF NEW.sex = 'F' THEN
               INSERT INTO trigger_test VALUES('added female');
         ELSE
               INSERT INTO trigger_test VALUES('added other employee');
         END IF;
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(111, 'Pam', 'Beesly', '1988-02-19', 'F', 69000, 106, 3);
insert into employee
values(112, 'Aaron', 'Paul', '1989-02-20', 'M', 70000, 106, 3);

select * from employee;
select * from trigger_test;

DROP TRIGGER my_trigger4;

DELIMITER $$
CREATE
    TRIGGER my_trigger5 after delete
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('deleted employee');
    END$$
DELIMITER ;








