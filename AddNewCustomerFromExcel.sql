USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewCustomerFromExcel]    Script Date: 11/21/2019 11:34:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[AddNewCustomerFromExcel]
@filePath  NVARCHAR(MAX)

AS
BEGIN
    SET XACT_ABORT ON
	BEGIN TRANSACTION[MAIN]	

BEGIN TRY

DECLARE @tableName NVARCHAR(MAX)
DECLARE @sheetName NVARCHAR(MAX)
CREATE TABLE #tempTable(telephoneNo float,fName nvarchar(255),lName nvarchar(255),serviceType nvarchar(255), street nvarchar(255), 
						city nvarchar(255), stateCode nvarchar(255), zipCode float, country nvarchar(255), countryCode int,
						salesrepsentativeId float,comissionRate float ,serviceNo int); 

SET @tableName = 'Customer'
SET @sheetName = 'Sheet1'

-------------================= start transaction =========------------


------====== validate the file path =======-------
	IF (@filePath is null or @filePath='' or LEN(@filePath) = 0)
		BEGIN
			PRINT('Source File Not Found')
			RETURN
		END	
	
-------===== validate the file is empty or not ======---------
BEGIN TRY
--BEGIN TRANSACTION[T1]	

	DECLARE @count INT  = 0;
	DECLARE @paramDefination  NVARCHAR(MAX)
	DECLARE @countCheck  NVARCHAR(MAX)

	SET  @countCheck = 'SELECT  @count1 = count(*) FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 
	SET @paramDefination = '@count1 INT OUTPUT'
	EXEC sp_executesql @countCheck, @paramDefination, @count1=@count
	OUTPUT
	IF @count = 0
		BEGIN 
			PRINT('No records found.')
			RETURN
		END
	
	PRINT (CONVERT(VARCHAR, @count  )+ ' records found.')

--COMMIT TRANSACTION[T1]
END TRY

BEGIN CATCH
	PRINT 'Error while check the file.'
	PRINT ERROR_MESSAGE()

	--ROLLBACK TRANSACTION[T1]
END CATCH

----=================== IF THE FILE has records copy the records to temporary table ====================================
BEGIN TRY
--BEGIN TRANSACTION[T2]	

	DECLARE @tempTable  NVARCHAR(MAX)
	DECLARE @isTableExist  NVARCHAR(MAX)
	DECLARE @insertQuery NVARCHAR(MAX)

	Print 'temp in t2'
	SET @tempTable = '#tempTable'
	SET @insertQuery = 'INSERT '+@tempTable+
	              ' SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 
	EXEC (@insertQuery)

--================================== check if the table is there =====------------------------

	SELECT @isTableExist = ROW_NUMBER() OVER (ORDER BY TABLE_NAME) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tableName

	--COMMIT TRANSACTION[T2]
END TRY

BEGIN CATCH

	PRINT 'Error while inserting into temporary table.'
	PRINT ERROR_MESSAGE()

	--ROLLBACK TRANSACTION[T2]
END CATCH

----=================================== IF the table exists insert the records and drop the temporary table ======--------------
BEGIN TRY
--BEGIN TRANSACTION[T3]

	DECLARE @dropTable  NVARCHAR(MAX)
	DECLARE @insertTable  NVARCHAR(MAX)

	IF(@isTableExist = 1)
		BEGIN
			SELECT @insertTable = 'INSERT INTO ' +@tableName +' SELECT * FROM ' + @tempTable
			EXEC (@insertTable)
        	SELECT @dropTable = 'DROP TABLE ' + @tempTable
			EXEC (@dropTable)
			COMMIT TRANSACTION[MAIN]
			RETURN
		END

--COMMIT TRANSACTION[T3]
END TRY

BEGIN CATCH
	PRINT 'Error while inserting record or dropping temporary table.'
	PRINT ERROR_MESSAGE()

--ROLLBACK TRANSACTION[T3]
END CATCH


------================== IF not create it db ==========================================--------------------
	
	IF(@isTableExist = 0)
		BEGIN
			DECLARE @createTable  NVARCHAR(MAX)
	
			SELECT @createTable = 'SELECT * INTO ' +  @tableName + '  FROM  ' + @tempTable
			EXEC (@createTable)
		END

------==================  drop the temporary table =================--------------------

		DECLARE @dropTableFinal  NVARCHAR(MAX)
		
		SELECT @dropTableFinal = 'DROP TABLE ' + @tempTable
		EXEC (@dropTableFinal)

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION[MAIN]
	PRINT 'Sorry, inserting the file was not successful.'
	PRINT ERROR_MESSAGE()
END CATCH
END

