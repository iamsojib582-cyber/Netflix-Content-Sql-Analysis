# Netflix SQL Portfolio Project

This project analyzes Netflix content using SQL to answer real-world business questions.
It demonstrates my ability to work with structured data, clean messy datasets, and perform analytical queries using PostgreSQL.

---

## Objective

- Analyze Netflix content by type, genre, country, rating, and director
- Perform time-based analysis on content additions
- Handle real-world data issues (multi-value columns, string dates)
- Demonstrate strong SQL querying skills

---

## Tools Used

- PostgreSQL
- SQL
- VS Code

---

## Dataset Overview

The dataset is divided into multiple relational tables.

### Tables

- **title** – show_id, title, director, show_type, added_date
- **genre** – show_id, genre, release_year
- **rating** – show_id, rating
- **country** – show_id, country_name

---

## Project Structure

Netflix-SQL-Project/
│
├── schema/
│ └── schema.sql
├── sql/
│ ├── q01_total_titles.sql
│ ├── q02_movies_vs_tv.sql
│ └── ...
├── README.md


---

## Analysis Performed

- Total titles on Netflix
- Movies vs TV Shows comparison
- Content by genre and rating
- Content added by year and quarter
- Top countries by content volume
- Directors with content across multiple genres and countries
- Multi-country and multi-genre title analysis

---

## SQL Concepts Used

- JOINs
- GROUP BY & HAVING
- CASE & COALESCE
- Window Functions
- Date functions
- LATERAL & UNNEST

---

## How to Run

1. Create tables using `schema/schema.sql`
2. Load the data into PostgreSQL
3. Run SQL queries from the `sql` folder

---

## Author

**Martin Sajeeb**  
Aspiring Data Analyst  

GitHub: *(add link)*

---

⭐ This project is created for learning and portfolio purposes.
