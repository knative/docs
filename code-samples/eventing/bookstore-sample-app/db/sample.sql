CREATE TABLE BookReviews(
  id SERIAL PRIMARY KEY,
  post_time datetime NOT NULL,
  content TEXT NOT NULL,
  sentiment TEXT,
  CONSTRAINT sentiment_check CHECK (sentiment IN ('positive', 'negative', 'neutral')),
);

INSERT INTO BookReviews VALUES(1, '2020-01-01 00:00:00', 'This book is great!', 'positive');
INSERT INTO BookReviews VALUES(2, '2020-01-02 00:02:00', 'This book is terrible!', 'negative');
INSERT INTO BookReviews VALUES(3, '2020-01-03 00:01:30', 'This book is okay.', 'neutral');
INSERT INTO BookReviews VALUES(4, '2020-01-04 00:00:00', 'Meh', 'neutral');
INSERT INTO BookReviews VALUES(5, '2020-01-04 00:04:00', 'I HATE THIS BOOK!', 'negative');
INSERT INTO BookReviews VALUES(6, '2020-01-06 00:00:00', 'Best thing I have ever read!', 'positive');
INSERT INTO BookReviews VALUES(7, '2020-01-07 00:12:00', 'ABSOLUTELY LOVELY!', 'positive');
INSERT INTO BookReviews VALUES(8, '2020-01-08 00:00:00', 'Most boring book I picked up', 'negative');