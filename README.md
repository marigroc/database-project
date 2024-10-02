


# QA Data Management Database

## Overview
This project is an Access database designed to manage contacts and QA data for probes across different departments. The aim is to enhance reporting transparency, facilitate quick analysis of QA data, and unify report formats.

## Features
- **Sites Management**: Add, edit, and manage site information.
- **Departments Management**: Manage departments with associated contacts.
- **Scanners and Probes Tracking**: Track scanners and probes, including their details and QA results.
- **Dynamic Reporting**: Generate reports based on selected parameters, including month and year.
- **Error Handling**: Built-in error handling to prevent incorrect data entry and handle null values.

## Database Structure
![image](https://github.com/user-attachments/assets/ab6e1adb-c0a1-42b5-a374-438d7c045371)
### Tables
1. **Sites**
   - `id` 
   - `site_name` (Primary Key)
   - `site_address`
   - `is_current`

2. **Departments**
   - `id` 
   - `dept_name` (Primary Key)
   - `site` (Foreign Key)
   - `contact`
   - `contact_number`
   - `contact_email`
   - `is_current`

3. **Scanners**
   - `id` 
   - `scanner_id`
   - `dept` (Foreign Key)
   - `brand`
   - `model`
   - `serial_number` (Primary Key)
   - `loan`
   - `site`
   - `is_current`

4. **Probes**
   - `id` 
   - `scanner_id` (Foreign Key)
   - `dept`
   - `model`
   - `type`
   - `serial_number` (Primary Key)
   - `loan`
   - `status`
   - `customer_comment`
   - `is_current`

5. **Results**
   - `id` (Primary Key)
   - `date`
   - `serial_number` 
   - `qa_cl_rev`
   - `qa_cl_gn`
   - `qa_cl_c`
   - `qa_ph_rev`
   - `qa_ph_gn`
   - `phys_comment`

## Usage
1. Open the Access database.
2. Use the forms to add or manage sites, departments, scanners, and probes.
3. Generate reports by selecting the desired parameters.
4. Follow prompts for error handling during data entry.

## Getting Started
1. Ensure you have Microsoft Access installed.
2. Download the database file.
3. Open the file and enable macros if prompted.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

## License
This project is licensed under the [MIT License](LICENSE).

## Acknowledgements
- [Microsoft Access](https://www.microsoft.com/en-us/microsoft-365/access) for database management.
