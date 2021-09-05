USE oci_database;

CREATE TABLE IF NOT EXISTS users (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT NOW(),
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
);
