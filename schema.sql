-- Netflix Project Database Schema
-- PostgreSQL

CREATE TABLE title (
    show_id VARCHAR(10) PRIMARY KEY,
    title TEXT,
    director TEXT,
    show_type VARCHAR(20),
    added_date DATE
);

CREATE TABLE genre (
    show_id VARCHAR(10),
    genre TEXT,
    release_year INT,
    FOREIGN KEY (show_id) REFERENCES title(show_id)
);

CREATE TABLE rating (
    show_id VARCHAR(10),
    rating VARCHAR(10),
    FOREIGN KEY (show_id) REFERENCES title(show_id)
);

CREATE TABLE country (
    show_id VARCHAR(10),
    country_name TEXT,
    FOREIGN KEY (show_id) REFERENCES title(show_id)
);
