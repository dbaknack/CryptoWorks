-- ******************** SqlDBM: Microsoft SQL Server ********************
-- ***** Generated by SqlDBM: CryptoWorks, v29 by dbaknack@gmail.com ****


DROP TABLE IF EXISTS "dbo"."TimeIndex";
GO


-- ************************************** "dbo"."TimeIndex"
IF NOT EXISTS (SELECT * FROM sys.tables t join sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name='dbo' and t.name='TimeIndex')
CREATE TABLE "dbo"."TimeIndex"
(
 "GlobalID"       uniqueidentifier NOT NULL CONSTRAINT "DF_TimeIndex_GlobalID" DEFAULT newid() ,
 "DailyRecID"     int IDENTITY (1, 1) NOT NULL ,
 "RequestCounter" int NOT NULL CONSTRAINT "DF_ReqCount_Value" DEFAULT 5 ,
 "SegmentID"        int NOT NULL ,
 "SpanID"         int NOT NULL ,
 "SecondofMin"    int NOT NULL ,
 "YearID"         int NOT NULL ,
 "MonthofYear"    int NOT NULL ,
 "WeekofYear"     int NOT NULL ,
 "DayofYear"      int NOT NULL ,
 "DayofMonth"     int NOT NULL ,
 "DayofWeek"      int NOT NULL ,
 "HourofDay"      int NOT NULL ,
 "MinuteofHr"     int NOT NULL ,
 "StartofSpan"    datetime2(2) NOT NULL ,
 "EndofSpan"      datetime2(2) NOT NULL ,
 "DayofWeekName"  char(3) NOT NULL ,
 "DayofWeekAscii" bigint NOT NULL ,
 "WeekDayDesc"    char(7) NOT NULL ,


 CONSTRAINT "pk_GlobalD" PRIMARY KEY CLUSTERED ("GlobalID" ASC)
);
GO
