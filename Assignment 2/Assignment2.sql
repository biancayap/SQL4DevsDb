--Assignment 2.1
SELECT p.ProductName, SUM(Quantity) AS TotalQuantity
FROM OrderItem o
LEFT JOIN Product p ON o.ProductId = p.ProductId
JOIN [Order] ord ON ord.OrderId = o.OrderId
JOIN Store s ON s.StoreId = ord.StoreId
WHERE s.State = 'TX'
GROUP BY p.productname
HAVING SUM(quantity) > 10
ORDER BY TotalQuantity DESC

--Assignment 2.2
SELECT replace (CategoryName, 'Bikes', 'Bicycles') as CategoryName, SUM(Quantity) AS TotalQuantity
FROM OrderItem o
LEFT JOIN Product p ON o.ProductId = p.ProductId
JOIN [Order] ord ON ord.OrderId = o.OrderId
JOIN Category c ON c.CategoryId = p.CategoryId
WHERE ord.ShippedDate IS NOT NULL
GROUP BY c.categoryname
ORDER BY TotalQuantity DESC

--Assignment 2.3
SELECT p.ProductName, SUM(Quantity) AS TotalQuantity
FROM OrderItem o
LEFT JOIN Product p ON o.ProductId = p.ProductId
JOIN [Order] ord ON ord.OrderId = o.OrderId
JOIN Store s ON s.StoreId = ord.StoreId
WHERE s.State = 'TX' AND ord.ShippedDate IS NOT NULL
GROUP BY p.productname
HAVING SUM(quantity) > 10
UNION
SELECT replace (CategoryName, 'Bikes', 'Bicycles') as CategoryName, SUM(Quantity) AS TotalQuantity
FROM OrderItem o
LEFT JOIN Product p ON o.ProductId = p.ProductId
JOIN [Order] ord ON ord.OrderId = o.OrderId
JOIN Category c ON c.CategoryId = p.CategoryId
WHERE ord.ShippedDate IS NOT NULL
GROUP BY c.categoryname
ORDER BY TotalQuantity DESC

--Assignment 2.4
;WITH CTE_ORDERS AS (
    SELECT YEAR(OrderDate) AS OrderYear
        , MONTH(OrderDate) AS OrderMonth
        , P.ProductName
        , SUM(Quantity) AS TotalQuantity
    FROM [Order] O
    INNER JOIN OrderItem OI
        ON O.OrderId = OI.OrderId
    INNER JOIN Product P
        ON OI.ProductId = P.ProductId
    WHERE O.ShippedDate IS NOT NULL
    GROUP BY YEAR(OrderDate), MONTH(OrderDate), P.ProductName
)
, CTE_TOP_PRODUCTS AS (
    SELECT *
        , RANK() OVER (PARTITION BY OrderYear, OrderMonth ORDER BY TotalQuantity DESC) AS [Ranking]
    FROM CTE_ORDERS
)
 
SELECT OrderYear, OrderMonth, ProductName, TotalQuantity
FROM CTE_TOP_PRODUCTS
WHERE [Ranking] = 1
ORDER BY OrderYear, OrderMonth
