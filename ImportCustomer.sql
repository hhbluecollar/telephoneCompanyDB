USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ImportCustomer]    Script Date: 11/21/2019 11:38:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[ImportCustomer]

AS
BEGIN

SELECT * INTO   dbo.Customer 
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
               'Excel 12.0;DATABASE=C:\Users\HHH\Desktop\Project\CUSTOMERS.xls',
			   'Select * from [Sheet1$]') 
END

