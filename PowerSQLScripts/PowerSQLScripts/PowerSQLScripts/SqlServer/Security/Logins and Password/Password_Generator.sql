
/**************************************************
說明:    密碼產生器
        直接執行即可產生12碼的密碼
        若是要增減長度改@NumOfCharacter變數
        若是要過濾或增減字元改@CharacterList變數
**************************************************/
-- 例如:  以下字元密碼不要有，則在@CharacterList變數裡面去除
-- XML特殊符號：< > & ' " 


declare @NumOfCharacter tinyint, @i tinyint;
declare @CharacterList varchar(100), @output varchar(12);
set @NumOfCharacter = 12;
--set @CharacterList = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^*()+-';
set @CharacterList = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%^*()+-';
set @i = 1;
set @output = '';

while @i < @NumOfCharacter + 1
begin
    set @output = @output +  substring(@CharacterList, CAST((RAND() * len(@CharacterList) + 1) as int), 1);
    set @i = @i + 1;
end

select @output;
go


-- Method 2
DECLARE @char CHAR = ''
DECLARE @charI INT = 0
DECLARE @password VARCHAR(100) = ''
DECLARE @len INT = 12 -- Length of Password
WHILE @len > 0
BEGIN
	SET @charI = ROUND(RAND()*100,0)
	SET @char = CHAR(@charI)
 
	IF @charI > 48 AND @charI < 122
	BEGIN
		SET @password += @char
		SET @len = @len - 1
	END
END
SELECT @password [PassWord]