USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewCallingCode]    Script Date: 11/21/2019 11:33:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[AddNewCallingCode]
@filePath  NVARCHAR(MAX)

AS
BEGIN
DECLARE @query NVARCHAR(MAX)
DECLARE @tableName NVARCHAR(MAX)
DECLARE @sheetName NVARCHAR(MAX)

SET @tableName = 'CallingCode'
SET @sheetName = 'Sheet1'

	SET @query =  'INSERT INTO '+@tableName + 
	              ' SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 

	BEGIN TRY
		EXECUTE sp_executesql @query;
		PRINT 'Calling codes successful inserted.'
	END TRY
	BEGIN CATCH
	    PRINT @query
		PRINT 'Sorry, inserting was not successful.'
		print ERROR_MESSAGE()
	END CATCH

END

