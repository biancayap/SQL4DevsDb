SELECT CustomerId, COUNT(CustomerId) as OrderCount
FROM dbo.[Order] 
WHERE OrderDate BETWEEN '2017-01-01' AND '2018-12-31'
AND ShippedDate IS NULL
GROUP BY CustomerId
HAVING COUNT(CustomerId) >= 2
