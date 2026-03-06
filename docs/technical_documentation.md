# Technical Documentation

## Database Schema

### Table Relationships
```
patients (1) ←→ (many) encounters (many) ←→ (1) procedures
patients (1) ←→ (many) encounters (many) ←→ (1) payers
patients (1) ←→ (many) encounters (many) ←→ (1) organizations
```

### Key SQL Queries Explained

#### 1. Encounter Volume Analysis
```sql
-- Purpose: Track yearly patient volume trends
-- Business Impact: Resource planning and capacity management
SELECT 
    YEAR(START) as encounter_year,
    COUNT(*) as total_encounters,
    CONCAT('Total encounters in ', YEAR(START), ': ', COUNT(*)) as summary
FROM encounters 
GROUP BY YEAR(START)
ORDER BY encounter_year;
```

#### 2. Financial Performance Analysis  
```sql
-- Purpose: Analyze cost patterns and payer coverage
-- Business Impact: Revenue optimization and contract negotiations
SELECT 
    YEAR(e.START) as encounter_year,
    p.NAME as payer_name,
    SUM(e.Total_Claim_Cost) as total_claims,
    SUM(e.Payer_Coverage) as total_coverage,
    ROUND(AVG(e.Payer_Coverage / e.Total_Claim_Cost) * 100, 2) as coverage_rate
FROM encounters e
JOIN payers p ON e.Payer = p.Id
GROUP BY YEAR(e.START), p.NAME;
```

#### 3. Readmission Risk Analysis
```sql
-- Purpose: Identify patients with high readmission rates
-- Business Impact: Quality improvement and care coordination
WITH patient_encounters AS (
    SELECT 
        Patient,
        YEAR(START) as encounter_year,
        COUNT(*) as encounter_count
    FROM encounters
    GROUP BY Patient, YEAR(START)
)
SELECT 
    encounter_year,
    COUNT(*) as total_patients,
    SUM(CASE WHEN encounter_count > 3 THEN 1 ELSE 0 END) as high_risk_patients,
    ROUND(SUM(CASE WHEN encounter_count > 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as high_risk_percentage
FROM patient_encounters
GROUP BY encounter_year;
```

## Data Quality Checks

### Automated Validation Rules
1. **Date Validation:** Ensure START < STOP for all encounters
2. **Cost Validation:** Base_Cost ≤ Total_Claim_Cost for all procedures  
3. **Referential Integrity:** All foreign keys must exist in parent tables
4. **Data Completeness:** Required fields must not be NULL

### Performance Optimization
- **Indexing Strategy:** Created indexes on frequently queried columns (START, Patient, Payer)
- **Query Optimization:** Used appropriate JOIN types and WHERE clauses
- **Partitioning:** Considered date-based partitioning for large encounter tables

## Power BI Dashboard Architecture

### Data Model
- **Fact Table:** Encounters (central fact table)
- **Dimension Tables:** Patients, Payers, Organizations, Procedures
- **Relationships:** Star schema design for optimal performance

### DAX Measures
```dax
// Year-over-Year Growth
YoY Growth = 
VAR CurrentYear = SELECTEDVALUE(Encounters[Year])
VAR PreviousYear = CurrentYear - 1
RETURN 
DIVIDE(
    [Total Encounters] - CALCULATE([Total Encounters], Encounters[Year] = PreviousYear),
    CALCULATE([Total Encounters], Encounters[Year] = PreviousYear)
)

// Coverage Rate
Coverage Rate = 
DIVIDE(
    SUM(Encounters[Payer Coverage]),
    SUM(Encounters[Total Claim Cost])
)
```

## Deployment & Maintenance

### Automated Refresh Schedule
- **Frequency:** Daily at 2:00 AM UTC
- **Failure Handling:** Email notifications for refresh failures
- **Data Validation:** Automated quality checks before dashboard update

### Monitoring & Alerts
- **Performance Metrics:** Query execution time, dashboard load time
- **Data Quality:** Missing data alerts, outlier detection
- **Usage Analytics:** Dashboard access patterns and user engagement
