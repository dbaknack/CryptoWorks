-- ******************** SqlDBM: Microsoft SQL Server ********************
-- ***** Generated by SqlDBM: CryptoWorks, v36 by dbaknack@gmail.com ****


DROP TABLE IF EXISTS "dbo"."Logging";
GO


-- ************************************** "dbo"."Logging"
IF NOT EXISTS (SELECT * FROM sys.tables t join sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name='dbo' and t.name='Logging')
CREATE TABLE "dbo"."Logging"
(
 "Lid"                          int IDENTITY (1, 1) NOT NULL ,
 "DateTime"                     datetime2(2) NOT NULL ,
 "ElapsedTime_Milliseconds"     decimal(10,2) NOT NULL ,
 "FunctionName"                 varchar(255) NOT NULL ,
 "StepID"                       INT NOT NULL,
 "FunctionStep"                 varchar(255) NOT NULL ,
 "Level"                        varchar(255) NOT NULL ,
 "Message"                      varchar(500) NOT NULL ,


 CONSTRAINT "pk_Lid" PRIMARY KEY CLUSTERED ("Lid" ASC)
);
GO
