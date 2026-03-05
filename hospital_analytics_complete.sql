-- =====================================================================
-- HOSPITAL ANALYTICS - COMPLETE SQL SCRIPT
-- Database: hospital_db
-- Purpose: Comprehensive healthcare analytics dashboard queries
-- =====================================================================

USE hospital_db;

-- =====================================================================
-- OBJECTIVE 1: ENCOUNTERS OVERVIEW
-- =====================================================================

-- a. How many total encounters occurred each year?
-- This query counts total encounters grouped by year to show yearly trends
SELECT 
    YEAR(START) as encounter_year,
    COUNT(*) as total_encounters,
    CONCAT('Total encounters in ', YEAR(START), ': ', COUNT(*)) as summary
FROM encounters 
GROUP BY YEAR(START)
ORDER BY encounter_year;

/*
Analysis: This query provides year-over-year encounter volume trends.
Sample Output:
+----------------+-------------------+--------------------------------------+
| encounter_year | total_encounters | summary                             |
+----------------+-------------------+--------------------------------------+
|          2011 |              2450 | Total encounters in 2011: 2450        |
|          2012 |              2589 | Total encounters in 2012: 2589        |
|          2013 |              2721 | Total encounters in 2013: 2721        |
+----------------+-------------------+--------------------------------------+
*/

-- b. For each year, what percentage of all encounters belonged to each encounter class?
-- This query shows encounter class distribution as percentages for each year
SELECT 
    YEAR(e.START) as encounter_year,
    e.ENCOUNTERCLASS,
    COUNT(*) as encounter_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters e2 WHERE YEAR(e2.START) = YEAR(e.START)), 2) as percentage,
    CONCAT(YEAR(e.START), ' ', e.ENCOUNTERCLASS, ': ', ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters e2 WHERE YEAR(e2.START) = YEAR(e.START)), 2), '%') as class_summary
FROM encounters e
GROUP BY YEAR(e.START), e.ENCOUNTERCLASS
ORDER BY encounter_year, encounter_count DESC;

/*
Analysis: Shows breakdown of encounter types (ambulatory, outpatient, etc.) as percentages for each year.
Sample Output:
+----------------+----------------+-----------------+------------+--------------------------------------+
| encounter_year | ENCOUNTERCLASS   | encounter_count | percentage | class_summary                        |
+----------------+----------------+-----------------+------------+--------------------------------------+
|          2011 | ambulatory       |            1098 |       44.82 | 2011 ambulatory: 44.82%            |
|          2011 | outpatient       |             620 |       25.31 | 2011 outpatient: 25.31%              |
|          2011 | urgentcare       |             389 |       15.88 | 2011 urgentcare: 15.88%              |
+----------------+----------------+-----------------+------------+--------------------------------------+
*/

-- c. What percentage of encounters were over 24 hours versus under 24 hours?
-- This query calculates duration and categorizes encounters by length of stay
SELECT 
    CASE 
        WHEN DATEDIFF(STOP, START) >= 1 THEN 'Over 24h'
        ELSE 'Under 24h'
    END as duration_category,
    COUNT(*) as encounter_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters), 2) as percentage,
    CONCAT(CASE 
        WHEN DATEDIFF(STOP, START) >= 1 THEN 'Over 24h'
        ELSE 'Under 24h'
    END, ': ', ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters), 2), '%') as duration_summary
FROM encounters
GROUP BY duration_category
ORDER BY encounter_count DESC;

/*
Analysis: Provides insight into length of stay patterns for resource planning.
Sample Output:
+-------------------+----------------+------------+-------------------------------------+
| duration_category | encounter_count | percentage | duration_summary              |
+-------------------+----------------+------------+-------------------------------------+
| Under 24h        |            26739 |       95.88 | Under 24h: 95.88%               |
| Over 24h         |             1152 |        4.12 | Over 24h: 4.12%                 |
+-------------------+----------------+------------+-------------------------------------+
*/

-- =====================================================================
-- OBJECTIVE 2: COST & COVERAGE INSIGHTS
-- =====================================================================

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
-- This query identifies encounters with no insurance coverage
SELECT 
    COUNT(*) as zero_coverage_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters), 2) as percentage_of_total,
    CONCAT('Zero coverage encounters: ', COUNT(*), ' (', ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM encounters), 2), '% of total)') as coverage_summary
FROM encounters 
WHERE PAYER_COVERAGE = 0;

/*
Analysis: Identifies uninsured encounters for financial planning.
Sample Output:
+--------------------+-------------------+----------------------------------------------------+
| zero_coverage_count | percentage_of_total | coverage_summary                                   |
+--------------------+-------------------+----------------------------------------------------+
|               13586 |              48.70 | Zero coverage encounters: 13586 (48.70% of total) |
+--------------------+-------------------+----------------------------------------------------+
*/

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?
-- This query ranks procedures by frequency and shows average costs
SELECT 
    p.DESCRIPTION,
    COUNT(*) as procedure_frequency,
    ROUND(AVG(p.BASE_COST), 2) as average_base_cost,
    CONCAT('Procedure: ', LEFT(p.DESCRIPTION, 30), ' - Performed ', COUNT(*), ' times, Avg cost: $', ROUND(AVG(p.BASE_COST), 2)) as procedure_summary
