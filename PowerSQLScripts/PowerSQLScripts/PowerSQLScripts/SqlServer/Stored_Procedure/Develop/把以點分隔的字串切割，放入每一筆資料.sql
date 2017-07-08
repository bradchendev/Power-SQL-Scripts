-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	把以點分隔的字串切割，放入每一筆資料

-- =============================================

    DECLARE @forWord_ NVARCHAR(2000) 	        
     SET @forWord_ = 'abc,def,ghi,jkl';
            
     DECLARE @tmp table(
	      val NVARCHAR(200) PRIMARY KEY
	 );   
     DECLARE @p NVARCHAR(200);
     
	 -- 反覆切出實際值並塞到暫存表後回傳
	 WHILE LEN(@forWord_) > 0
	 BEGIN
		IF CHARINDEX(',', @forWord_) = 0
		BEGIN
			SET @p = @forWord_;
			SET @forWord_ = '';
		END
		ELSE
		BEGIN
			SET @p = LEFT(@forWord_, CHARINDEX(',', @forWord_) - 1);
			SET @forWord_ = RIGHT(@forWord_, LEN(@forWord_) - LEN(@p) - 1);
	 	END
	 	
	 	IF (LEN(@p) > 0) INSERT INTO @tmp (val) VALUES (@p);
	 END
	 
	 SELECT * FROM @tmp;
	 
--return
-- val
--abc
--def
--ghi
--jkl

	 
	 -- 逗點分隔
	 
	declare @pos int
	declare @SendToArray_IN varchar(50) = 'abc,def,ghi,jkl'
	
	 		WHILE CHARINDEX(',', @SendToArray_IN, @pos + 1) > 0
			BEGIN
							-- do
							SET @pos = CHARINDEX(',', @SendToArray_IN, @pos + @len) + 1
			END
