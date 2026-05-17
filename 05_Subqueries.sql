--Subqueries--

-- 1. Employees earning above the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 2. Show each employee's salary vs the company average
SELECT name,
       salary,
       (SELECT ROUND(AVG(salary), 2) FROM employees) AS company_avg
FROM employees;

-- ─── SUBQUERY IN FROM (Derived Table) ────────────────────
-- Treat a subquery result as a temporary table.

-- 3. Department-level summary used as a derived table
SELECT dept_summary.dept_id,
       dept_summary.avg_sal
FROM (
    SELECT dept_id, ROUND(AVG(salary), 2) AS avg_sal
    FROM employees
    GROUP BY dept_id
) AS dept_summary
WHERE dept_summary.avg_sal > 60000;



-- 4. Employees who work in departments with 'ing' in the name
SELECT name, dept_id
FROM employees
WHERE dept_id IN (
    SELECT dept_id
    FROM departments
    WHERE dept_name LIKE '%ing%'
);

-- 5. Employees NOT in any Engineering or Finance department
SELECT name
FROM employees
WHERE dept_id NOT IN (
    SELECT dept_id
    FROM departments
    WHERE dept_name IN ('Engineering', 'Finance')
);

-- CORRELATED SUBQUERY --


-- 6. Employees earning more than the average of their OWN department
SELECT e.name, e.dept_id, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees inner_e
    WHERE inner_e.dept_id = e.dept_id   -- correlated reference
);

-- 7. Find the highest-paid employee in each department (correlated)
SELECT e.name, e.dept_id, e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees inner_e
    WHERE inner_e.dept_id = e.dept_id
);

--Exists / Not Exists--

-- 8. Departments that HAVE at least one employee
SELECT dept_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id
);

-- 9. Departments with NO employees assigned
SELECT dept_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id
);

--CTE--

-- 10. Using a CTE to find above-average earners
WITH avg_salary AS (
    SELECT ROUND(AVG(salary), 2) AS avg_sal FROM employees
)
SELECT e.name, e.salary, a.avg_sal
FROM employees e, avg_salary a
WHERE e.salary > a.avg_sal
ORDER BY e.salary DESC;

-- 11. Multiple CTEs chained together
WITH dept_stats AS (
    SELECT dept_id,
           ROUND(AVG(salary), 2) AS avg_sal,
           COUNT(*)               AS headcount
    FROM employees
    GROUP BY dept_id
),
high_value_depts AS (
    SELECT dept_id
    FROM dept_stats
    WHERE avg_sal > 60000 AND headcount >= 2
)
SELECT e.name, e.salary, d.dept_name
FROM employees e
JOIN departments   d ON e.dept_id = d.dept_id
JOIN high_value_depts h ON e.dept_id = h.dept_id
ORDER BY e.salary DESC;
