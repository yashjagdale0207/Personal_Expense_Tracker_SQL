-- Create Database
CREATE DATABASE IF NOT EXISTS PersonalExpenseTracker;

-- Use the Database
USE PersonalExpenseTracker;


-- Create Category Table
CREATE TABLE IF NOT EXISTS Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(255) UNIQUE NOT NULL
);

-- Create SubCategory Table
CREATE TABLE IF NOT EXISTS SubCategory (
    SubCategoryID INT PRIMARY KEY AUTO_INCREMENT,
    SubCategoryName VARCHAR(255) UNIQUE NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

-- Create Expense Table
CREATE TABLE IF NOT EXISTS Expense (
    ExpenseID INT PRIMARY KEY AUTO_INCREMENT,
    Amount DECIMAL(10, 2) NOT NULL,
    ExpenseDate DATE NOT NULL,
    SubCategoryID INT,
    TaxRate DECIMAL(4, 2) DEFAULT 0,
    FOREIGN KEY (SubCategoryID) REFERENCES SubCategory(SubCategoryID)
);

-- Create Earnings Table
-- Create Earnings Table
CREATE TABLE IF NOT EXISTS Earnings (
    EarningsID INT PRIMARY KEY AUTO_INCREMENT,
    EarningName VARCHAR(255) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    EarningsDate DATE NOT NULL
);


-- Create Tax Table
CREATE TABLE IF NOT EXISTS Tax (
    TaxID INT PRIMARY KEY AUTO_INCREMENT,
    TaxRate DECIMAL(4, 2) NOT NULL,
    CategoryID INT,
    SubCategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
    FOREIGN KEY (SubCategoryID) REFERENCES SubCategory(SubCategoryID)
);


-- Create a user with limited access
CREATE USER 'limited_user'@'localhost' IDENTIFIED BY 'password';

-- Grant SELECT permission on specific tables
GRANT SELECT ON PersonalExpenseTracker.Category TO 'limited_user'@'localhost';
GRANT SELECT ON PersonalExpenseTracker.SubCategory TO 'limited_user'@'localhost';
GRANT SELECT ON PersonalExpenseTracker.Expense TO 'limited_user'@'localhost';
-- Repeat for other tables as needed



-- Insert Sample Categories
INSERT INTO Category (CategoryName) VALUES
('Groceries'),
('Entertainment'),
('Utilities'),
('Travel'),
('Clothing'),
('Healthcare'),
('Education'),
('Dining Out'),
('Home Maintenance'),
('Technology');


-- Insert Sample SubCategories
INSERT INTO SubCategory (SubCategoryName, CategoryID) VALUES
('Food', 1),
('Movies', 2),
('Electricity', 3),
('Flights', 4),
('Apparel', 5),
('Medical Expenses', 6),
('Tuition Fees', 7),
('Restaurants', 8),
('Repairs', 9),
('Electronics', 10);


-- Insert Sample Expenses
INSERT INTO Expense (Amount, ExpenseDate, SubCategoryID, TaxRate) VALUES
(1000, '2022-01-01', 1, 2.0),
(500, '2022-01-05', 2, 8.0),
(200, '2022-01-10', 3, 0.0),
(1500, '2022-02-02', 4, 5.0),
(700, '2022-02-05', 5, 0.0),
(250, '2022-02-10', 6, 2.5),
(1200, '2022-03-01', 7, 1.0),
(600, '2022-03-05', 8, 8.0),
(300, '2022-03-10', 9, 0.0),
(800, '2022-03-15', 10, 5.0);


-- Insert Sample Earnings
INSERT INTO Earnings (EarningName, Amount, EarningsDate) VALUES
('Salary', 3000, '2022-01-02'),
('Bonus', 4000, '2022-01-15'),
('Freelance', 3500, '2022-02-02'),
('Investments', 4500, '2022-02-15'),
('Part-Time Job', 2000, '2022-03-02'),
('Commission', 3000, '2022-03-15'),
('Consulting', 2500, '2022-04-02'),
('Dividends', 5000, '2022-04-15'),
('Gifts', 1000, '2022-05-02'),
('Rent', 6000, '2022-05-15');


-- Insert Sample Taxes
INSERT INTO Tax (TaxRate, CategoryID, SubCategoryID) VALUES
(2.0, 1, 1),
(8.0, 2, 2),
(0.0, 3, 3),
(5.0, 4, 4),
(3.5, 1, 5),
(9.0, 2, 6),
(0.0, 3, 7),
(6.0, 4, 8),
(2.0, 5, NULL),
(8.0, 6, NULL);

-- Total Expenses and Earnings for the Month
DELIMITER //
CREATE PROCEDURE GetTotalExpensesAndEarnings(IN p_month INT, OUT total_expenses DECIMAL(10, 2), OUT total_earnings DECIMAL(10, 2))
BEGIN
    SELECT
        SUM(Amount) INTO total_expenses
    FROM
        Expense
    WHERE
        MONTH(ExpenseDate) = p_month;

    SELECT
        SUM(Amount) INTO total_earnings
    FROM
        Earnings
    WHERE
        MONTH(EarningsDate) = p_month;
END //
DELIMITER ;

-- Taxes Paid in a Category, Shown Sub-Category Wise
DELIMITER //
CREATE PROCEDURE GetTaxesPaidInCategory(IN p_category_name VARCHAR(255))
BEGIN
    SELECT
        sc.SubCategoryName,
        SUM(e.Amount * (e.TaxRate / 100)) AS TaxPaid
    FROM
        Expense e
    JOIN SubCategory sc ON e.SubCategoryID = sc.SubCategoryID
    JOIN Category c ON sc.CategoryID = c.CategoryID
    WHERE
        c.CategoryName = p_category_name
    GROUP BY
        sc.SubCategoryName;
END //
DELIMITER ;

-- Sub-Categories with No Expenses
DELIMITER //
CREATE PROCEDURE GetSubCategoriesWithNoExpenses()
BEGIN
    SELECT
        sc.SubCategoryName
    FROM
        SubCategory sc
    LEFT JOIN
        Expense e ON sc.SubCategoryID = e.SubCategoryID
    WHERE
        e.ExpenseID IS NULL;
END //
DELIMITER ;

-- Profitable Months
DELIMITER //
CREATE PROCEDURE GetProfitableMonths(OUT profitable_months VARCHAR(255))
BEGIN
    SELECT
        GROUP_CONCAT(DISTINCT MONTHNAME(e.EarningsDate)) INTO profitable_months
    FROM
        Earnings e
    LEFT JOIN
        Expense ex ON e.EarningsDate = ex.ExpenseDate
    WHERE
        SUM(e.Amount) > COALESCE(SUM(ex.Amount), 0);
END //
DELIMITER ;

-- TRIGGER to Ensure Total Spending per Month does not Exceed 50000 Rs
DELIMITER //
CREATE TRIGGER CheckTotalSpending
BEFORE INSERT ON Expense
FOR EACH ROW
BEGIN
    DECLARE total_spending DECIMAL(10, 2);
    
    SELECT
        COALESCE(SUM(Amount), 0)
    INTO
        total_spending
    FROM
        Expense
    WHERE
        MONTH(NEW.ExpenseDate) = MONTH(ExpenseDate)
    GROUP BY
        MONTH(ExpenseDate);

    IF (total_spending + NEW.Amount > 50000) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total spending for the month exceeds 50000 Rs';
    END IF;
END //
DELIMITER ;

-- Reset DELIMITER to default
DELIMITER ;



-- Call the stored procedure
CALL GetTotalExpensesAndEarnings(1, @total_expenses, @total_earnings);

-- Retrieve the output values
SELECT @total_expenses AS TotalExpenses, @total_earnings AS TotalEarnings;
