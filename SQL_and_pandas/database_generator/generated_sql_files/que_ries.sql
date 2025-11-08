CREATE TABLE Users (
  UserID INTEGER PRIMARY KEY,
  Name TEXT,
  Email TEXT
);



INSERT INTO Users (Name, Email) VALUES
  ('Alice', 'alice@email.com'),
  ('Bob', 'bob@email.com');

SELECT * FROM Users;

SELECT * FROM Users
WHERE Name = 'Alice';

UPDATE Users
SET Email = 'kkema@gmail.com'
WHERE Name = 'Alice';

DROP TABLE `jesse table`