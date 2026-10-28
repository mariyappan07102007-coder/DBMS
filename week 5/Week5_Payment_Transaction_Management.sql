-- Week 5: Payment Transaction Management System
-- MySQL 8.0+ | Designed to connect to the Week 4 ecommerce database.
-- Run Week 4 script first, or ensure Customer, Product, and Orders already exist.

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Each order can have at most one payment record:
-- Order_ID is both a foreign key and UNIQUE.
CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,
    Payment_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Payment_Mode VARCHAR(30) NOT NULL
        CHECK (Payment_Mode IN ('UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cash on Delivery')),
    Payment_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Payment_Status IN ('Pending', 'Success', 'Failed')),
    Transaction_Amount DECIMAL(10,2) NOT NULL
        CHECK (Transaction_Amount >= 0),
    CONSTRAINT fk_payment_order FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Sample payment records linked to existing Week 4 orders
INSERT INTO Payment (Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount) VALUES
(1, 1001, '2026-10-01 10:15:00', 'UPI', 'Success', 46300.00),
(2, 1002, '2026-10-03 12:30:00', 'Credit Card', 'Success', 3000.00),
(3, 1003, '2026-10-10 09:20:00', 'Debit Card', 'Failed', 2300.00),
(4, 1004, '2026-10-12 16:45:00', 'Net Banking', 'Success', 45000.00),
(5, 1005, '2026-10-15 11:00:00', 'Cash on Delivery', 'Pending', 1750.00);

-- 1. Insert a payment for an existing order
-- Do not run for an Order_ID that already has a payment because Order_ID is UNIQUE.
INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES (1002, 'UPI', 'Pending', 3000.00);

-- 2. Display all successful payments
SELECT * FROM Payment WHERE Payment_Status = 'Success';

-- 3. Find failed and pending transactions
SELECT * FROM Payment
WHERE Payment_Status IN ('Failed', 'Pending')
ORDER BY Payment_Date;

-- 4. Update status after a transaction retry
UPDATE Payment
SET Payment_Status = 'Success', Payment_Date = CURRENT_TIMESTAMP
WHERE Order_ID = 1003 AND Payment_Status = 'Failed';

-- 5. Count successful and failed payments
SELECT Payment_Status, COUNT(*) AS Transaction_Count
FROM Payment
WHERE Payment_Status IN ('Success', 'Failed')
GROUP BY Payment_Status;

-- 6. Retrieve payment details for one specific order
SELECT * FROM Payment WHERE Order_ID = 1001;

-- 7. Display complete payment, customer, and order information
SELECT p.Payment_ID, o.Order_ID, c.Customer_ID, c.Customer_Name,
       o.Order_Date, o.Order_Status, p.Payment_Date, p.Payment_Mode,
       p.Payment_Status, p.Transaction_Amount
FROM Payment p
JOIN Orders o ON o.Order_ID = p.Order_ID
JOIN Customer c ON c.Customer_ID = o.Customer_ID
ORDER BY p.Payment_ID;

-- 8. Update a payment mode/status as required
UPDATE Payment
SET Payment_Mode = 'Net Banking', Payment_Status = 'Pending'
WHERE Order_ID = 1005;

-- 9. Delete a payment record if a payment record must be removed
-- Consider keeping failed transactions for audit purposes.
-- DELETE FROM Payment WHERE Payment_ID = 5;

-- REPORT 1: Number of transactions by payment mode
SELECT Payment_Mode, COUNT(*) AS Number_Of_Transactions
FROM Payment
GROUP BY Payment_Mode
ORDER BY Number_Of_Transactions DESC, Payment_Mode;

-- REPORT 2: Most preferred payment method (returns ties if present)
SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
HAVING COUNT(*) = (
    SELECT MAX(mode_count)
    FROM (
        SELECT COUNT(*) AS mode_count
        FROM Payment
        GROUP BY Payment_Mode
    ) AS mode_counts
);

-- REPORT 3: Total successful payment revenue
SELECT COALESCE(SUM(Transaction_Amount), 0.00) AS Successful_Payment_Revenue
FROM Payment
WHERE Payment_Status = 'Success';

-- REPORT 4: Revenue by payment method (successful payments only)
SELECT Payment_Mode, SUM(Transaction_Amount) AS Successful_Revenue
FROM Payment
WHERE Payment_Status = 'Success'
GROUP BY Payment_Mode
ORDER BY Successful_Revenue DESC;

-- REPORT 5: Average transaction amount
SELECT ROUND(AVG(Transaction_Amount), 2) AS Average_Transaction_Amount
FROM Payment;

-- REPORT 6: Customer payment history
SELECT c.Customer_ID, c.Customer_Name, o.Order_ID, p.Payment_ID,
       p.Payment_Date, p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Customer c
JOIN Orders o ON o.Customer_ID = c.Customer_ID
JOIN Payment p ON p.Order_ID = o.Order_ID
ORDER BY c.Customer_ID, p.Payment_Date;

-- REPORT 7: Total successful, failed, and pending transactions
SELECT Payment_Status, COUNT(*) AS Transaction_Count,
       SUM(Transaction_Amount) AS Transaction_Amount_Total
FROM Payment
GROUP BY Payment_Status
ORDER BY Payment_Status;

-- REPORT 8: Orders with failed or pending payments
SELECT o.Order_ID, c.Customer_Name, o.Order_Date, o.Order_Status,
       p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Orders o
JOIN Customer c ON c.Customer_ID = o.Customer_ID
JOIN Payment p ON p.Order_ID = o.Order_ID
WHERE p.Payment_Status IN ('Failed', 'Pending')
ORDER BY p.Payment_Status, o.Order_ID;

-- Optional summary of all payment records
SELECT * FROM Payment ORDER BY Payment_ID;
