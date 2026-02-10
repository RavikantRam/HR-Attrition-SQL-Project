-- Stores original HR data exactly as received from CSV 
CREATE TABLE hr_data (
    Age INT,
    Attrition VARCHAR(5),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,  -- unique employee ID from source
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(5),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

-- Check full data
select * from hr_data;

-- Verify total records
SELECT COUNT(*) FROM hr_data;

-- Preview sample data
SELECT * FROM hr_data LIMIT 5;

-- Identify unique departments
SELECT DISTINCT Department FROM hr_data;

-- Identify unique job roles
SELECT DISTINCT JobRole FROM hr_data;

-- Stores unique departments
CREATE TABLE departments(
dept_id SERIAL PRIMARY KEY,
dept_name VARCHAR(50) UNIQUE
);

--I normalized department data to avoid repetition
-- Insert unique department names from raw data
INSERT INTO departments (dept_name)
SELECT DISTINCT Department FROM hr_data;

SELECT * FROM departments;

-- Stores unique job roles and job levels
CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    job_role VARCHAR(50),
    job_level INT
);

-- Insert distinct job roles with levels
INSERT INTO jobs (job_role, job_level)
SELECT DISTINCT JobRole, JobLevel FROM hr_data;

SELECT * FROM jobs; 

-- Main employee table with foreign keys
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    marital_status VARCHAR(20),
    dept_id INT REFERENCES departments(dept_id), --FORIEGN KEY
    job_id INT REFERENCES jobs(job_id), -- FORIEGN KEY
    monthly_income INT,
    total_working_years INT,
    years_at_company INT,
    attrition VARCHAR(5),
    overtime VARCHAR(5),
    job_satisfaction INT,
    work_life_balance INT,
    performance_rating INT
);

-- Lists all user-created tables in the public schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Insert employee data using joins to map department and job IDs
INSERT INTO employees (
    emp_id,
    age,
    gender,
    marital_status,
    dept_id,
    job_id,
    monthly_income,
    total_working_years,
    years_at_company,
    attrition,
    overtime,
    job_satisfaction,
    work_life_balance,
    performance_rating
)
SELECT
    h.EmployeeNumber,
    h.Age,
    h.Gender,
    h.MaritalStatus,
    d.dept_id,
    j.job_id,
    h.MonthlyIncome,
    h.TotalWorkingYears,
    h.YearsAtCompany,
    h.Attrition,
    h.OverTime,
    h.JobSatisfaction,
    h.WorkLifeBalance,
    h.PerformanceRating
FROM hr_data h
JOIN departments d
    ON h.Department = d.dept_name
JOIN jobs j
    ON h.JobRole = j.job_role
   AND h.JobLevel = j.job_level;

SELECT * FROM employees;

SELECT * FROM employees LIMIT 5;

-- Total employees per department
SELECT d.dept_name, COUNT(e.emp_id) AS total_employees
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- Attrition count per department
SELECT d.dept_name, COUNT(*) AS attrition_count
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.attrition = 'Yes'
GROUP BY d.dept_name;

-- Average salary by job role
SELECT j.job_role, AVG(e.monthly_income) AS avg_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_role;

SELECT emp_id, monthly_income
FROM employees
WHERE monthly_income > 10000
ORDER BY monthly_income DESC;

SELECT COUNT(*) 
FROM employees
WHERE overtime = 'Yes';

-- Index to optimize attrition-based queries
CREATE INDEX idx_employee_attrition ON employees(attrition);

-- Index to optimize attrition-based queries
CREATE INDEX idx_employee_income ON employees(monthly_income);

-- View all indexes on employees table
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Verify index usage and performance
EXPLAIN ANALYZE
SELECT * FROM employees
WHERE monthly_income > 80000;





