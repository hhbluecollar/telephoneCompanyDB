USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewRate]    Script Date: 11/21/2019 11:35:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AddNewRate]
	@filePath NVARCHAR(MAX)
AS
BEGIN
	
	SET NOCOUNT ON;
	------------------------- Declare variables -----------------
	DECLARE @fileName VARCHAR(50);
	DECLARE @serviceType NVARCHAR(MAX);
	DECLARE @countryName NVARCHAR(MAX);
	DECLARE @serviceNo INT;
	DECLARE @sheetName VARCHAR(100);
	DECLARE @effectiveDate DATE;
	DECLARE @ServiceCursor CURSOR;
	DECLARE @query NVARCHAR(MAX);
    ---------------------- Extract the file name and effective date ------------------------
	SELECT @fileName = RIGHT(@filePath, CHARINDEX('\', REVERSE(@filePath)) -1);	
	PRINT @fileName
	---- SUBSTRING(string, start, length) ------ date format yyy/mm/dd ----
	SET @effectiveDate = CONVERT(date, SUBSTRING(@fileName, 7, 4)+'-'+SUBSTRING(@fileName, 11, 2)+'-'+
	SUBSTRING(@fileName, 13, 2), 23);
	
	BEGIN
	------------------------- loop thru' the sheets for each service ---------------	
		SET @ServiceCursor = CURSOR FOR SELECT ServiceNo from Service;
		OPEN @ServiceCursor;
	------------------------- point a cursor in the service table to the countryCode attribute ---------------	
		FETCH NEXT FROM @ServiceCursor INTO @serviceNo;
		WHILE @@FETCH_STATUS = 0
		BEGIN
	 --------------------------- Concatinate the service type and the country name ------------
			SELECT @serviceType = serviceType FROM Service WHERE serviceNo = @serviceNo;
			SELECT @countryName = countryName FROM CallingCode WHERE countryCode = 
												  (SELECT countryCode FROM Service WHERE serviceNo = @serviceNo);
			SET @sheetName = @serviceType + '_' +@countryName;
			SET @query = 'INSERT INTO Rate SELECT ''' + CAST(@effectiveDate as varchar) + 
			             ''' as effectiveDate, dest as countryCode, '+CAST( @serviceNo as varchar)+
						 ' as serviceNo,  peak  as peakRate, offpeak  as offPeakRate FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
						 ''Excel 8.0;Database=' + @filePath +''', ''SELECT * FROM ['+ @sheetName +'$]'')';
			BEGIN TRY
				PRINT @query
				EXECUTE sp_executesql @query;
			END TRY
			BEGIN CATCH
			print ERROR_MESSAGE()
			PRINT 'Sorry, inserting records unsuccessful'
			END CATCH;
			FETCH NEXT FROM @ServiceCursor INTO @serviceNo;
		END; 
		CLOSE @ServiceCursor;
		DEALLOCATE @ServiceCursor;
		
	END; 	
END
