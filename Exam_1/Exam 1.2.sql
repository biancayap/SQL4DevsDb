--BackupDatabase

DECLARE @table NVARCHAR(MAX) = 'Product';
DECLARE @new_table NVARCHAR(MAX) = @table + '_' + 
                                   CONVERT(NVARCHAR(100), GETDATE(),112);
DECLARE @sql NVARCHAR(MAX) = 'SELECT * INTO ' + @new_table + ' FROM '+ @table + ' WHERE ModelYear != 2016';
SELECT @sql;

EXEC (@sql);

-------------------------------
UPDATE Product_20220507
SET ListPrice = (ListPrice + (ListPrice * 0.2))
WHERE BrandId IN(3, 7)

UPDATE Product_20220507
SET ListPrice = (ListPrice + (ListPrice * 0.1))
WHERE BrandId NOT IN(3, 7)
