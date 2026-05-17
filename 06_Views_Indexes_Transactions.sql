--Views--
-- 1. Simple view – employee details with department name
CREATE OR REPLACE VIEW vw_employee_details AS
SELECT e.emp_id,
       e.name,
       d.dept_name,
       e.salary,
       e.city,
       e.hire_date
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Query the view just like a table
SELECT * FROM vw_employee_details WHERE city = 'Palakkad';

-- 2. View – department salary summary
CREATE OR REPLACE VIEW vw_dept_salary_summary AS
SELECT d.dept_name,
       COUNT(e.emp_id)            AS headcount,
       ROUND(AVG(e.salary), 2)    AS avg_salary,
       MAX(e.salary)              AS max_salary,
       MIN(e.salary)              AS min_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

SELECT * FROM vw_dept_salary_summary ORDER BY avg_salary DESC;

-- 3. View – above-average earners only
CREATE OR REPLACE VIEW vw_top_earners AS
SELECT name, salary, city
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

SELECT * FROM vw_top_earners;

-- 4. Drop a view
DROP VIEW IF EXISTS vw_top_earners;

--Indexes--


-- 5. Single-column index on city (we filter by city often)
CREATE INDEX IF NOT EXISTS idx_emp_city
    ON employees (city);

-- 6. Index on dept_id for faster joins
CREATE INDEX IF NOT EXISTS idx_emp_dept
    ON employees (dept_id);

-- 7. Composite index – useful when filtering by (dept_id, salary) together
CREATE INDEX IF NOT EXISTS idx_emp_dept_salary
    ON employees (dept_id, salary);

-- 8. Unique index – enforces uniqueness and speeds up lookups
CREATE UNIQUE INDEX IF NOT EXISTS idx_dept_name_unique
    ON departments (dept_name);

-- 9. See all indexes on a table (PostgreSQL)
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- 10. Drop an index
DROP INDEX IF EXISTS idx_emp_city;

--Transactions--

BEGIN;

    UPDATE employees SET salary = salary - 5000 WHERE emp_id = 101;
    UPDATE employees SET salary = salary + 5000 WHERE emp_id = 103;

COMMIT;   -- make changes permanent

-- 12. Transaction with ROLLBACK on error
BEGIN;

    INSERT INTO employees (emp_id, name, dept_id, salary, hire_date, city)
    VALUES (201, 'Test Employee', 1, 50000, CURRENT_DATE, 'Palakkad');

    -- Simulate discovering an error → undo everything
    ROLLBACK;

-- emp_id 201 never appears in the table

-- 13. SAVEPOINT – partial rollback within a transaction
BEGIN;

    UPDATE employees SET city = 'Mumbai' WHERE emp_id = 101;

    SAVEPOINT before_salary_change;

    UPDATE employees SET salary = 999999 WHERE emp_id = 101;  -- mistake!

    ROLLBACK TO SAVEPOINT before_salary_change;   -- undo only the salary change

    -- city update (Mumbai) is still in effect
COMMIT;
