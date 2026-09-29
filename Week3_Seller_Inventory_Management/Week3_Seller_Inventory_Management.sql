-- ============================================================
-- WEEK 3 - SELLER & INVENTORY MANAGEMENT SYSTEM
-- MySQL 8.x
-- ============================================================

DROP DATABASE IF EXISTS SellerInventoryDB;
CREATE DATABASE SellerInventoryDB;
USE SellerInventoryDB;

-- ------------------------------------------------------------
-- 1. SELLER TABLE
-- ------------------------------------------------------------
CREATE TABLE Seller (
    Seller_ID INT AUTO_INCREMENT PRIMARY KEY,
    Seller_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    CHECK (CHAR_LENGTH(Seller_Name) >= 2)
);

-- ------------------------------------------------------------
-- 2. PRODUCT TABLE
-- Product is included so Seller -> Product and
-- Product -> Inventory relationships can be demonstrated.
-- ------------------------------------------------------------
CREATE TABLE Product (
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name VARCHAR(150) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CHECK (Price > 0)
);

-- ------------------------------------------------------------
-- 3. SELLER_PRODUCT TABLE
-- Many-to-many relationship between Seller and Product.
-- A seller can supply many products and a product can have
-- multiple sellers.
-- ------------------------------------------------------------
CREATE TABLE Seller_Product (
    Seller_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    PRIMARY KEY (Seller_ID, Product_ID),
    FOREIGN KEY (Seller_ID) REFERENCES Seller(Seller_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. INVENTORY TABLE
-- Each inventory record belongs to one seller and one product.
-- ------------------------------------------------------------
CREATE TABLE Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_ID INT NOT NULL,
    Seller_ID INT NOT NULL,
    Stock_Quantity INT NOT NULL DEFAULT 0,
    Stock_Status VARCHAR(20) NOT NULL,
    Last_Updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Seller_ID) REFERENCES Seller(Seller_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (Product_ID, Seller_ID),
    CHECK (Stock_Quantity >= 0),
    CHECK (Stock_Status IN ('Available', 'Low Stock', 'Out of Stock'))
);

-- ------------------------------------------------------------
-- SAMPLE SELLER DATA
-- ------------------------------------------------------------
INSERT INTO Seller (Seller_Name, Email, Phone, Address) VALUES
('TechWorld Supplies', 'techworld@gmail.com', '9876500011', 'Chennai, Tamil Nadu'),
('Smart Choice Store', 'smartchoice@gmail.com', '9876500012', 'Coimbatore, Tamil Nadu'),
('Digital Hub', 'digitalhub@gmail.com', '9876500013', 'Madurai, Tamil Nadu'),
('Prime Electronics', 'primeelectronics@gmail.com', '9876500014', 'Trichy, Tamil Nadu'),
('NextGen Traders', 'nextgen@gmail.com', '9876500015', 'Salem, Tamil Nadu');

-- ------------------------------------------------------------
-- SAMPLE PRODUCT DATA
-- ------------------------------------------------------------
INSERT INTO Product (Product_Name, Category, Price) VALUES
('HP Pavilion 15', 'Laptop', 58999.00),
('Dell Inspiron 15', 'Laptop', 62999.00),
('Lenovo IdeaPad Slim 3', 'Laptop', 47999.00),
('Logitech Wireless Mouse', 'Accessories', 1299.00),
('HP USB Keyboard', 'Accessories', 899.00),
('Samsung 24 Inch Monitor', 'Monitor', 11999.00),
('Canon Wireless Printer', 'Printer', 15499.00),
('JBL Bluetooth Speaker', 'Audio', 3499.00),
('TP-Link WiFi Router', 'Networking', 2499.00),
('Seagate 1TB External HDD', 'Storage', 5299.00);

-- ------------------------------------------------------------
-- ASSIGN PRODUCTS TO SELLERS
-- ------------------------------------------------------------
INSERT INTO Seller_Product (Seller_ID, Product_ID) VALUES
(1,1),(1,4),(1,6),(1,9),
(2,2),(2,5),(2,8),(2,10),
(3,3),(3,4),(3,7),(3,9),
(4,1),(4,6),(4,7),(4,10),
(5,2),(5,3),(5,5),(5,8);

-- ------------------------------------------------------------
-- SAMPLE INVENTORY DATA
-- ------------------------------------------------------------
INSERT INTO Inventory
(Product_ID, Seller_ID, Stock_Quantity, Stock_Status)
VALUES
(1,1,25,'Available'),
(4,1,8,'Low Stock'),
(6,1,15,'Available'),
(9,1,0,'Out of Stock'),
(2,2,18,'Available'),
(5,2,7,'Low Stock'),
(8,2,0,'Out of Stock'),
(10,2,22,'Available'),
(3,3,30,'Available'),
(4,3,12,'Available'),
(7,3,5,'Low Stock'),
(9,3,9,'Low Stock'),
(1,4,14,'Available'),
(6,4,4,'Low Stock'),
(7,4,0,'Out of Stock'),
(10,4,16,'Available'),
(2,5,11,'Available'),
(3,5,6,'Low Stock'),
(5,5,20,'Available'),
(8,5,0,'Out of Stock');

-- ============================================================
-- SELLER & PRODUCT OPERATIONS
-- ============================================================

-- Add seller details
INSERT INTO Seller (Seller_Name, Email, Phone, Address)
VALUES ('FreshTech Mart', 'freshtech@gmail.com', '9876500016', 'Erode, Tamil Nadu');

-- Assign a product to the new seller
INSERT INTO Seller_Product (Seller_ID, Product_ID)
VALUES (6, 6);

-- Display products supplied by each seller
SELECT s.Seller_Name, p.Product_ID, p.Product_Name, p.Category, p.Price
FROM Seller s
JOIN Seller_Product sp ON s.Seller_ID = sp.Seller_ID
JOIN Product p ON sp.Product_ID = p.Product_ID
ORDER BY s.Seller_ID, p.Product_ID;

-- Count products supplied by each seller
SELECT s.Seller_ID, s.Seller_Name,
       COUNT(sp.Product_ID) AS Product_Count
FROM Seller s
LEFT JOIN Seller_Product sp ON s.Seller_ID = sp.Seller_ID
GROUP BY s.Seller_ID, s.Seller_Name
ORDER BY s.Seller_ID;

-- Update seller details
UPDATE Seller
SET Phone = '9876500099',
    Address = 'Erode, Tamil Nadu - Updated'
WHERE Seller_ID = 6;

-- ============================================================
-- INVENTORY OPERATIONS
-- ============================================================

-- Display available products
SELECT i.Inventory_ID, p.Product_Name, s.Seller_Name,
       i.Stock_Quantity, i.Stock_Status
FROM Inventory i
JOIN Product p ON i.Product_ID = p.Product_ID
JOIN Seller s ON i.Seller_ID = s.Seller_ID
WHERE i.Stock_Quantity > 0
ORDER BY i.Stock_Quantity DESC;

-- Find out-of-stock products
SELECT i.Inventory_ID, p.Product_Name, s.Seller_Name,
       i.Stock_Quantity, i.Stock_Status
FROM Inventory i
JOIN Product p ON i.Product_ID = p.Product_ID
JOIN Seller s ON i.Seller_ID = s.Seller_ID
WHERE i.Stock_Quantity = 0;

-- Find products with stock less than 10
SELECT i.Inventory_ID, p.Product_Name, s.Seller_Name,
       i.Stock_Quantity, i.Stock_Status
FROM Inventory i
JOIN Product p ON i.Product_ID = p.Product_ID
JOIN Seller s ON i.Seller_ID = s.Seller_ID
WHERE i.Stock_Quantity < 10;

-- Update stock quantity
UPDATE Inventory
SET Stock_Quantity = 18,
    Stock_Status = 'Available'
WHERE Inventory_ID = 2;

-- Delete discontinued inventory
-- Example: delete an out-of-stock inventory record for a discontinued item.
DELETE FROM Inventory
WHERE Inventory_ID = 9
  AND Stock_Quantity = 0;

-- ============================================================
-- INVENTORY REPORTS
-- ============================================================

-- Seller-wise product report
SELECT s.Seller_Name,
       COUNT(DISTINCT i.Product_ID) AS Products_In_Inventory,
       SUM(i.Stock_Quantity) AS Total_Stock
FROM Seller s
LEFT JOIN Inventory i ON s.Seller_ID = i.Seller_ID
GROUP BY s.Seller_ID, s.Seller_Name
ORDER BY s.Seller_ID;

-- Stock availability report
SELECT
    CASE
        WHEN Stock_Quantity = 0 THEN 'Out of Stock'
        WHEN Stock_Quantity < 10 THEN 'Low Stock'
        ELSE 'Available'
    END AS Availability_Status,
    COUNT(*) AS Inventory_Records,
    SUM(Stock_Quantity) AS Total_Units
FROM Inventory
GROUP BY Availability_Status;

-- Total available products / units
SELECT SUM(Stock_Quantity) AS Total_Available_Units
FROM Inventory
WHERE Stock_Quantity > 0;

-- Number of out-of-stock inventory records
SELECT COUNT(*) AS Out_of_Stock_Records
FROM Inventory
WHERE Stock_Quantity = 0;

-- Highest stocked product
SELECT p.Product_Name, s.Seller_Name, i.Stock_Quantity
FROM Inventory i
JOIN Product p ON i.Product_ID = p.Product_ID
JOIN Seller s ON i.Seller_ID = s.Seller_ID
WHERE i.Stock_Quantity = (SELECT MAX(Stock_Quantity) FROM Inventory);

-- Average inventory quantity
SELECT ROUND(AVG(Stock_Quantity), 2) AS Average_Inventory_Quantity
FROM Inventory;

-- ============================================================
-- CRUD EXAMPLES
-- ============================================================

-- CREATE
INSERT INTO Seller (Seller_Name, Email, Phone, Address)
VALUES ('Demo Seller', 'demo.seller@gmail.com', '9876500020', 'Tanjore, Tamil Nadu');

-- READ
SELECT * FROM Seller;

-- UPDATE
UPDATE Seller
SET Address = 'Tanjore, Tamil Nadu - Updated'
WHERE Email = 'demo.seller@gmail.com';

-- DELETE
DELETE FROM Seller
WHERE Email = 'demo.seller@gmail.com';

-- ============================================================
-- USEFUL VALIDATION QUERIES
-- ============================================================

-- Complete inventory view
SELECT i.Inventory_ID, p.Product_Name, p.Category,
       s.Seller_Name, i.Stock_Quantity, i.Stock_Status,
       i.Last_Updated
FROM Inventory i
JOIN Product p ON i.Product_ID = p.Product_ID
JOIN Seller s ON i.Seller_ID = s.Seller_ID
ORDER BY i.Inventory_ID;
