USE [telephoneCompany ]
GO
/****** Object:  StoredProcedure [dbo].[MonthlyCustomerTotalBalance]    Script Date: 11/21/2019 11:40:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MonthlyCustomerTotalBalance] @month INT, 
                                                     @year  INT 
AS 
  BEGIN 
      SELECT cust.telephoneno, 
             cust.fname, 
             cust.lname, 
             cust.[street], 
             cust.city, 
             cust.zipcode, 
             cust.[stateCode ], 
             cust.country  AS fromCountry, 
             c.telephoneno, 
             c.duration, 
             c.calldate, 
             c.calltime, 
             s.servicetype, 
             cc.countryname, 
             Ceiling(( ( CASE 
                           WHEN c.calltime BETWEEN 
                                s.peakperiod AND s.offpeakperiod 
                         THEN 
                           r.peakrate 
                           ELSE r.offpeakrate 
                         END ) * c.duration / 60 ) * 100) / 100 AS rate 
      FROM   dbo.customer cust, 
             dbo.call c, 
             callingcode cc, 
             dbo.service s, 
             dbo.rate r 
      WHERE  cust.telephoneno = c.telephoneno 
             AND s.servicetype = cust.servicetype 
             AND c.telephoneno = cust.telephoneno 
             AND cc.countrycode = c.countrycode 
             AND Month(c.calldate) = @month 
             AND Year(c.calldate) = @year 
             AND r.serviceno = s.serviceno 
             AND r.countrycode = cc.countrycode 
             AND r.effectivedate = (SELECT Max(effectivedate) 
                                    FROM   rate) 
      ORDER  BY cust.fname, 
                cc.countryname 
  END