-- EDU01 sample schema and seed data for K-12 student information + Fabric NLQ lab
-- Run this script against your deployed Azure SQL Database.
-- The data is fully synthetic and denormalized for lab purposes. It mirrors the
-- kind of roster, demographic, attendance, and assessment records that a K-12
-- Student Information System (SIS) such as PowerSchool, Infinite Campus, or
-- Skyward would export.

IF OBJECT_ID('dbo.StudentInformation', 'U') IS NOT NULL
    DROP TABLE dbo.StudentInformation;
GO

CREATE TABLE dbo.StudentInformation (
    StudentID INT NOT NULL PRIMARY KEY,
    StudentNumber NVARCHAR(20) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    GradeLevel NVARCHAR(5) NOT NULL,
    SchoolName NVARCHAR(100) NOT NULL,
    SchoolLevel NVARCHAR(20) NOT NULL,
    DistrictName NVARCHAR(80) NOT NULL,
    State NVARCHAR(30) NOT NULL,
    EnrollmentDate DATE NOT NULL,
    EnrollmentStatus NVARCHAR(20) NOT NULL,
    Gender NVARCHAR(20) NOT NULL,
    Ethnicity NVARCHAR(40) NOT NULL,
    EconomicallyDisadvantaged NVARCHAR(5) NOT NULL,
    EnglishLearner NVARCHAR(5) NOT NULL,
    SpecialEducation NVARCHAR(5) NOT NULL,
    AttendanceRatePct DECIMAL(5,2) NOT NULL,
    AbsenceDays INT NOT NULL,
    TardyCount INT NOT NULL,
    GPA DECIMAL(3,2) NOT NULL,
    MathScore INT NOT NULL,
    ReadingScore INT NOT NULL,
    ScienceScore INT NOT NULL,
    PerformanceLevel NVARCHAR(20) NOT NULL,
    CreditsEarned DECIMAL(5,2) NOT NULL,
    HomeroomTeacher NVARCHAR(80) NOT NULL,
    Counselor NVARCHAR(80) NOT NULL,
    LastUpdatedDate DATE NOT NULL
);
GO

