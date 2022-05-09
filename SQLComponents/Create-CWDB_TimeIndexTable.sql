-- Create a new table called 'TableName' in schema 'SchemaName'
-- Drop the table if it already exists
use CWDB
IF OBJECT_ID('dbo.TimeIndex', 'U') IS NOT NULL
DROP TABLE dbo.TimeIndex
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TimeIndex
(
    SpanID      INT NOT NULL,
    SecondofMin INT NOT NULL,
    GlobalID    BIGINT NOT NULL,
    [YearID]    INT NOT NULL,
    MonthofYear INT NOT NULL,
    WeekofYear  INT NOT NULL,
    DayofYear   INT NOT NULL,
    DayofMonth  INT NOT NULL,
    DayofWeek   INT NOT NULL,
    HourofDay   INT NOT NULL,
    MinuteofHr  INT NOT NULL,
    StartofSpan datetime2 NOT NULL,
    EndtofSpan datetime2 NOT NULL,
    DayofWeekName datetime2 NOT NULL,
    DayofWeekAscii datetime2 NOT NULL,
    WeekDayDesc datetime2 NOT NULL,
    BlockID varchar(9) NOT NULL
);
GO
