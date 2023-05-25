# Database Restore Instructions

* Place database backup file in some location from where it will be accesssable by sql server instance for example: C:\TEMP\PoiDB.BAK

* Connect to sql server instance using sqlcmd or Sql Server Management Studio <br>
(In case of SSMS, Open "New Query Window" and paste below script)

* Issue the following command: 
```
RESTORE DATABASE [PoiDB] FROM  DISK = N'C:\Temp\PoiDB.BAK'
WITH  FILE = 1
,  MOVE N'PoiDB'     TO N'C:\DATA\PoiDB.mdf'
,  MOVE N'PoiDB_log' TO N'C:\DATA\PoiDB_log.ldf'
,  NOUNLOAD,  STATS = 5
GO
```
