USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ExportMonthlySalesRepCommission]    Script Date: 11/21/2019 11:37:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[ExportMonthlySalesRepCommission]
(@month int,
 @year int)

AS

BEGIN
DECLARE @commisionQuery NVARCHAR(MAX)

INSERT INTO OPENROWSET ('Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\Users\HHH\Desktop\Exported\MonthlySalesRepCommission.xlsx;', 
'SELECT * FROM [Sheet1$]')
SELECT sRep.salesReperesentativeId AS Representative_ID, 
sRep.fName AS First_Name, sRep.lName AS Last_Name, SUM((c.comissionRate/100*(
																		  case 
																			when cal.callTime BETWEEN  
																			s.peakPeriod and s.offPeakPeriod 
																			THEN r.peakRate 
																			ELSE r.offPeakRate END)*cal.duration/60) 
																			) AS Total_Commission
FROM dbo.SalesRepresentative sRep, Customer c, dbo.Call cal, dbo.CallingCode cc, dbo.Service s, dbo.Rate r
WHERE c.salesrepsentativeId = sRep.salesReperesentativeId AND
        Year(cal.callDate) = @year AND 
		MOnth(cal.callDate) = @month AND
		s.serviceNo = c.serviceNo AND
		cal.telephoneNo = c.telephoneNo AND
		cc.countryCode = cal.countryCode AND
		s.countryCode = r.countryCode		
GROUP BY  sRep.salesReperesentativeId, sRep.fName, sRep.lName
END
