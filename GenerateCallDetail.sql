USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[GenerateCallDetail]    Script Date: 11/21/2019 11:37:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GenerateCallDetail]
	@month int,
	@year int
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @valid bit = 1;

	IF @year > YEAR(GETDATE())
	BEGIN
		SET @valid = 0;
		RAISERROR('Invalid from year, year can only be in the past! ', 11, 1);		
		RETURN;
	END
	IF( @month > 12)
	BEGIN
		SET @valid = 0;
		RAISERROR('Invalid to month, month must be < 12 !', 11, 1);
		RETURN;
	END

	
	IF @valid = 1
	BEGIN
		SELECT telephoneNo AS Caller, toTel AS Called, countryCode AS Called_Country
		, duration AS Duration, callDate AS Call_Date, callTime AS Call_Time
		FROM Call
		WHERE Month(callDate) = @month AND YEAR(callDate) = @year 
	END
	ELSE
		PRINT 'Invalid input'	
END
