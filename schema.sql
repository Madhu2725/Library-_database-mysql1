

CREATE TABLE books (
    book_id     INT PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(255) NOT NULL,
    author      VARCHAR(255) NOT NULL,
    isbn        VARCHAR(20) UNIQUE NOT NULL,
    genre       VARCHAR(100),
    total_copies    INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_copies CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

CREATE TABLE users (
    user_id     INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    phone       VARCHAR(20),
    status      ENUM('active', 'suspended') DEFAULT 'active',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id  INT PRIMARY KEY AUTO_INCREMENT,
    book_id         INT NOT NULL,
    user_id         INT NOT NULL,
    issued_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date        DATE NOT NULL,
    returned_at     TIMESTAMP NULL DEFAULT NULL,
    status          ENUM('issued', 'returned', 'overdue') DEFAULT 'issued',
    fine_amount     DECIMAL(6,2) DEFAULT 0.00,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
