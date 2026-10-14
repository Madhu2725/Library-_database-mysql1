

INSERT INTO books (title, author, isbn, genre, total_copies, available_copies) VALUES
('The Pragmatic Programmer', 'Andrew Hunt',    '9780135957059', 'Technology', 3, 3),
('Clean Code',               'Robert Martin', '9780132350884', 'Technology', 2, 2),
('Dune',                     'Frank Herbert', '9780441013593', 'Sci-Fi',     4, 4);

INSERT INTO users (name, email, phone) VALUES
('<name_1>', '<email_1>', '<phone_1>'),
('<name_2>', '<email_2>', '<phone_2>');




START TRANSACTION;

INSERT INTO transactions (user_id, book_id, due_date)
SELECT :user_id, :book_id, :due_date
FROM books
WHERE book_id = :book_id AND available_copies > 0 AND status = 'active'  -- guard: copy available
  AND (SELECT status FROM users WHERE user_id = :user_id) = 'active';    -- guard: user active

UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = :book_id AND available_copies > 0;

COMMIT;



START TRANSACTION;

UPDATE transactions
SET returned_at  = NOW(),
    status       = 'returned',
    fine_amount  = GREATEST(0, DATEDIFF(NOW(), due_date)) * 5.00
WHERE transaction_id = :transaction_id AND status != 'returned';

UPDATE books
SET available_copies = available_copies + 1
WHERE book_id = (SELECT book_id FROM transactions WHERE transaction_id = :transaction_id);

COMMIT;



UPDATE transactions
SET status = 'overdue'
WHERE status = 'issued' AND due_date < CURDATE();



SELECT
    t.transaction_id,
    b.title,
    b.isbn,
    u.name        AS user_name,
    u.email,
    t.issued_at,
    t.due_date,
    t.status,
    DATEDIFF(CURDATE(), t.due_date) AS days_overdue
FROM transactions t
JOIN books b ON t.book_id = b.book_id
JOIN users u ON t.user_id = u.user_id
WHERE t.status IN ('issued', 'overdue')
ORDER BY t.due_date;



SELECT
    t.transaction_id,
    b.title,
    t.issued_at,
    t.due_date,
    t.returned_at,
    t.status,
    t.fine_amount
FROM transactions t
JOIN books b ON t.book_id = b.book_id
WHERE t.user_id = :user_id
ORDER BY t.issued_at DESC;




SELECT book_id, title, author, genre, available_copies
FROM books
WHERE available_copies > 0
ORDER BY title;



SELECT
    u.user_id,
    u.name,
    u.email,
    SUM(t.fine_amount) AS total_fine
FROM transactions t
JOIN users u ON t.user_id = u.user_id
WHERE t.fine_amount > 0 AND t.status != 'returned'
GROUP BY u.user_id, u.name, u.email
ORDER BY total_fine DESC;




SELECT
    b.book_id,
    b.title,
    b.author,
    COUNT(t.transaction_id) AS borrow_count
FROM transactions t
JOIN books b ON t.book_id = b.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY borrow_count DESC
LIMIT 10;
