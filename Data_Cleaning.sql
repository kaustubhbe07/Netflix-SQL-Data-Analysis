--1)Standardize Dates:Convert 'date_added' column from string to Standard YYYY-MM-DD date format.
UPDATE netflix_titles 
SET date_added = STR_TO_DATE(TRIM(date_added), '%M %e, %Y')
WHERE date_added IS NOT NULL AND date_added != '';

ALTER TABLE netflix_titles 
MODIFY COLUMN date_added DATE;
