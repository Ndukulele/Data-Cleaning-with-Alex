# Data Cleaning project

This is a description of everything that was done to the [data](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv) step by step.

## Data Cleaning using MySql
- removed duplicates
- populated blank or null values where possible
- standerdised data
- removed columns

### Removed duplicates
- used the Row Number function to return any duplicated data then deleted them using the DELETE function

### standerdising data
- the TRIM function was used to remove spaces in the data
- to remove TRIM(TRAILING) to remove fullstops in the data
- to normalised data that was inputed incorrectly to the desirable input

### populate blank or null values
- when populating blank or null values it is hard to manipulate blank values so first it must they must be turned to null values for it to be easier to work with
- used already available data as reference to populate data where needed
- removed rows where data will be unusable

### removed columns
- removed the 'row_numb' column since its use has been fulfilled and it won't be needed anymore
