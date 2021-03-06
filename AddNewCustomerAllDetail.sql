USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[AddNewCustomerAllDetail]    Script Date: 11/21/2019 11:33:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AddNewCustomerAllDetail]
(
	@telephoneNo varchar(50),
	@fName varchar(50),
	@lName varchar(50),
	@serviceNo varchar(50),
	@street varchar(50),
	@city varchar(50),
	@stateCode varchar(50),
	@zipCode varchar(50),
	@countryCode int,
	@salesRepID int,
	@commissionRate int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @telephoneCount INT = 0;
	DECLARE @validServiceNo INT = 0;
	DECLARE @validSellRepId INT = 0;
	DECLARE @valid bit = 1;
--====================================================================================================--

	SET @telephoneCount = (SELECT COUNT(*) FROM Customer WHERE telephoneNo = @telephoneNo);
	SELECT @serviceNo =  ServiceNo FROM Service WHERE countryCode = @countryCode AND serviceNo = @serviceNo;
	SET @validSellRepId = (SELECT COUNT(*) FROM SalesRepresentative  WHERE salesReperesentativeId = @salesRepID);

---------------------------------------------------------------------------------------------------------	
	IF @serviceNo = 0
	BEGIN
		SET @valid = 0;
		PRINT 'The service does not exist!';
	END
---------------------------------------------------------------------------------------------------------
	IF @telephoneCount > 0 
	BEGIN
		SET @valid = 0;
		PRINT 'The telephone number is already registered!';
	END
------------------------------------------------------------------------------------------------------
	IF @validSellRepId = 0
	BEGIN
		SET @valid = 0;
		PRINT 'The Sales Representative ID is not valid.';
	END
---------------------------------------------------------------------------------------------------------
	IF @commissionRate < 5 or @commissionRate > 10 
	BEGIN
		SET @valid = 0;
		PRINT 'Commission rate should be between 5 and 10 percent.';
	END
---------------------------------------------------------------------------------------------------------	
	IF @valid = 0
	BEGIN
		PRINT 'Sorry: The customer cannot be added.';
		RETURN;
	END
---------------------------------------------------------------------------------------------------------
	ELSE
	BEGIN
		INSERT INTO [dbo].[Customer]
        ([telephoneNo],[fName],[lName],[street],[city],[zipCode],[stateCode],
		[countryCode],comissionRate,[serviceType],salesrepsentativeId)
		VALUES
        (@telephoneNo,@fName,@lName,@street,@city,@zipCode,@stateCode,
		@countryCode,@commissionRate,@serviceNo,@salesRepID)
		PRINT 'Success: The customer is added.';
	END	
---------------------------------------------------------------------------------------------------------
END
