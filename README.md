# Data Cleaning in SQL Project

## Overview
This project involves cleaning a dataset using SQL. The data cleaning process includes removing duplicates, standardizing data, handling null values, and eliminating unnecessary rows or columns. The steps outlined below detail the process followed to clean the dataset.

## Project Steps

### 1. Download Dataset
The dataset used in this project can be downloaded from the following my GitHub repository:
- [Dataset Link](https://github.com/mkkhan151/data-cleaning-in-SQL/blob/main/layoffs.csv)

### 2. Import Dataset in MySQL Workbench
Once the dataset is downloaded, import it into MySQL Workbench as a new table. This table will serve as the raw data that will be cleaned in subsequent steps.

### 3. Make a Copy of the Original Raw Table
Before performing any data cleaning operations, create a copy of the original table to preserve the raw data. This allows you to refer back to the original dataset if needed.

### 4. Perform Data Cleaning Steps
The following steps are performed in the SQL script to clean the dataset:

#### 4.1 Check Duplicates and Remove Duplicates
Identify and remove duplicate rows from the dataset to ensure each entry is unique.

#### 4.2 Standardize the Data
Standardize data entries for consistency. This includes formatting text, aligning date formats, and ensuring numerical data is correctly typed.

#### 4.3 Look at Null Values or Blank Values
Examine the dataset for null or blank values. Address these by either filling them with appropriate data, removing them, or applying other strategies.

#### 4.4 Remove Unnecessary Columns or Rows
Identify and remove any columns or rows that are not required for analysis or that could lead to inaccurate results.

### data_cleaning Script
All the above steps are documented and executed in the **data_cleaning.sql** script file. The script includes comments explaining each step in detail.

### EDA Script
All the Exploratory Data Analysis steps are documented and executed in the **eda.sql** script file. The script includes comments explaining each step in detail.

## Conclusion
This project demonstrates the process of cleaning a dataset using SQL, ensuring that the data is ready for analysis. The cleaned data is stored in a separate table, which can be used for further data analysis or reporting.
