# Hospital Performance Dashboard — Synthetic Data Practice

An independent SQL and Power BI practice project exploring encounter, procedure, payer, and patient tables generated with Synthea. The project is not affiliated with Massachusetts General Hospital (MGH) and does not use real patient records.

## Repository contents

- [Power BI report](Hospital%20dashboard.pbix)
- Dashboard screenshots: [Encounters overview](Encounters_Overview.png.png), [Cost and coverage](Cost%26Coverage_Insights.png.png), and [Patient behavior](Patient_Behavior_Analysis.png.png)
- [CSV data files](data/)
- [SQL scripts](scripts/)
- [Dataset citation](docs/citation.txt)

## Data provenance and scope

The citation file references Synthea, a synthetic patient and electronic health record data generator. The data in this repository is synthetic and should not be interpreted as real hospital operations or clinical outcomes. No hospital client engagement or operational impact is claimed.

The repository includes CSVs for encounters, patients, procedures, payers, and organizations. Dataset size and date coverage are not stated here because they have not been reconciled against the files.

## Analysis artifacts

The SQL analytics script contains queries for encounter trends and classes, encounter duration, payer coverage and claim costs, procedure frequency and costs, quarterly patient counts, and a 30-day encounter recurrence query. These are exploratory/descriptive analyses over synthetic data. The supplied SQL includes sample output comments; those comments have not been independently reconciled against the CSVs or dashboard.

The PBIX and screenshots are included as artifacts. The repository does not currently contain a data dictionary, a documented KPI reconciliation, or a complete reproducible database setup: the referenced schema script is present but empty, and no database import instructions are verified.

## Viewing the dashboard

Open the PBIX in Power BI Desktop. The repository also includes static screenshots for preview. Reconnecting or refreshing the report may require updating its data source paths to the local CSV files; those paths have not been validated in a clean environment.

## SQL files

- [Hospital analytics queries](scripts/hospital_analytics_complete.sql)
- [Business questions](scripts/hospital_analytics_questions.sql)
- [Database schema script](scripts/create_hospital_db.sql) — currently empty; it does not create the database or tables.
