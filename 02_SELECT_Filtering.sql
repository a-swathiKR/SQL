

-- 1. Select all columns
SELECT * FROM employees;

-- 2. Select specific columns
SELECT name, salary, city
FROM employees;

-- 3. WHERE – exact match
SELECT * FROM employees
WHERE city = 'Palakkad';

-- 4. WHERE – comparison operators
SELECT name, salary
FROM employees
WHERE salary > 60000;

-- 5. WHERE – range with BETWEEN
SELECT name, salary
FROM employees
WHERE salary BETWEEN 50000 AND 80000;

-- 6. WHERE – multiple conditions with AND / OR
SELECT name, dept_id, salary
FROM employees
WHERE dept_id = 1 AND salary > 70000;

SELECT name, city
FROM employees
WHERE city = 'Kochi' OR city = 'Thrissur';

-- 7. IN – match against a list of values
SELECT name, city
FROM employees
WHERE city IN ('Palakkad', 'Kochi', 'Thrissur');

-- 8. NOT IN – exclude values
SELECT name, dept_id
FROM employees
WHERE dept_id NOT IN (2, 4);



SELECT name FROM employees WHERE name LIKE 'A%';       -- starts with A
SELECT name FROM employees WHERE name LIKE '%Nair';    -- ends with Nair
SELECT name FROM employees WHERE name LIKE '%a%';      -- contains 'a'
SELECT name FROM employees WHERE name LIKE 'A____i%';  -- A, then 4 chars, then 'i'

-- 10. IS NULL / IS NOT NULL
SELECT name FROM employees WHERE city IS NULL;
SELECT name FROM employees WHERE city IS NOT NULL;

-- 11. ORDER BY – sort results
SELECT name, salary
FROM employees
ORDER BY salary DESC;          -- highest first

SELECT name, hire_date
FROM employees
ORDER BY hire_date ASC;        -- oldest hire first

-- 12. LIMIT / OFFSET – pagination
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;                       -- top 3 earners

SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;              -- next 3 (page 2)

-- 13. DISTINCT – remove duplicates
SELECT DISTINCT city FROM employees;

-- 14. Alias with AS
SELECT name AS employee_name,
       salary AS monthly_salary
FROM employees;
