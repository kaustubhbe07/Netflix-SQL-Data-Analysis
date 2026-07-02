--Create the database
CREATE DATABASE netflix_db;

--Switch to the new database
USE netflix_db;

--Schema of Netflix Dataset
--create a table
DROP TABLE IF EXISTS netflix_titles;
CREATE TABLE netflix_titles (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(15),
    duration VARCHAR(20),
    listed_in VARCHAR(255),
    description VARCHAR(550)
);