;WITH numbers AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
base AS (
    SELECT
        100000 + n AS StudentID,
        CONCAT('SIS-', RIGHT('000000' + CAST(100000 + n AS VARCHAR(6)), 6)) AS StudentNumber,
        CASE (n - 1) % 24
            WHEN 0 THEN 'Ava'
            WHEN 1 THEN 'Liam'
            WHEN 2 THEN 'Mia'
            WHEN 3 THEN 'Noah'
            WHEN 4 THEN 'Isabella'
            WHEN 5 THEN 'Ethan'
            WHEN 6 THEN 'Sophia'
            WHEN 7 THEN 'Mason'
            WHEN 8 THEN 'Camila'
            WHEN 9 THEN 'Lucas'
            WHEN 10 THEN 'Amelia'
            WHEN 11 THEN 'Logan'
            WHEN 12 THEN 'Harper'
            WHEN 13 THEN 'Jackson'
            WHEN 14 THEN 'Evelyn'
            WHEN 15 THEN 'Aiden'
            WHEN 16 THEN 'Abigail'
            WHEN 17 THEN 'Elijah'
            WHEN 18 THEN 'Emily'
            WHEN 19 THEN 'James'
            WHEN 20 THEN 'Ella'
            WHEN 21 THEN 'Benjamin'
            WHEN 22 THEN 'Scarlett'
            ELSE 'Henry'
        END AS FirstName,
        CASE (n - 1) % 20
            WHEN 0 THEN 'Smith'
            WHEN 1 THEN 'Johnson'
            WHEN 2 THEN 'Martinez'
            WHEN 3 THEN 'Garcia'
            WHEN 4 THEN 'Nguyen'
            WHEN 5 THEN 'Williams'
            WHEN 6 THEN 'Brown'
            WHEN 7 THEN 'Jones'
            WHEN 8 THEN 'Miller'
            WHEN 9 THEN 'Davis'
            WHEN 10 THEN 'Rodriguez'
            WHEN 11 THEN 'Lopez'
            WHEN 12 THEN 'Wilson'
            WHEN 13 THEN 'Anderson'
            WHEN 14 THEN 'Thomas'
            WHEN 15 THEN 'Taylor'
            WHEN 16 THEN 'Moore'
            WHEN 17 THEN 'Jackson'
            WHEN 18 THEN 'Martin'
            ELSE 'Lee'
        END AS LastName,
        CASE
            WHEN x.si <= 5 THEN
                CASE (n - 1) % 6
                    WHEN 0 THEN 'K'
                    WHEN 1 THEN '01'
                    WHEN 2 THEN '02'
                    WHEN 3 THEN '03'
                    WHEN 4 THEN '04'
                    ELSE '05'
                END
            WHEN x.si <= 8 THEN
                CASE (n - 1) % 3
                    WHEN 0 THEN '06'
                    WHEN 1 THEN '07'
                    ELSE '08'
                END
            ELSE
                CASE (n - 1) % 4
                    WHEN 0 THEN '09'
                    WHEN 1 THEN '10'
                    WHEN 2 THEN '11'
                    ELSE '12'
                END
        END AS GradeLevel,
        CASE x.si
            WHEN 0 THEN 'Lincoln Elementary School'
            WHEN 1 THEN 'Jefferson Elementary School'
            WHEN 2 THEN 'Roosevelt Elementary School'
            WHEN 3 THEN 'Kennedy Elementary School'
            WHEN 4 THEN 'Adams Elementary School'
            WHEN 5 THEN 'Madison Elementary School'
            WHEN 6 THEN 'Franklin Middle School'
            WHEN 7 THEN 'Hamilton Middle School'
            WHEN 8 THEN 'Monroe Middle School'
            WHEN 9 THEN 'Washington High School'
            WHEN 10 THEN 'Clinton High School'
            ELSE 'Jackson High School'
        END AS SchoolName,
        CASE
            WHEN x.si <= 5 THEN 'Elementary'
            WHEN x.si <= 8 THEN 'Middle'
            ELSE 'High'
        END AS SchoolLevel,
        CASE (n - 1) % 6
            WHEN 0 THEN 'Riverside Unified School District'
            WHEN 1 THEN 'Lakeview Consolidated School District'
            WHEN 2 THEN 'Summit Valley School District'
            WHEN 3 THEN 'Harbor County Public Schools'
            WHEN 4 THEN 'Prairie Ridge School District'
            ELSE 'Cedar Grove Area Schools'
        END AS DistrictName,
        CASE (n - 1) % 6
            WHEN 0 THEN 'California'
            WHEN 1 THEN 'Illinois'
            WHEN 2 THEN 'Colorado'
            WHEN 3 THEN 'New York'
            WHEN 4 THEN 'Iowa'
            ELSE 'Oregon'
        END AS State,
        DATEADD(DAY, -((n * 11) % 730), CAST('2026-01-15' AS DATE)) AS EnrollmentDate,
        CASE (n - 1) % 20
            WHEN 0 THEN 'Transferred'
            WHEN 1 THEN 'Inactive'
            WHEN 2 THEN 'Graduated'
            ELSE 'Active'
        END AS EnrollmentStatus,
        CASE (n - 1) % 2
            WHEN 0 THEN 'Female'
            ELSE 'Male'
        END AS Gender,
        CASE (n - 1) % 7
            WHEN 0 THEN 'White'
            WHEN 1 THEN 'Hispanic/Latino'
            WHEN 2 THEN 'Black/African American'
            WHEN 3 THEN 'Asian'
            WHEN 4 THEN 'Two or More Races'
            WHEN 5 THEN 'American Indian/Alaska Native'
            ELSE 'Native Hawaiian/Pacific Islander'
        END AS Ethnicity,
        CASE WHEN (n % 10) IN (0, 1, 2, 3) THEN 'Yes' ELSE 'No' END AS EconomicallyDisadvantaged,
        CASE WHEN (n % 10) IN (0, 1) THEN 'Yes' ELSE 'No' END AS EnglishLearner,
        CASE WHEN (n % 8) = 0 THEN 'Yes' ELSE 'No' END AS SpecialEducation,
        CAST(80.0 + (((n * 7) % 200) / 10.0) AS DECIMAL(5,2)) AS AttendanceRatePct,
        (n * 3) % 25 AS AbsenceDays,
        (n * 5) % 18 AS TardyCount,
        CAST(1.50 + (((n * 11) % 250) / 100.0) AS DECIMAL(3,2)) AS GPA,
        45 + ((n * 13) % 56) AS MathScore,
        45 + ((n * 17) % 56) AS ReadingScore,
        45 + ((n * 19) % 56) AS ScienceScore,
        CAST(
            CASE
                WHEN x.si >= 9 THEN 4.0 + (((n * 7) % 120) / 10.0)
                ELSE 0
            END AS DECIMAL(5,2)
        ) AS CreditsEarned,
        CASE (n - 1) % 10
            WHEN 0 THEN 'Ms. Alvarez'
            WHEN 1 THEN 'Mr. Bennett'
            WHEN 2 THEN 'Ms. Carter'
            WHEN 3 THEN 'Mr. Delgado'
            WHEN 4 THEN 'Ms. Foster'
            WHEN 5 THEN 'Mr. Grant'
            WHEN 6 THEN 'Ms. Hayes'
            WHEN 7 THEN 'Mr. Ibarra'
            WHEN 8 THEN 'Ms. Jensen'
            ELSE 'Mr. Kowalski'
        END AS HomeroomTeacher,
        CASE (n - 1) % 6
            WHEN 0 THEN 'Dr. Nguyen'
            WHEN 1 THEN 'Dr. Patel'
            WHEN 2 THEN 'Dr. Okafor'
            WHEN 3 THEN 'Dr. Ramirez'
            WHEN 4 THEN 'Dr. Chen'
            ELSE 'Dr. Brooks'
        END AS Counselor,
        DATEADD(DAY, -((n * 3) % 60), CAST('2026-01-15' AS DATE)) AS LastUpdatedDate
    FROM numbers
    CROSS APPLY (SELECT (n - 1) % 12 AS si) AS x
)
INSERT INTO dbo.StudentInformation (
    StudentID,
    StudentNumber,
    FirstName,
    LastName,
    GradeLevel,
    SchoolName,
    SchoolLevel,
    DistrictName,
    State,
    EnrollmentDate,
    EnrollmentStatus,
    Gender,
    Ethnicity,
    EconomicallyDisadvantaged,
    EnglishLearner,
    SpecialEducation,
    AttendanceRatePct,
    AbsenceDays,
    TardyCount,
    GPA,
    MathScore,
    ReadingScore,
    ScienceScore,
    PerformanceLevel,
    CreditsEarned,
    HomeroomTeacher,
    Counselor,
    LastUpdatedDate
)
SELECT
    StudentID,
    StudentNumber,
    FirstName,
    LastName,
    GradeLevel,
    SchoolName,
    SchoolLevel,
    DistrictName,
    State,
    EnrollmentDate,
    EnrollmentStatus,
    Gender,
    Ethnicity,
    EconomicallyDisadvantaged,
    EnglishLearner,
    SpecialEducation,
    AttendanceRatePct,
    AbsenceDays,
    TardyCount,
    GPA,
    MathScore,
    ReadingScore,
    ScienceScore,
    CASE
        WHEN (MathScore + ReadingScore + ScienceScore) / 3 >= 85 THEN 'Advanced'
        WHEN (MathScore + ReadingScore + ScienceScore) / 3 >= 70 THEN 'Proficient'
        WHEN (MathScore + ReadingScore + ScienceScore) / 3 >= 55 THEN 'Basic'
        ELSE 'Below Basic'
    END AS PerformanceLevel,
    CreditsEarned,
    HomeroomTeacher,
    Counselor,
    LastUpdatedDate
FROM base;
GO

-- Validation query 1: Confirm row count.
SELECT COUNT(*) AS StudentCount
FROM dbo.StudentInformation;
GO

-- Validation query 2: Active enrollment by school level.
SELECT
    SchoolLevel,
    COUNT(*) AS ActiveStudents,
    CAST(AVG(AttendanceRatePct) AS DECIMAL(5,2)) AS AvgAttendancePct,
    CAST(AVG(GPA) AS DECIMAL(3,2)) AS AvgGPA
FROM dbo.StudentInformation
WHERE EnrollmentStatus = 'Active'
GROUP BY SchoolLevel
ORDER BY ActiveStudents DESC;
GO

-- Validation query 3: Students who may need intervention first
-- (low attendance combined with low GPA).
SELECT TOP 10
    StudentNumber,
    FirstName,
    LastName,
    GradeLevel,
    SchoolName,
    AttendanceRatePct,
    GPA,
    PerformanceLevel
FROM dbo.StudentInformation
WHERE EnrollmentStatus = 'Active'
ORDER BY AttendanceRatePct ASC, GPA ASC;
GO
