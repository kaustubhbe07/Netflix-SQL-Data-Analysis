# Netflix Content Analysis using SQL

Exploring 8,800+ Netflix titles with SQL to uncover content, catalog, and release trends — from raw data to 20 answered business questions.

<p align="center">
  <img src="https://github.com/kaustubhbe07/Netflix-SQL-Data-Analysis/blob/main/logo.png" alt="[logo.png]" />
</p>

## 📊 Dataset

- **Source:** [Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows) (Kaggle)
- **Size:** 8,807 titles × 12 columns
- **Fields:** show ID, type, title, director, cast, country, date added, release year, rating, duration, genre, description

## 🎯 Objective

Analyze Netflix's content catalog to answer real-world business questions around content mix, regional trends, genre distribution, cast/director patterns, and platform growth over time.

## 🛠️ Tools

- **MySQL** — schema design, data cleaning, EDA, and query solutions
- Recursive CTEs, window functions, and self-joins for multi-value field parsing and ranking

## 🚀 Approach

1. **Schema Design** — defined a structured `netflix_titles` table (`Schema.sql`)
2. **Data Cleaning** — standardized inconsistent date formats into proper `DATE` types (`Data_Cleaning.sql`)
3. **Exploratory Data Analysis** — profiled record counts, missing values, distributions, and temporal trends (`EDA.sql`)
4. **Business Problem Solving** — answered 20 structured business questions using CTEs and window functions (`Solutions.sql`)

## 💡 Key Business Questions Solved

- What's the split between Movies and TV Shows on the platform?
- Which countries produce the most Netflix content?
- Who are the top directors in Thrillers and TV Mysteries?
- Which actor pair has co-starred together the most often?
- What's the most popular month for new content drops?
- How has cumulative content growth trended month-over-month?

*(Full list of 20 questions in `netflix_sql_project_questions.txt`)*

## 📈 Sample Insight

Out of **8,807 total titles**, the longest movie in the catalog is *Black Mirror: Bandersnatch* at **312 minutes** — nearly 3x the average runtime of a typical Netflix movie.
The **United States** is the primary content producer, accounting for roughly **32%** of the entire Netflix catalog, followed distantly by **India**.
**Movies make up approximately 70%** of the platform's offerings compared to TV Shows.

## 📁 Files

| File | Description |
|------|-------------|
| [`Schema.sql`](./Schema.sql) | Database and table creation |
| [`Data_Cleaning.sql`](./Data_Cleaning.sql) | Date standardization and type fixes |
| [`EDA.sql`](./EDA.sql) | Exploratory data analysis queries |
| [`Solutions.sql`](./Solutions.sql) | 20 business problem solutions |
| [`netflix_sql_project_questions.txt`](./netflix_sql_project_questions.txt) | Full list of business questions |
