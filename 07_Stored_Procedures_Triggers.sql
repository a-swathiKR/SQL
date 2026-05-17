

-- 1. Simple procedure – give a raise to all employees in a department
CREATE OR REPLACE PROCEDURE sp_give_raise(
    p_dept_id  INT,
    p_percent  NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_percent / 100.0)
    WHERE dept_id = p_dept_id;

    RAISE NOTICE 'Raise of %% applied to dept_id %', p_percent, p_dept_id;
END;
$$;

-- Call it: give Engineering (dept 1) a 15% raise
CALL sp_give_raise(1, 15);


-- 2. Procedure with OUT parameter – get department stats
CREATE OR REPLACE PROCEDURE sp_dept_stats(
    p_dept_id    IN  INT,
    p_avg_salary OUT NUMERIC,
    p_headcount  OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT ROUND(AVG(salary), 2), COUNT(*)
    INTO   p_avg_salary, p_headcount
    FROM   employees
    WHERE  dept_id = p_dept_id;
END;
$$;

-- Call it (store results in variables via DO block)
DO $$
DECLARE
    v_avg NUMERIC;
    v_cnt INT;
BEGIN
    CALL sp_dept_stats(1, v_avg, v_cnt);
    RAISE NOTICE 'Dept 1 → avg salary: %, headcount: %', v_avg, v_cnt;
END;
$$;


-- 3. Procedure with exception handling – safe employee insert
CREATE OR REPLACE PROCEDURE sp_add_employee(
    p_emp_id   INT,
    p_name     VARCHAR,
    p_dept_id  INT,
    p_salary   NUMERIC,
    p_city     VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (emp_id, name, dept_id, salary, hire_date, city)
    VALUES (p_emp_id, p_name, p_dept_id, p_salary, CURRENT_DATE, p_city);

    RAISE NOTICE 'Employee % added successfully.', p_name;

EXCEPTION
    WHEN unique_violation THEN
        RAISE WARNING 'Employee ID % already exists. Skipped.', p_emp_id;
    WHEN foreign_key_violation THEN
        RAISE WARNING 'Department ID % does not exist.', p_dept_id;
END;
$$;

CALL sp_add_employee(201, 'Lakshmi Varma', 1, 68000, 'Palakkad');
CALL sp_add_employee(101, 'Duplicate Test', 2, 50000, 'Kochi');  -- will warn




-- 4. Audit log table to record salary changes
CREATE TABLE IF NOT EXISTS salary_audit (
    audit_id    SERIAL PRIMARY KEY,
    emp_id      INT,
    old_salary  NUMERIC,
    new_salary  NUMERIC,
    changed_at  TIMESTAMP DEFAULT NOW(),
    changed_by  VARCHAR(50) DEFAULT CURRENT_USER
);

-- Trigger function – called automatically by the trigger
CREATE OR REPLACE FUNCTION fn_log_salary_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only log if salary actually changed
    IF OLD.salary IS DISTINCT FROM NEW.salary THEN
        INSERT INTO salary_audit (emp_id, old_salary, new_salary)
        VALUES (OLD.emp_id, OLD.salary, NEW.salary);
    END IF;
    RETURN NEW;
END;
$$;

-- Attach the trigger to the employees table
CREATE OR REPLACE TRIGGER trg_salary_audit
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION fn_log_salary_change();

-- Test: update a salary and check the audit log
UPDATE employees SET salary = 95000 WHERE emp_id = 107;
SELECT * FROM salary_audit;


-- 5. BEFORE INSERT trigger – auto-uppercase the name
CREATE OR REPLACE FUNCTION fn_uppercase_name()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.name := INITCAP(NEW.name);   -- Title Case
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_format_name
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION fn_uppercase_name();

-- Test: insert with lowercase
CALL sp_add_employee(202, 'sanjay kumar', 3, 52000, 'Kozhikode');
SELECT name FROM employees WHERE emp_id = 202;  -- → 'Sanjay Kumar'


-- 6. BEFORE DELETE trigger – prevent deletion of high earners
CREATE OR REPLACE FUNCTION fn_block_delete_high_earner()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.salary > 90000 THEN
        RAISE EXCEPTION 'Cannot delete employee % with salary > 90,000.', OLD.emp_id;
    END IF;
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER trg_protect_high_earner
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION fn_block_delete_high_earner();


