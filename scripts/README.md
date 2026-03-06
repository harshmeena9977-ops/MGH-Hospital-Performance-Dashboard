# SQL Scripts Documentation

## Script Overview

### 1. `create_hospital_db.sql`
**Purpose:** Creates the complete database schema and populates initial data
**Size:** 18.7MB (includes sample data generation)
**Execution Time:** ~2-3 minutes on standard MySQL instance

#### Key Components:
- Database creation and user permissions
- Table schema definitions with proper data types
- Foreign key relationships and constraints
- Sample data insertion for demonstration

### 2. `hospital_analytics_complete.sql`
**Purpose:** Comprehensive analytics queries for dashboard insights
**Size:** 16.5KB (292 lines of documented SQL)
**Execution Time:** ~30-45 seconds

#### Business Questions Answered:
1. **Encounter Volume Trends:** Yearly patient visit patterns
2. **Service Mix Analysis:** Distribution of encounter types
3. **Financial Performance:** Cost analysis and payer coverage
4. **Patient Behavior:** Readmission rates and high-risk identification
5. **Geographic Analysis:** Patient distribution by location

### 3. `hospital_analytics_questions.sql`
**Purpose:** Specific business questions for executive reporting
**Size:** 1.1KB (focused query examples)

## Query Categories

### Operational Analytics
```sql
-- Encounter volume by year and quarter
-- Average encounter duration by class
-- Peak demand periods identification
```

### Financial Analytics
```sql
-- Revenue trends by payer
-- Cost analysis by procedure type
-- Coverage gap identification
-- Profitability analysis
```

### Patient Analytics
```sql
-- Readmission risk factors
-- Patient demographic patterns
-- Geographic distribution analysis
-- High-risk patient identification
```

## Performance Optimization

### Index Recommendations
```sql
-- Recommended indexes for optimal performance:
CREATE INDEX idx_encounters_start ON encounters(START);
CREATE INDEX idx_encounters_patient ON encounters(Patient);
CREATE INDEX idx_encounters_payer ON encounters(Payer);
CREATE INDEX idx_procedures_patient ON procedures(Patient);
CREATE INDEX idx_procedures_encounter ON procedures(Encounter);
```

### Query Optimization Tips
1. Use appropriate WHERE clauses to limit data scope
2. Consider date range filtering for large datasets
3. Use EXPLAIN PLAN to analyze query performance
4. Implement proper JOIN strategies based on data volume

## Data Validation Scripts

### Quality Checks
```sql
-- Check for data completeness
SELECT 
    'encounters' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN START IS NULL THEN 1 END) as missing_start_dates,
    COUNT(CASE WHEN Patient IS NULL THEN 1 END) as missing_patients
FROM encounters
UNION ALL
-- Similar checks for other tables
```

### Business Logic Validation
```sql
-- Ensure cost calculations are logical
SELECT 
    COUNT(*) as invalid_costs
FROM procedures
WHERE Base_Cost > 100000 OR Base_Cost < 0;

-- Check date consistency
SELECT 
    COUNT(*) as invalid_dates
FROM encounters
WHERE START > STOP;
```

## Usage Instructions

### Running Complete Analysis
```bash
# Execute all scripts in order
mysql -u root -p < scripts/create_hospital_db.sql
mysql -u root -p hospital_db < scripts/hospital_analytics_complete.sql
```

### Running Specific Analysis
```bash
# Run only financial queries
mysql -u root -p hospital_db -e "
source scripts/hospital_analytics_complete.sql;
-- Focus on financial sections only
"
```

## Customization Guide

### Adding New Metrics
1. Identify business question
2. Design SQL query with proper joins
3. Add documentation and sample output
4. Test with sample data
5. Update Power BI data model if needed

### Modifying Time Periods
```sql
-- Change analysis period by modifying WHERE clauses
WHERE YEAR(START) BETWEEN 2020 AND 2022  -- Custom range
WHERE START >= '2021-01-01' AND START < '2022-01-01'  -- Specific year
```
