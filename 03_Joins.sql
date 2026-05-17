-- ============================================================
--  03_Joins.sql  |  INNER, LEFT, RIGHT, FULL OUTER, SELF, CROSS
-- ============================================================

-- Setup: add a projects table to make joins more interesting
CREATE TABLE IF NOT EXISTS projects (
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(100),
    lead_emp_id  INT   -- may be NULL if unassigned
);

INSERT INTO projects (project_id, project_name, lead_emp_id) VALUES
    (1, 'SkillLink AI Platform',  101),
    (2, 'Marketing Analytics',    102),
    (3, 'HR Portal Redesign',     NULL),
    (4, 'Finance Dashboard',      105),
    (5, 'Cloud Migration',        999);  -- 999 does not exist in employees

-- ─── INNER JOIN ───────────────────────────────────────────
-- Returns only rows that have a match in BOTH tables.

-- 1. Employees with their department names
SELECT e.name,
       d.dept_name,
       e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- 2. Projects with their lead employee names (only assigned projects)
SELECT p.project_name,
       e.name AS lead_name
FROM projects p
INNER JOIN employees e ON p.lead_emp_id = e.emp_id;

-- ─── LEFT JOIN ────────────────────────────────────────────
-- Returns ALL rows from the LEFT table; NULLs for non-matching right side.

-- 3. All projects, with lead name if assigned (NULL if unassigned)
SELECT p.project_name,
       e.name AS lead_name
FROM projects p
LEFT JOIN employees e ON p.lead_emp_id = e.emp_id;

-- 4. Find projects with NO assigned lead
SELECT p.project_name
FROM projects p
LEFT JOIN employees e ON p.lead_emp_id = e.emp_id
WHERE e.emp_id IS NULL;

-- ─── RIGHT JOIN ───────────────────────────────────────────
-- Returns ALL rows from the RIGHT table; NULLs for non-matching left side.

-- 5. All employees, showing project if they lead one (NULL if not)
SELECT e.name,
       p.project_name
FROM projects p
RIGHT JOIN employees e ON p.lead_emp_id = e.emp_id;

-- ─── FULL OUTER JOIN ──────────────────────────────────────
-- Returns ALL rows from BOTH tables; NULLs where there is no match.

-- 6. All employees and all projects, matched where possible
SELECT e.name        AS employee_name,
       p.project_name
FROM employees e
FULL OUTER JOIN projects p ON e.emp_id = p.lead_emp_id;

-- ─── SELF JOIN ────────────────────────────────────────────
-- A table joined to itself (common for hierarchical data).
-- Add a manager column to demonstrate:
ALTER TABLE employees ADD COLUMN IF NOT EXISTS manager_id INT;
UPDATE employees SET manager_id = 107 WHERE dept_id = 1 AND emp_id != 107;
UPDATE employees SET manager_id = 106 WHERE dept_id = 2 AND emp_id != 106;

-- 7. List each employee alongside their manager's name
SELECT e.name       AS employee,
       m.name       AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- ─── CROSS JOIN ───────────────────────────────────────────
-- Cartesian product – every row of table A × every row of table B.
-- Useful for generating combinations.

-- 8. All employee–department combinations (demo only)
SELECT e.name, d.dept_name
FROM employees e
CROSS JOIN departments d
LIMIT 20;

-- ─── JOINING 3 TABLES ─────────────────────────────────────

-- 9. Project name, lead employee name, and lead's department
SELECT p.project_name,
       e.name        AS lead_name,
       d.dept_name
FROM projects p
INNER JOIN employees   e ON p.lead_emp_id = e.emp_id
INNER JOIN departments d ON e.dept_id     = d.dept_id;
