# 🎧 Spotify Advanced SQL Project and Query Optimization

---

## 📂 Project Category: **Advanced**

---

## 📝 Overview

This project involves analyzing a **Spotify dataset** with attributes for tracks, albums, and artists using **SQL**. It covers the end-to-end journey: normalizing a denormalized dataset, executing SQL queries of various complexities, and optimizing query performance. The major goals are:

- Practicing **advanced SQL skills**  
- Generating **valuable insights** from the dataset

---

## 🚦 Project Steps

### 1️⃣ Data Exploration

Before diving into SQL, it's crucial to understand the dataset. It contains:

- 🎤 **Artist**: The performer of the track  
- 🎵 **Track**: The song name  
- 💽 **Album**: Album to which the track belongs  
- 🎼 **Album_type**: Kind of album (e.g., single or album)  
- 📊 Various metrics: **danceability**, **energy**, **loudness**, **tempo**, etc.

---

### 2️⃣ Querying the Data

Data prepared? Write queries in three levels: **easy**, **medium**, and **advanced** to build up SQL confidence:

- 🟢 **Easy Queries**: Simple retrieval, filtering, and basic aggregation  
- 🟠 **Medium Queries**: Grouping, aggregate functions, **joins**  
- 🔴 **Advanced Queries**: Nested subqueries, window functions, CTEs, optimization

---

### 3️⃣ Query Optimization

Optimize queries using:

- 🏷️ **Indexing**: Add indexes to frequently queried columns  
- 🔎 **Query Execution Plan**: Use `EXPLAIN ANALYZE` to review performance

---

## 🧩 15 Practice Questions

### 🟢 Easy Level

1. Retrieve names of all tracks with over 1 billion streams  
2. List all albums with their respective artists  
3. Get total comments for tracks where `licensed = TRUE`  
4. Find tracks that belong to the album type 'single'  
5. Count total number of tracks by each artist  

---

### 🟠 Medium Level

1. Calculate average danceability of tracks in each album  
2. Find top 5 tracks with highest energy values  
3. List all tracks with their views and likes where `official_video = TRUE`  
4. For each album, total the views of all associated tracks  
5. Retrieve track names streamed more on Spotify than YouTube  

---

### 🔴 Advanced Level

1. Top 3 most-viewed tracks for each artist using window functions  
2. Query tracks where liveness score exceeds average  
3. Use a WITH clause for difference between highest and lowest energy per album  
4. Find tracks where energy-to-liveness ratio exceeds 1.2  
5. Calculate cumulative sum of likes for tracks ordered by views (window functions)  

---

## 🚀 Query Optimization Technique

Optimization steps:

- **Initial Performance (EXPLAIN)**:  
    - Execution Time: **7 ms**  
    - Planning Time: **0.17 ms**  

- **Index Creation**: Added index on the artist column

- **After Indexing**:  
    - Execution Time: **0.153 ms**  
    - Planning Time: **0.152 ms**  

Shows that **indexing** drastically improves query execution time!

---

## 💻 Technology Stack

- **Database**: PostgreSQL  
- **SQL Concepts**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions  
- **Tools**: pgAdmin 4 (or any SQL editor)

---

## ⚙️ How to Run the Project

1. Install PostgreSQL and pgAdmin
2. Set up the database schema and tables
3. Insert sample data into tables
4. Execute SQL queries for the listed problem statements
5. Experiment with **optimization techniques** for large datasets

---

## 🙏 Acknowledgments

- Dataset sourced from [Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)
- Highlighted by: [Zero Analyst YouTube Channel](https://www.youtube.com/@zero_analyst)
- All SQL queries written independently

---

## 👤 Author

- Parveen Jalwal  
- [LinkedIn Profile](https://www.linkedin.com/in/parveen-jalwal-201a2a302)

---