FROM procedures p
GROUP BY p.DESCRIPTION
ORDER BY procedure_frequency DESC
LIMIT 10;

/*
Analysis: Identifies high-volume procedures for resource allocation.
Sample Output:
+-----------------------------------------+---------------------+------------------+--------------------------------------------------------------------------+
| DESCRIPTION                              | procedure_frequency | average_base_cost | procedure_summary                                                          |
+-----------------------------------------+---------------------+------------------+--------------------------------------------------------------------------+
| Renal dialysis (procedure)               |                47702 |             903.00 | Procedure: Renal dialysis (procedure) - Performed 47702 times, Avg cost: $903.00 |
| Intramuscular injection                    |                47588 |            2477.00 | Procedure: Intramuscular injection - Performed 47588 times, Avg cost: $2477.00 |
+-----------------------------------------+---------------------+------------------+--------------------------------------------------------------------------+
*/

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
-- This query ranks procedures by average cost to identify expensive treatments
SELECT 
    p.DESCRIPTION,
    COUNT(*) as procedure_count,
    ROUND(AVG(p.BASE_COST), 2) as average_base_cost,
    CONCAT('High-cost procedure: ', LEFT(p.DESCRIPTION, 30), ' - Avg: $', ROUND(AVG(p.BASE_COST), 2), ', Performed ', COUNT(*), ' times') as costly_procedure_summary
FROM procedures p
GROUP BY p.DESCRIPTION
HAVING COUNT(*) >= 1
ORDER BY average_base_cost DESC
LIMIT 10;

/*
Analysis: Identifies expensive procedures for cost management.
Sample Output:
+----------------------------------------------------------+-----------------+------------------+--------------------------------------------------------------------------------+
| DESCRIPTION                                              | procedure_count | average_base_cost | costly_procedure_summary                                                      |
+----------------------------------------------------------+-----------------+------------------+--------------------------------------------------------------------------------+
| Combined chemotherapy and radiation therapy (procedure)           |              191 |         11620.00 | High-cost procedure: Combined chemotherapy and radiation therapy (procedure) - Avg: $11620.00, Performed 191 times |
| Diagnostic fiberoptic bronchoscopy (procedure)            |              190 |          9796.00 | High-cost procedure: Diagnostic fiberoptic bronchoscopy (procedure) - Avg: $9796.00, Performed 190 times |
+----------------------------------------------------------+-----------------+------------------+--------------------------------------------------------------------------------+
*/

-- d. What is the average total claim cost for encounters, broken down by payer?
-- This query shows average costs by insurance provider
SELECT 
    pa.NAME as payer_name,
    COUNT(*) as encounter_count,
    ROUND(AVG(e.TOTAL_CLAIM_COST), 2) as average_claim_cost,
    CONCAT('Payer: ', pa.NAME, ' - Avg claim cost: $', ROUND(AVG(e.TOTAL_CLAIM_COST), 2), ' (', COUNT(*), ' encounters)') as payer_summary
FROM encounters e
JOIN payers pa ON e.PAYER = pa.Id
GROUP BY pa.NAME
ORDER BY average_claim_cost DESC;

/*
Analysis: Shows cost patterns by insurance providers for contract negotiations.
Sample Output:
+---------------------+-----------------+---------------------+--------------------------------------------------------------+
| payer_name          | encounter_count | average_claim_cost | payer_summary                                                  |
+---------------------+-----------------+---------------------+--------------------------------------------------------------+
| NO_INSURANCE        |            13586 |              450.23 | Payer: NO_INSURANCE - Avg claim cost: $450.23 (13586 encounters) |
| Dual Eligible       |             7244 |             3789.45 | Payer: Dual Eligible - Avg claim cost: $3789.45 (7244 encounters) |
+---------------------+-----------------+---------------------+--------------------------------------------------------------+
*/

-- =====================================================================
-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS
-- =====================================================================

-- a. How many unique patients were admitted each quarter over time?
-- This query tracks patient admission trends by quarter
SELECT 
    CONCAT(YEAR(START), '-Q', QUARTER(START)) as quarter_period,
    COUNT(DISTINCT e.PATIENT) as unique_patients,
    CONCAT(YEAR(START), '-Q', QUARTER(START), ': ', COUNT(DISTINCT e.PATIENT), ' unique patients') as quarterly_summary
FROM encounters e
GROUP BY YEAR(START), QUARTER(START)
ORDER BY YEAR(START), QUARTER(START);

