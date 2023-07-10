CREATE TABLE users (
  id serial PRIMARY KEY,
  username varchar(50) NOT NULL
);

CREATE TABLE slanders (
  id serial PRIMARY KEY,
  paragraph varchar(140),
  username_id integer REFERENCES users (id) ON DELETE CASCADE NOT NULL,
  date_created date DEFAULT CURRENT_TIMESTAMP
);
