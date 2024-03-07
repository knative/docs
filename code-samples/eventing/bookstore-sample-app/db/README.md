# Bookstore Database

1. Database Schema
2. Sample Data

## 1. Database Schema

### BookReviews Table
The BookReviews table contains all reviews made on the bookstore website. 

See the columns of the BookReviews table below:
* ID (serial) - Primary Key
* post_time (datetime) - Posting time of the comment
* content (text) - The contents of the comment
* sentiment (text) - The sentiment results (currently, the values it could take on are 'positive' or 'neutral' or 'negative')

## 2. Sample Data

### BookReviews Table
The sample rows inserted for the BookReviews table are shown below:
| id | post_time           | content                      | sentiment |
|----|---------------------|------------------------------|-----------|
| 1  | 2020-01-01 00:00:00 | This book is great!          | positive  |
| 2  | 2020-01-02 00:02:00 | This book is terrible!       | negative  |
| 3  | 2020-01-03 00:01:30 | This book is okay.           | neutral   |
| 4  | 2020-01-04 00:00:00 | Meh                          | neutral   |