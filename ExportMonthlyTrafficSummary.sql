USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ExportMonthlyTrafficSummary]    Script Date: 11/21/2019 11:37:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ExportMonthlyTrafficSummary]
	@trafficMonth int,
	@trafficYear int
AS
BEGIN
INSERT INTO OPENROWSET ('Microsoft.ACE.OLEDB.12.0', 
	'Excel 12.0;Database=C:\Users\HHH\Desktop\Exported\MonthlyTrafficSummary.xlsx;', 
	'SELECT * FROM [Sheet1$]') 
	SELECT s.serviceType AS Service_Names,  s.countryCode AS From_Country, 
	cc.countryName AS To_Country,SUM(c.duration/60) AS TotalMinutes 
	FROM dbo.Service s, dbo.Call c, dbo.CallingCode cc, dbo.Customer u
    WHERE c.countryCode = cc.countryCode AND MONTH(c.callDate) = @trafficMonth AND 
	      YEAR(c.callDate) = @trafficYear AND c.telephoneNo = u.telephoneNo AND
		   s.serviceNo = u.serviceNO 
    GROUP BY s.serviceType, s.countryCode, cc.countryName
END
