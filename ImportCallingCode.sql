USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[ImportCallingCode]    Script Date: 11/21/2019 11:38:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[ImportCallingCode]
AS
BEGIN

INSERT  INTO dbo.CallingCode SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','Excel 12.0;DATABASE=C:\Users\HHH\Desktop\Calling_Codes.xls',
                'Select * from [Sheet1$]') 
EXEC [ImportCallingCode]
END