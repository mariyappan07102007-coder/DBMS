-- Week 4: Order Management System
-- MySQL 8.0+
-- Run this script in MySQL Workbench.
-- If you already have customer/product tables, review the CREATE TABLE statements first.

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Base tables used by the order-management relationships
CREATE TABLE IF NOT EXISTS Customer (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    City VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS Product (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_Name VARCHAR(120) NOT NULL UNIQUE,
    Category VARCHAR(80) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (Total_Amount >= 0),
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT fk_orders_customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    CONSTRAINT fk_details_order FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_details_product FOREIGN KEY (Product_ID)
        REFERENCES Product(Product_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_order_product UNIQUE (Order_ID, Product_ID)
);

-- Sample data
INSERT INTO Customer (Customer_ID, Customer_Name, Email, Phone, City) VALUES
(1, 'Arun Kumar', 'arun@example.com', '9876500001', 'Thoothukudi'),
(2, 'Priya Devi', 'priya@example.com', '9876500002', 'Madurai'),
(3, 'Karthik Raj', 'karthik@example.com', '9876500003', 'Tirunelveli'),
(4, 'Meena S', 'meena@example.com', '9876500004', 'Chennai');

INSERT INTO Product (Product_ID, Product_Name, Category, Price, Stock) VALUES
(101, 'Laptop', 'Electronics', 45000.00, 20),
(102, 'Wireless Mouse', 'Accessories', 650.00, 100),
(103, 'Keyboard', 'Accessories', 1200.00, 70),
(104, 'Headphones', 'Accessories', 1800.00, 50),
(105, 'USB Drive 64GB', 'Storage', 550.00, 80);

INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status) VALUES
(1001, 1, '2026-10-01', 46300.00, 'Delivered'),
(1002, 2, '2026-10-03', 3000.00, 'Shipped'),
(1003, 1, '2026-10-10', 2300.00, 'Pending'),
(1004, 3, '2026-10-12', 45000.00, 'Delivered'),
(1005, 4, '2026-10-15', 1750.00, 'Pending');

INSERT INTO Order_Details (Order_Detail_ID, Order_ID, Product_ID, Quantity, Price) VALUES
(1, 1001, 101, 1, 45000.00),
(2, 1001, 102, 2, 650.00),
(3, 1002, 103, 1, 1200.00),
(4, 1002, 104, 1, 1800.00),
(5, 1003, 105, 1, 550.00),
(6, 1003, 104, 1, 1750.00),
(7, 1004, 101, 1, 45000.00),
(8, 1005, 102, 1, 650.00),
(9, 1005, 103, 1, 1100.00);

-- 1. Create a new order for a customer
INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES (2, CURRENT_DATE(), 0.00, 'Pending');
SET @new_order_id = LAST_INSERT_ID();

-- 2. Add multiple products to the new order
INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
VALUES
(@new_order_id, 102, 2, 650.00),
(@new_order_id, 105, 1, 550.00);

-- 3. Calculate and save the order total
UPDATE Orders
SET Total_Amount = (
    SELECT COALESCE(SUM(Quantity * Price), 0)
    FROM Order_Details
    WHERE Order_ID = @new_order_id
)
WHERE Order_ID = @new_order_id;

-- 4. Update order status examples
UPDATE Orders SET Order_Status = 'Shipped' WHERE Order_ID = 1002;
UPDATE Orders SET Order_Status = 'Delivered' WHERE Order_ID = 1005;
-- To mark an order pending:
UPDATE Orders SET Order_Status = 'Pending' WHERE Order_ID = 1003;

-- 5. Update quantity of an ordered product
UPDATE Order_Details
SET Quantity = 3
WHERE Order_ID = 1001 AND Product_ID = 102;

-- Recalculate the order total after changing quantity
UPDATE Orders o
SET o.Total_Amount = (
    SELECT COALESCE(SUM(od.Quantity * od.Price), 0)
    FROM Order_Details od
    WHERE od.Order_ID = o.Order_ID
)
WHERE o.Order_ID = 1001;

-- 6. Display complete order details with customer and product
SELECT o.Order_ID, c.Customer_Name, c.Email, o.Order_Date, o.Order_Status,
       p.Product_Name, od.Quantity, od.Price,
       (od.Quantity * od.Price) AS Line_Total, o.Total_Amount
FROM Orders o
JOIN Customer c ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od ON od.Order_ID = o.Order_ID
JOIN Product p ON p.Product_ID = od.Product_ID
ORDER BY o.Order_ID, p.Product_Name;

-- 7. Delete a cancelled order (details are deleted automatically by ON DELETE CASCADE)
-- First mark it cancelled, then delete it if deletion is required.
UPDATE Orders SET Order_Status = 'Cancelled' WHERE Order_ID = 1003;
DELETE FROM Orders WHERE Order_ID = 1003 AND Order_Status = 'Cancelled';

-- REPORT 1: Customer order history
SELECT c.Customer_ID, c.Customer_Name, o.Order_ID, o.Order_Date,
       o.Order_Status, o.Total_Amount
FROM Customer c
JOIN Orders o ON o.Customer_ID = c.Customer_ID
ORDER BY c.Customer_ID, o.Order_Date;

-- REPORT 2: Product-wise order report
SELECT p.Product_ID, p.Product_Name, COUNT(DISTINCT od.Order_ID) AS Orders_Containing_Product,
       SUM(od.Quantity) AS Total_Quantity_Sold,
       SUM(od.Quantity * od.Price) AS Product_Sales
FROM Product p
LEFT JOIN Order_Details od ON od.Product_ID = p.Product_ID
LEFT JOIN Orders o ON o.Order_ID = od.Order_ID AND o.Order_Status <> 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Product_Sales DESC;

-- REPORT 3: Number of times each product was ordered
SELECT p.Product_Name, COUNT(od.Order_Detail_ID) AS Times_Ordered
FROM Product p
LEFT JOIN Order_Details od ON od.Product_ID = p.Product_ID
LEFT JOIN Orders o ON o.Order_ID = od.Order_ID AND o.Order_Status <> 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Times_Ordered DESC;

-- REPORT 4: Total quantity of products sold
SELECT COALESCE(SUM(od.Quantity), 0) AS Total_Quantity_Sold
FROM Order_Details od
JOIN Orders o ON o.Order_ID = od.Order_ID
WHERE o.Order_Status <> 'Cancelled';

-- REPORT 5: Customer(s) with maximum number of orders
SELECT c.Customer_ID, c.Customer_Name, COUNT(o.Order_ID) AS Number_Of_Orders
FROM Customer c
JOIN Orders o ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(o.Order_ID) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM Orders
        WHERE Order_Status <> 'Cancelled'
        GROUP BY Customer_ID
    ) AS counts_by_customer
);

-- REPORT 6: Total spending by each customer
SELECT c.Customer_ID, c.Customer_Name,
       COALESCE(SUM(CASE WHEN o.Order_Status <> 'Cancelled' THEN o.Total_Amount ELSE 0 END), 0)
       AS Total_Spending
FROM Customer c
LEFT JOIN Orders o ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

-- REPORT 7: Average order value (excluding cancelled orders)
SELECT ROUND(AVG(Total_Amount), 2) AS Average_Order_Value
FROM Orders
WHERE Order_Status <> 'Cancelled';

-- REPORT 8: Total sales amount (excluding cancelled orders)
SELECT ROUND(COALESCE(SUM(Total_Amount), 0), 2) AS Total_Sales
FROM Orders
WHERE Order_Status <> 'Cancelled';

-- Optional: view all orders and their totals
SELECT * FROM Orders ORDER BY Order_ID;
