USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ExportCurrentRate]    Script Date: 11/21/2019 11:36:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[ExportCurrentRate](
@serviceName VARCHAR(50),
@sourceCountry VARCHAR(50))

AS
BEGIN
DECLARE @query NVARCHAR(MAX);
DECLARE @variable NVARCHAR(MAX);
DECLARE @sourceCountryService NVARCHAR(MAX);  

SET @sourceCountryService = (SELECT  TOP 1 serviceNo FROM Service WHERE countryCode = (SELECT TOP 1 countryCode FROM  CallingCode WHERE countryName = @sourceCountry))

SET @query =  'INSERT  INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
			 ''Excel 12.0;DATABASE=C:\Users\HHH\Desktop\Exported\'+ @serviceName+'_'+@sourceCountry+'.xlsx' + ''',
			 ''SELECT * FROM [Sheet1$]'') 
			   SELECT  c.countryName as Destinaion_Country, r.peakRate as Peak_Rate,
			        r.offPeakRate as Off_Peak_Rate FROM  Rate r, CallingCode c, Service s
		      WHERE s.serviceType = '''+@serviceName+''' AND r.countryCode = c.countryCode AND s.serviceNo = '''+@sourceCountryService+''' 
			       AND r.serviceNo ='''+@sourceCountryService+''' AND r.effectiveDate = (SELECT MAX(effectiveDate) FROM Rate ) ORDER BY c.countryName ASC'
BEGIN TRY
	    PRINT 'Export started.'
		EXECUTE sp_executesql @query;
		PRINT 'Export successful.'
	END TRY
	BEGIN CATCH
		PRINT 'Sorry, Exporting the file was not successful.'
		print ERROR_MESSAGE()
	END CATCH;
END

