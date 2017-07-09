-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	資料加解密Data Encryption

-- =============================================




--HASHBYTES (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms174415.aspx


--A: Return the hash of a variable
--The following example returns the SHA1 hash of the nvarchar data stored in variable @HashThis.
DECLARE @HashThis nvarchar(4000);  
SET @HashThis = CONVERT(nvarchar(4000),'dslfdkjLK85kldhnv$n000#knf');  
SELECT HASHBYTES('SHA1', @HashThis);  
  

--B: Return the hash of a table column
--The following example returns the SHA1 hash of the values in column c1 in the table Test1.
CREATE TABLE dbo.Test1 (c1 nvarchar(50));  
INSERT dbo.Test1 VALUES ('This is a test.');  
INSERT dbo.Test1 VALUES ('This is test 2.');  
SELECT HASHBYTES('SHA1', c1) FROM dbo.Test1;  
  

--Here is the result set.
---------------------------------------------  
--0x0E7AAB0B4FF0FD2DFB4F0233E2EE7A26CD08F173  
--0xF643A82F948DEFB922B12E50B950CEE130A934D6  
  
--(2 row(s) affected)  



--SQL Server內建的加密方法–HASHBYTES
--http://studio.5dfu.com/mssql/sql-server%E5%85%A7%E5%BB%BA%E7%9A%84%E5%8A%A0%E5%AF%86%E6%96%B9%E6%B3%95-hashbytes/


--SQL Server內建的加密方法–HASHBYTES
--加密：
--HASHBYTES('MD5',’密碼’)
--*MD5 可以更改為→MD2 | MD4 | MD5 | SHA | SHA1 | SHA2_256 | SHA2_512
--*建議可加密二層，密碼請額外加上字元(動態ex:日期、亂數、…..)，以防被破解
--*加密後的資料型態為 varbinary , 如需寫入varchar欄位，請使用sys.fn_VarBinToHexStr()函數，轉換成varchar型態，否則之後查詢時會變亂碼。
--MSDN  : 連結
--範例： 
--會員資料表
CREATE TABLE [dbo].[UserData](
[Id] [varchar](20) NOT NULL,
[Pw] [varchar](200) NOT NULL,
CONSTRAINT [PK_UserData] PRIMARY KEY CLUSTERED
([Id] ASC)) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


--新增會員資料
INSERT INTO [UserData]
([Id]
,[Pw])
VALUES
('U0001' , sys.fn_VarBinToHexStr( HASHBYTES( 'MD5' , HASHBYTES( 'MD5' , '密碼') ) ) )

--密碼驗證:
SELECT [id]
FROM [UserData]
where [Id] = 'U0001'
AND [Pw] = sys.fn_VarBinToHexStr(HASHBYTES('MD5',HASHBYTES('MD5','密碼')))







--ENCRYPTBYPASSPHRASE (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms190357.aspx
USE AdventureWorks2012;  
GO  
-- Create a column in which to store the encrypted data.  
ALTER TABLE Sales.CreditCard   
    ADD CardNumber_EncryptedbyPassphrase varbinary(256);   
GO  
-- First get the passphrase from the user.  
DECLARE @PassphraseEnteredByUser nvarchar(128);  
SET @PassphraseEnteredByUser   
    = 'A little learning is a dangerous thing!';  
  
-- Update the record for the user's credit card.  
-- In this case, the record is number 3681.  
UPDATE Sales.CreditCard  
SET CardNumber_EncryptedbyPassphrase = EncryptByPassPhrase(@PassphraseEnteredByUser  
    , CardNumber, 1, CONVERT( varbinary, CreditCardID))  
WHERE CreditCardID = '3681';  
GO  