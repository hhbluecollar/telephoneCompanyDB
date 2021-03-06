USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ImportTable]    Script Date: 11/21/2019 11:39:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ImportTable]
	@filePath  NVARCHAR(MAX),
	@sheetName NVARCHAR(MAX), 
	@tableName NVARCHAR(MAX) 
	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @query NVARCHAR(MAX);

	SET @query =  'SELECT * INTO '+@tableName + ' FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;DATABASE='+ 
	              @filePath + ''',''SELECT * FROM ['+ @sheetName +'$]'')' 

	BEGIN TRY
		EXECUTE sp_executesql @query;
		PRINT 'Impor successful.'
	END TRY
	BEGIN CATCH
		PRINT 'Sorry, imporing the file was not successful.'
		PRINT ERROR_MESSAGE()
	END CATCH;
	
END
