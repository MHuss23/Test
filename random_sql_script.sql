
-- ================================================
-- Script: Random SQL Server Example Script
-- Description: Creates a sample database, tables, inserts data,
--              and defines a view and stored procedure.
-- ================================================

-- Create the database
IF DB_ID(N'RandomDB') IS NULL
BEGIN
    PRINT 'Creating database RandomDB';
    CREATE DATABASE RandomDB;
END
GO

-- Switch context to RandomDB
USE RandomDB;
GO

-- Drop tables if they exist
IF OBJECT_ID(N'dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

-- Create Customers table
CREATE TABLE dbo.Customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Email        NVARCHAR(100) UNIQUE,
    CreatedDate  DATETIME DEFAULT GETDATE()
);
GO

-- Create Orders table
CREATE TABLE dbo.Orders (
    OrderID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID   INT NOT NULL,
    OrderDate    DATETIME DEFAULT GETDATE(),
    TotalAmount  DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers (CustomerID)
        ON DELETE CASCADE
);
GO

-- Insert sample data into Customers
INSERT INTO dbo.Customers (FirstName, LastName, Email)
VALUES
    (N'John', N'Doe', N'john.doe@example.com'),
    (N'Jane', N'Smith', N'jane.smith@example.com'),
    (N'Emily', N'Johnson', N'emily.johnson@example.com');
GO

-- Insert sample data into Orders
INSERT INTO dbo.Orders (CustomerID, TotalAmount)
VALUES
    (1,  150.00),
    (1,   75.50),
    (2,  200.00),
    (3,  320.75),
    (2,   50.25);
GO

-- Create a view to display customers with their order totals
IF OBJECT_ID(N'dbo.vwCustomerOrderTotals', 'V') IS NOT NULL
    DROP VIEW dbo.vwCustomerOrderTotals;
GO

CREATE VIEW dbo.vwCustomerOrderTotals
AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName;
GO

-- Create a stored procedure to retrieve orders for a given customer
IF OBJECT_ID(N'dbo.usp_GetOrdersByCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetOrdersByCustomer;
GO

CREATE PROCEDURE dbo.usp_GetOrdersByCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderID,
        o.OrderDate,
        o.TotalAmount
    FROM dbo.Orders AS o
    WHERE o.CustomerID = @CustomerID
    ORDER BY o.OrderDate DESC;
END;
GO
