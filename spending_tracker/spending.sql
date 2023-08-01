CREATE TABLE payments (
  id serial PRIMARY KEY,
  amount decimal(6, 2) NOT NULL,
  category varchar(30) NOT NULL,
  date_of_payment date DEFAULT CURRENT_TIMESTAMP,
  );