USE [{0}]
GO

INSERT INTO [dbo].[TimeIndex]
           ([SpanID]
           ,[SecondofMin]
           ,[GlobalID]
           ,[YearID]
           ,[MonthofYear]
           ,[WeekofYear]
           ,[DayofYear]
           ,[DayofMonth]
           ,[DayofWeek]
           ,[HourofDay]
           ,[MinuteofHr]
           ,[StartofSpan]
           ,[EndtofSpan]
           ,[DayofWeekName]
           ,[DayofWeekAscii]
           ,[WeekDayDesc]
           ,[BlockID])
     VALUES
           ({0}
           ,{1}
           ,{2}
           ,{3}
           ,{4}
           ,{5}
           ,{6}
           ,{7}
           ,{8}
           ,{9}
           ,{10}
           ,{11}
           ,{12}
           ,{13}
           ,{14}
           ,{15}
           ,{16})
GO


