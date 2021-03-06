USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewCall]    Script Date: 11/21/2019 11:31:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AddNewCall]
	@filePath  NVARCHAR(MAX)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @query NVARCHAR(MAX);
	DECLARE @tableName NVARCHAR(MAX);
	DECLARE @sheetName NVARCHAR(MAX);

	SET @tableName = 'Call'
	SET @sheetName = 'Nov_Calls'

--============================================================================================


	SET @query =  'INSERT INTO '+@tableName + ' SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				  ''Excel 12.0;DATABASE='+ @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 

	BEGIN TRY
		EXECUTE sp_executesql @query;
		PRINT 'Insert successful.'
	END TRY
	BEGIN CATCH
	    PRINT @query
		PRINT 'Sorry, inserting the file was not successful.'
		print ERROR_MESSAGE()
	END CATCH;
	
END
