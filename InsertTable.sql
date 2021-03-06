USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[InsertTable]    Script Date: 11/21/2019 11:40:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[InsertTable]
	@filePath  NVARCHAR(MAX),
	@sheetName NVARCHAR(MAX), 
	@tableName NVARCHAR(MAX) 	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @query NVARCHAR(MAX);

	SET @query =  'INSERT INTO '+@tableName + ' SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 

	BEGIN TRY
		EXECUTE sp_executesql @query;
		PRINT 'Insert successful.'
	END TRY
	BEGIN CATCH
		PRINT 'Sorry, inserting the file was not successful.'
		PRINT ERROR_MESSAGE()
	END CATCH;
	
END
