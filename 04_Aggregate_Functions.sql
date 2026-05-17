-- ============================================================
--  04_Aggregate_Functions.sql  |  COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- ============================================================

-- ─── BASIC AGGREGATES ─────────────────────────────────────

-- 1. Total number of employees
SELECT COUNT(*) AS total_employees
FROM employees;

-- 2. Count employees in a specific department
SELECT COUNT(*) AS engineering_headcount
FROM employees
WHERE dept_id = 1;

-- 3. Total salary payout per month
SELECT SUM(salary) AS total_salary_cost
FROM employees;

-- 4. Average salary across the company
SELECT ROUND(AVG(salary), 2) AS avg_salary
FROM employees;

-- 5. Highest and lowest salaries
SELECT MAX(salary) AS highest_salary,
       MIN(salary) AS lowest_salary
FROM employees;

-- 6. Salary range (spread)
SELECT MAX(salary) - MIN(salary) AS salary_range
FROM employees;

-- ─── GROUP BY ─────────────────────────────────────────────
-- Aggregate per category.

-- 7. Headcount per department
SELECT d.dept_name,
       COUNT(e.emp_id) AS headcount
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- 8. Average salary per department
SELECT d.dept_name,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

-- 9. Total salary cost per city
SELECT city,
       SUM(salary)  AS total_cost,
       COUNT(*)     AS num_employees
FROM employees
GROUP BY city
ORDER BY total_cost DESC;

-- 10. Group by multiple columns
SELECT d.dept_name, e.city, COUNT(*) AS count
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name, e.city
ORDER BY d.dept_name, e.city;

-- ─── HAVING ───────────────────────────────────────────────
-- Filter AFTER aggregation (WHERE filters before aggregation).

-- 11. Departments with more than 1 employee
SELECT d.dept_name, COUNT(*) AS headcount
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(*) > 1;

-- 12. Departments where average salary exceeds 65,000
SELECT d.dept_name,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 65000;

-- 13. Cities with total salary cost above 100,000
SELECT city, SUM(salary) AS total_cost
FROM employees
GROUP BY city
HAVING SUM(salary) > 100000
ORDER BY total_cost DESC;

-- ─── WHERE vs HAVING (side-by-side) ──────────────────────

-- WHERE  → filter rows BEFORE grouping
SELECT d.dept_name, AVG(e.salary) AS avg_sal
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.city = 'Palakkad'          -- only Palakkad employees
GROUP BY d.dept_name;

-- HAVING → filter groups AFTER grouping
SELECT d.dept_name, AVG(e.salary) AS avg_sal
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 60000;     -- only high-paying depts

-- ─── COUNT DISTINCT ───────────────────────────────────────

-- 14. How many unique cities do employees come from?
SELECT COUNT(DISTINCT city) AS unique_cities
FROM employees;
