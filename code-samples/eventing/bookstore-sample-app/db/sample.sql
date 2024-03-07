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