--#1
CREATE PROCEDURE dbo.CreateNewBrandAndMoveProducts
@newBrandName VARCHAR(50),
@oldBrandId INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION CreateNewBrand
			IF NOT EXISTS (SELECT brandName FROM Brand WHERE BrandName = @newBrandName)
			BEGIN
				INSERT INTO dbo.Brand (	BrandName )
					VALUES (@newBrandName)	
			END				

			UPDATE dbo.Product
			SET BrandId = (SELECT BrandId FROM dbo.Brand WHERE BrandName = @newBrandName)
			WHERE BrandId = @oldBrandId

			DELETE FROM dbo.Brand
			WHERE BrandId = @oldBrandId
		COMMIT TRANSACTION CreateNewBrand
	END TRY
	BEGIN CATCH
		 ROLLBACK TRAN CreateNewBrand
		 SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_STATE() AS ErrorState,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END
GO
--------------------------------
--#2
CREATE PROCEDURE dbo.FilterProducts
@productName VARCHAR(MAX),
@brandId INT,
@categoryId INT,
@modelYear SMALLINT
AS
BEGIN
	SELECT  p.ProductId, p.ProductName, p.BrandId, b.BrandName, p.CategoryId, c.CategoryName, p.ModelYear, p.ListPrice
	FROM Product p
	INNER JOIN Brand b ON b.BrandId = p.BrandId
	INNER JOIN Category c ON c.CategoryId = p.CategoryId
	WHERE ProductName LIKE '%'+ @productName +'%'
	OR p.BrandId = @brandId
	OR p.CategoryId = @categoryId
	OR p.ModelYear = @modelYear
	ORDER BY ModelYear DESC, ListPrice DESC, ProductName ASC
	OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY
END
------------------------------
--#3
SELECT * 
INTO ProductsBackUp
FROM Product

UPDATE ProductsBackUp
SET ListPrice = CASE
				WHEN(c.CategoryName = 'Children Bicycles'
						OR c.CategoryName = 'Cyclocross Bicycles'
						OR c.CategoryName = 'Road Bikes') THEN (ListPrice * 1.2)
				WHEN(c.CategoryName = 'Comfort Bicycles'
						OR c.CategoryName = 'Cruisers Bicycles'
						OR c.CategoryName = 'Electric Bikes') THEN (ListPrice * 1.7)
				WHEN (c.CategoryName = 'Mountain Bikes') THEN (ListPrice * 1.4)
				END
FROM ProductsBackUp p1 
INNER JOIN Category c ON c.CategoryId = p1.CategoryId
------------------------------
--#4
--A.
CREATE TABLE Ranking (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Description varchar(255) NOT NULL
);

--B.
INSERT INTO Ranking (Description)
VALUES ('Inactive'), ('Bronze'), ('Silver'), ('Gold'), ('Platinum')

--C.
ALTER TABLE Customer
    ADD RankingId INT,
    FOREIGN KEY(RankingId) REFERENCES Ranking(Id);

--D.
CREATE PROCEDURE dbo.uspRankCustomers
AS
BEGIN
	SELECT c.CustomerId, ISNULL((SUM((oi.Quantity * oi.ListPrice)/(1 + oi.Discount))), 0) as TotalAmount
	INTO #table1
	FROM [Order] o 
	INNER JOIN OrderItem oi ON o.OrderId = oi.OrderId 
	FULL OUTER JOIN Customer c ON c.CustomerId = o.CustomerId
	GROUP BY c.CustomerId

	UPDATE Customer
	SET RankingId = CASE
					WHEN (tb.TotalPrice = 0) THEN 1
					WHEN (tb.TotalPrice < 1000) THEN 2
					WHEN (tb.TotalPrice < 2000) THEN 3
					WHEN (tb.TotalPrice < 3000) THEN 4
					WHEN (tb.TotalPrice >= 3000) THEN 5
					END
	FROM Customer c
	INNER JOIN #table1 tb ON tb.CustomerId = c.CustomerId
END

--E.
CREATE VIEW vwCustomerOrders AS
SELECT c.CustomerId, c.FirstName, c.LastName, ISNULL((SUM((oi.Quantity * oi.ListPrice)/(1 + oi.Discount))), 0) as TotalAmount, r.[Description]
FROM [Order] o 
INNER JOIN OrderItem oi ON o.OrderId = oi.OrderId 
FULL OUTER JOIN Customer c ON c.CustomerId = o.CustomerId
INNER JOIN Ranking r ON r.Id = c.RankingId
GROUP BY c.CustomerId, c.FirstName, c.LastName, r.[Description]
----------------------------------------------
--#5
;WITH CTE(FullName , StaffId, Level, EmployeeHierarchy) AS 
(
     SELECT s.FirstName + ' ' + s.LastName AS FullName, s.StaffId, 0 Level
		,Cast(s.FirstName + ' ' + s.LastName as Varchar(MAX)) EmployeeHierarchy         
     FROM Staff s 
	 Where s.ManagerId IS NULL
     UNION ALL
     SELECT E.FirstName + ' ' + E.LastName AS FullName, E.StaffId, 
		c.Level + 1 , c.EmployeeHierarchy+', '+ (E.FirstName + ' ' + E.LastName)
     FROM Staff E INNER JOIN CTE c on c.StaffId = e.ManagerID 
)

SELECT StaffId, FullName, EmployeeHierarchy 
FROM CTE 
ORDER BY StaffId
