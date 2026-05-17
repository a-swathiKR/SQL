-- ============================================================
--  01_DML.sql  |  INSERT, UPDATE, DELETE
--  Dataset: employees & departments
-- ============================================================

-- Create supporting tables (run once to set up the demo schema)
CREATE TABLE IF NOT EXISTS departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS employees (
    emp_id     INT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    dept_id    INT REFERENCES departments(dept_id),
    salary     DECIMAL(10,2),
    hire_date  DATE,
    city       VARCHAR(50)
);

-- ─── INSERT ───────────────────────────────────────────────

-- 1. Insert single row
INSERT INTO departments (dept_id, dept_name)
VALUES (1, 'Engineering');

-- 2. Insert multiple rows at once
INSERT INTO departments (dept_id, dept_name) VALUES
    (2, 'Marketing'),
    (3, 'Human Resources'),
    (4, 'Finance');

-- 3. Insert employees
INSERT INTO employees (emp_id, name, dept_id, salary, hire_date, city) VALUES
    (101, 'Aswathi Nair',    1, 72000.00, '2022-06-15', 'Palakkad'),
    (102, 'Ravi Kumar',      2, 58000.00, '2021-03-01', 'Kochi'),
    (103, 'Priya Menon',     1, 85000.00, '2020-11-20', 'Thrissur'),
    (104, 'Arjun Das',       3, 47000.00, '2023-01-10', 'Kozhikode'),
    (105, 'Sneha Pillai',    4, 63000.00, '2019-08-05', 'Palakkad'),
    (106, 'Meera Raj',       2, 54000.00, '2022-09-30', 'Kochi'),
    (107, 'Vishnu Prasad',   1, 91000.00, '2018-04-12', 'Thrissur'),
    (108, 'Divya Krishnan',  3, 45000.00, '2023-06-01', 'Kannur');

-- ─── UPDATE ───────────────────────────────────────────────

-- 4. Give a 10% raise to all Engineering employees
UPDATE employees
SET salary = salary * 1.10
WHERE dept_id = 1;

-- 5. Update a specific employee's city
UPDATE employees
SET city = 'Bengaluru'
WHERE emp_id = 102;

-- 6. Update multiple columns at once
UPDATE employees
SET salary   = 70000.00,
    city     = 'Kochi'
WHERE emp_id = 104;

-- ─── DELETE ───────────────────────────────────────────────

-- 7. Delete a specific employee
DELETE FROM employees
WHERE emp_id = 108;

-- 8. Delete all employees from a department (careful!)
-- DELETE FROM employees WHERE dept_id = 3;

-- 9. Safe pattern: delete using a subquery
DELETE FROM employees
WHERE emp_id IN (
    SELECT emp_id FROM employees
    WHERE salary < 46000
);
