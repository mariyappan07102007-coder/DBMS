-- TASK 2: PRODUCT & CATEGORY MANAGEMENT
-- Database: ProductManagementDB

CREATE DATABASE IF NOT EXISTS ProductManagementDB;
USE ProductManagementDB;

-- 1. CREATE CATEGORY TABLE
CREATE TABLE IF NOT EXISTS Category (
    Category_ID INT PRIMARY KEY AUTO_INCREMENT,
    Category_Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 2. CREATE PRODUCT TABLE
CREATE TABLE IF NOT EXISTS Product (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_Name VARCHAR(100) NOT NULL UNIQUE,
    Category_ID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Stock_Quantity INT NOT NULL CHECK (Stock_Quantity >= 0),
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID)
);

-- 3. INSERT CATEGORY DATA
INSERT INTO Category (Category_Name, Description) VALUES
('Laptops', 'Laptop computers for students and professionals'),
('Mobiles', 'Smartphones and mobile devices'),
('Accessories', 'Computer and mobile accessories');

-- 4. INSERT 11 PRODUCT RECORDS
INSERT INTO Product (Product_Name, Category_ID, Price, Stock_Quantity) VALUES
('HP Laptop', 1, 55000.00, 10),
('Dell Inspiron', 1, 62000.00, 8),
('Lenovo IdeaPad', 1, 48000.00, 12),
('Acer Aspire', 1, 45000.00, 15),
('ASUS VivoBook', 1, 58000.00, 7),
('MSI Gaming Laptop', 1, 85000.00, 5),
('iPhone 15', 2, 70000.00, 5),
('Samsung Galaxy S24', 2, 65000.00, 6),
('OnePlus 12', 2, 55000.00, 10),
('Wireless Mouse', 3, 800.00, 25),
('Keyboard', 3, 1200.00, 20);

-- 5. SELECT
SELECT * FROM Category;
SELECT * FROM Product;

-- 6. INSERT (CRUD)
INSERT INTO Product (Product_Name, Category_ID, Price, Stock_Quantity)
VALUES ('Sony Headphones', 3, 2500.00, 15);

-- 7. UPDATE (CRUD)
UPDATE Product
SET Price = 60000.00
WHERE Product_Name = 'HP Laptop';

-- 8. DELETE (CRUD)
DELETE FROM Product
WHERE Product_Name = 'Sony Headphones';

-- 9. PRODUCTS CATEGORY-WISE
SELECT c.Category_Name, p.Product_Name, p.Price, p.Stock_Quantity
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
ORDER BY c.Category_Name, p.Product_Name;

-- 10. COUNT PRODUCTS IN EACH CATEGORY
SELECT c.Category_Name, COUNT(p.Product_ID) AS Product_Count
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY c.Category_ID;

-- 11. HIGHEST-PRICED PRODUCT
SELECT Product_Name, Price
FROM Product
WHERE Price = (SELECT MAX(Price) FROM Product);

-- 12. CATEGORIES HAVING MORE THAN 5 PRODUCTS
SELECT c.Category_Name, COUNT(p.Product_ID) AS Product_Count
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name
HAVING COUNT(p.Product_ID) > 5;

-- 13. AVERAGE PRODUCT PRICE
SELECT AVG(Price) AS Average_Product_Price
FROM Product;

-- 14. CATEGORY-WISE AVERAGE PRICE
SELECT c.Category_Name, AVG(p.Price) AS Average_Price
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name;
