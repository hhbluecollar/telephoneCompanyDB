USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewService]    Script Date: 11/21/2019 11:35:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[AddNewService]
@filePath  NVARCHAR(MAX)

AS
BEGIN
DECLARE @query NVARCHAR(MAX)
DECLARE @tableName NVARCHAR(MAX)
DECLARE @sheetName NVARCHAR(MAX)

SET @tableName = 'Service'
SET @sheetName = 'Sheet1'


IF (@filePath is null or @filePath='' or LEN(@filePath) = 0)
BEGIN
    PRINT('Source File Not Found')
END
RETURN -1


	SET @query =  'INSERT INTO '+@tableName + 
	              ' SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 

	BEGIN TRY
	BEGIN TRANSACTION [Tran1]
		EXECUTE sp_executesql @query;
		PRINT 'Service successful added.'
     COMMIT TRANSACTION [Tran1]
	END TRY
	BEGIN CATCH
	    PRINT @query
		PRINT 'Sorry, inserting was not successful.'
		print ERROR_MESSAGE()
		ROLLBACK TRANSACTION [Tran1]
	END CATCH

END