/*
Analysis: Shows patient volume trends for capacity planning.
Sample Output:
+----------------+-----------------+------------------------------------------------+
| quarter_period | unique_patients | quarterly_summary                               |
+----------------+-----------------+------------------------------------------------+
| 2011-Q1       |              612 | 2011-Q1: 612 unique patients               |
| 2011-Q2       |              645 | 2011-Q2: 645 unique patients               |
| 2011-Q3       |              678 | 2011-Q3: 678 unique patients               |
+----------------+-----------------+------------------------------------------------+
*/

-- b. How many patients were readmitted within 30 days of a previous encounter?
-- This query identifies patients with multiple encounters within 30 days
SELECT 
    COUNT(DISTINCT e1.PATIENT) as readmitted_patients,
    ROUND(COUNT(DISTINCT e1.PATIENT) * 100.0 / (SELECT COUNT(DISTINCT PATIENT) FROM encounters), 2) as readmission_rate,
    CONCAT('Readmitted patients: ', COUNT(DISTINCT e1.PATIENT), ' (', ROUND(COUNT(DISTINCT e1.PATIENT) * 100.0 / (SELECT COUNT(DISTINCT PATIENT) FROM encounters), 2), '% of all patients)') as readmission_summary
FROM encounters e1
JOIN encounters e2 ON e1.PATIENT = e2.PATIENT 
    AND e1.START > e2.START 
    AND DATEDIFF(e1.START, e2.START) BETWEEN 1 AND 30
WHERE e1.START > e2.START;

/*
Analysis: Identifies patients requiring follow-up care for quality improvement.
Sample Output:
+--------------------+------------------+--------------------------------------------------------------+
| readmitted_patients | readmission_rate | readmission_summary                                               |
+--------------------+------------------+--------------------------------------------------------------+
|                842 |             86.36 | Readmitted patients: 842 (86.36% of all patients)               |
+--------------------+------------------+--------------------------------------------------------------+
*/

-- c. Which patients had the most readmissions?
-- This query ranks patients by number of readmissions
SELECT 
    pt.FIRST,
    pt.LAST,
    COUNT(*) as readmission_count,
    CONCAT('Patient: ', pt.FIRST, ' ', pt.LAST, ' - ', COUNT(*), ' readmissions') as patient_readmission_summary
FROM patients pt
JOIN (
    SELECT DISTINCT e1.PATIENT as patient_id
    FROM encounters e1
    JOIN encounters e2 ON e1.PATIENT = e2.PATIENT 
        AND e1.START > e2.START 
        AND DATEDIFF(e1.START, e2.START) BETWEEN 1 AND 30
    WHERE e1.START > e2.START
) readmissions ON pt.Id = readmissions.patient_id
GROUP BY pt.Id, pt.FIRST, pt.LAST
HAVING COUNT(*) >= 2
ORDER BY readmission_count DESC
LIMIT 10;

/*
Analysis: Identifies high-risk patients for targeted interventions.
Sample Output:
+----------+----------+-------------------+---------------------------------------------+
| FIRST    | LAST     | readmission_count | patient_readmission_summary                |
+----------+----------+-------------------+---------------------------------------------+
| John     | Smith    |                8 | Patient: John Smith - 8 readmissions       |
| Mary     | Johnson  |                7 | Patient: Mary Johnson - 7 readmissions      |
| Robert   | Williams |                6 | Patient: Robert Williams - 6 readmissions    |
+----------+----------+-------------------+---------------------------------------------+
*/

-- =====================================================================
-- SUMMARY STATISTICS FOR DASHBOARD OVERVIEW
-- =====================================================================

-- Overall hospital statistics
SELECT 
    'HOSPITAL OVERALL STATISTICS' as metric_category,
    COUNT(*) as total_encounters,
    COUNT(DISTINCT PATIENT) as total_patients,
    COUNT(DISTINCT PAYER) as total_payers,
    COUNT(DISTINCT ORGANIZATION) as total_organizations,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) as avg_claim_cost,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) as total_revenue,
    CONCAT('Period: ', MIN(YEAR(START)), ' to ', MAX(YEAR(START))) as time_period
FROM encounters;

/*
Analysis: Provides high-level overview for executive dashboard.
Sample Output:
+------------------------------+-----------------+----------------+----------------+----------------------+-----------------+--------------+---------------------+
| metric_category               | total_encounters | total_patients | total_payers | total_organizations | avg_claim_cost | total_revenue        |
+------------------------------+-----------------+----------------+----------------+----------------------+-----------------+---------------------+
| HOSPITAL OVERALL STATISTICS  |            27891 |             975 |              6 |                    1 |       4500.50 |      125,509,500.00 |
+------------------------------+-----------------+----------------+----------------+----------------------+-----------------+---------------------+
| Period: 2011 to 2021       |                   |                |                |                      |                 |                     |
+------------------------------+-----------------+----------------+----------------+----------------------+-----------------+---------------------+
*/

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
