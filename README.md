# QA Data Management Database

## Overview

This database project is designed to replace multiple spreadsheets for managing contacts and Quality Assurance (QA) data for probes scattered across different departments. The implementation will improve the transparency of reporting and updating contact lists while facilitating quick analysis of QA data. Additionally, it will unify the format of the reports being issued.

## Features

- **Contact Management**: A structured approach to efficiently manage and update contact details.
- **QA Data Analysis**: Quick access to QA data for department probes, enabling better decision-making.
- **Unified Reporting**: Standardized report formats to enhance clarity and consistency.
- **User-Friendly Interface**: Easy-to-use forms for data entry and modifications.
- **Error Handling**: Robust error handling prevents incorrect data entry and ensures data integrity.

## Getting Started

### Prerequisites

- Microsoft Access (version X or higher)
- Basic understanding of relational databases and SQL

### Installation

1. **Clone the repository**:
   ```bash
   git clone (https://github.com/marigroc/database-project)

2. Open the Access database: Open the .accdb file in Microsoft Access.

3. Set up the database: Ensure all tables and relationships are correctly configured according to the project specifications.

## Usage
1. Adding QA results: use the "Monthly QA" tab in qa_form to add results.
2. Managing Records: Use the "Add/Remove" tab in the qa_monthly form to add, remove, and update site, department, scanner, probe, and contact person information.
3. Generating Reports: Use the "Report Diesel Generator" tab in the qa-monthly form, and choose the site, department, and date to generate the report.

## License
This project is licensed under the MIT License.
