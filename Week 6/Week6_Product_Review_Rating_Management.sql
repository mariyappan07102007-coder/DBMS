-- Week 6: Product Review and Rating Management System
-- MySQL 8.0+ | Uses the Week 4 ecommerce database.
-- Run the Week 4 script first so Customer and Product tables exist.

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE Review (
    Review_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Review_Text VARCHAR(1000) NOT NULL,
    Review_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_review_product FOREIGN KEY (Product_ID)
        REFERENCES Product(Product_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Sample reviews linked to existing customers and products
INSERT INTO Review
(Review_ID, Customer_ID, Product_ID, Rating, Review_Text, Review_Date) VALUES
(1, 1, 101, 5, 'Excellent laptop performance and build quality.', '2026-10-02 09:00:00'),
(2, 2, 102, 4, 'Comfortable mouse and good value for money.', '2026-10-04 10:15:00'),
(3, 3, 101, 4, 'Works well for study and daily tasks.', '2026-10-13 11:30:00'),
(4, 4, 103, 3, 'Keyboard is usable, but the keys feel stiff.', '2026-10-16 12:00:00'),
(5, 1, 104, 5, 'Clear sound quality and comfortable fit.', '2026-10-17 14:20:00'),
(6, 2, 105, 2, 'The USB drive transfer speed is slower than expected.', '2026-10-18 16:45:00'),
(7, 3, 102, 5, 'Easy to use and responsive.', '2026-10-20 09:10:00'),
(8, 4, 101, 5, 'Very good product; satisfied with the purchase.', '2026-10-22 15:05:00');

-- 1. Insert a new review
INSERT INTO Review (Customer_ID, Product_ID, Rating, Review_Text)
VALUES (2, 104, 4, 'Good sound and comfortable to wear.');

-- 2. Display all reviews for a specific product (example Product_ID = 101)
SELECT r.Review_ID, p.Product_Name, c.Customer_Name, r.Rating,
       r.Review_Text, r.Review_Date
FROM Review r
JOIN Product p ON p.Product_ID = r.Product_ID
JOIN Customer c ON c.Customer_ID = r.Customer_ID
WHERE r.Product_ID = 101
ORDER BY r.Review_Date DESC;

-- 3. Display customer names with their reviews
SELECT c.Customer_Name, p.Product_Name, r.Rating, r.Review_Text, r.Review_Date
FROM Review r
JOIN Customer c ON c.Customer_ID = r.Customer_ID
JOIN Product p ON p.Product_ID = r.Product_ID
ORDER BY r.Review_Date DESC;

-- 4. Find products having the maximum number of reviews (includes ties)
SELECT p.Product_ID, p.Product_Name, COUNT(r.Review_ID) AS Review_Count
FROM Product p
LEFT JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING COUNT(r.Review_ID) = (
    SELECT MAX(review_count)
    FROM (
        SELECT COUNT(*) AS review_count
        FROM Review
        GROUP BY Product_ID
    ) AS counts_by_product
);

-- 5. Display recent customer feedback (latest first)
SELECT c.Customer_Name, p.Product_Name, r.Rating, r.Review_Text, r.Review_Date
FROM Review r
JOIN Customer c ON c.Customer_ID = r.Customer_ID
JOIN Product p ON p.Product_ID = r.Product_ID
ORDER BY r.Review_Date DESC
LIMIT 10;

-- 6. Retrieve reviews with ratings above 4
SELECT * FROM Review WHERE Rating > 4 ORDER BY Review_Date DESC;

-- 7. Update a review comment and rating
UPDATE Review
SET Review_Text = 'Updated: excellent product and reliable performance.',
    Rating = 5
WHERE Review_ID = 3;

-- 8. Delete an inappropriate or invalid review (example only)
-- Check the review first, then uncomment and run if deletion is appropriate:
-- DELETE FROM Review WHERE Review_ID = 6;

-- REPORT 1: Average rating for each product
SELECT p.Product_ID, p.Product_Name,
       COUNT(r.Review_ID) AS Number_Of_Reviews,
       ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
LEFT JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Average_Rating DESC;

-- REPORT 2: Number of reviews per product
SELECT p.Product_Name, COUNT(r.Review_ID) AS Number_Of_Reviews
FROM Product p
LEFT JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Number_Of_Reviews DESC;

-- REPORT 3: Highest-rated products (among products with reviews)
SELECT p.Product_Name, ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) = (
    SELECT MAX(avg_rating)
    FROM (
        SELECT AVG(Rating) AS avg_rating
        FROM Review
        GROUP BY Product_ID
    ) AS product_averages
);

-- REPORT 4: Products with average rating above 4
SELECT p.Product_Name, COUNT(r.Review_ID) AS Number_Of_Reviews,
       ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) > 4
ORDER BY Average_Rating DESC;

-- REPORT 5: Most reviewed products
SELECT p.Product_Name, COUNT(r.Review_ID) AS Number_Of_Reviews
FROM Product p
JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Number_Of_Reviews DESC;

-- REPORT 6: Products requiring improvement (average rating below 3.5)
SELECT p.Product_Name, COUNT(r.Review_ID) AS Number_Of_Reviews,
       ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) < 3.5
ORDER BY Average_Rating ASC;

-- REPORT 7: Count of 5-star, 4-star, and low-rated reviews (1-3 stars)
SELECT
    SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END) AS Five_Star_Reviews,
    SUM(CASE WHEN Rating = 4 THEN 1 ELSE 0 END) AS Four_Star_Reviews,
    SUM(CASE WHEN Rating <= 3 THEN 1 ELSE 0 END) AS Low_Rated_Reviews
FROM Review;

-- REPORT 8: Product rating analysis (name, count, average)
SELECT p.Product_Name, COUNT(r.Review_ID) AS Number_Of_Reviews,
       ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
LEFT JOIN Review r ON r.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Number_Of_Reviews DESC, Average_Rating DESC;

-- REPORT 9: Customer feedback analysis
SELECT c.Customer_ID, c.Customer_Name,
       COUNT(r.Review_ID) AS Reviews_Written,
       ROUND(AVG(r.Rating), 2) AS Average_Rating_Given,
       SUM(CASE WHEN r.Rating >= 4 THEN 1 ELSE 0 END) AS Positive_Reviews,
       SUM(CASE WHEN r.Rating <= 2 THEN 1 ELSE 0 END) AS Negative_Reviews
FROM Customer c
LEFT JOIN Review r ON r.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Reviews_Written DESC, Average_Rating_Given DESC;

-- Optional: all review records
SELECT * FROM Review ORDER BY Review_Date DESC;
