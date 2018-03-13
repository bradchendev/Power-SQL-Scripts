-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/3/13
-- Description:	Clone SQL Login, User and Permission

	--How to Clone a SQL Server Login, Part 1 of 3
	--https://www.mssqltips.com/sqlservertip/3589/how-to-clone-a-sql-server-login-part-1-of-3/
	--How to Clone a SQL Server Login, Part 2 of 3
	--https://www.mssqltips.com/sqlservertip/3629/how-to-clone-a-sql-server-login-part-2-of-3/
	--How to Clone a SQL Server Login, Part 3 of 3
	--https://www.mssqltips.com/sqlservertip/3648/how-to-clone-a-sql-server-login-part-3-of-3/

-- =============================================


EXEC DBA.dbo.CloneLoginAndAllDBPerms
  @NewLogin = 'BradTestUser',
  @NewLoginPwd = 'SomeOtherPassw0rd!',
  @LoginToClone = 'AppUser1', -- clone from which login
  @WindowsLogin = 'F', -- F for SQL Login, T for Windows Login
  @OnlyGenSQL = 1


USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[CloneLogin]    Script Date: 03/13/2018 15:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By Brad Chen

CREATE PROCEDURE [dbo].[CloneLogin]
  @NewLogin sysname,
  @NewLoginPwd NVARCHAR(MAX),
  @WindowsLogin CHAR(1),
  @LoginToClone sysname,
  @OnlyGenSQL bit 
AS BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL nvarchar(MAX);
	DECLARE @Return int;

	IF (@WindowsLogin = 'T')
	  SET @SQL = 'CREATE LOGIN [' + @NewLogin + '] FROM WINDOWS;'
	ELSE
	  SET @SQL = 'CREATE LOGIN [' + @NewLogin + '] WITH PASSWORD = N''' + @NewLoginPwd + ''';';

    BEGIN TRAN;

	PRINT @SQL;
	IF @OnlyGenSQL = 0
	BEGIN
		EXEC @Return = sp_executesql @SQL;
	
		IF (@Return <> 0)
		BEGIN
		  ROLLBACK TRAN;
		  RAISERROR('Error encountered creating login', 16, 1);
		  RETURN(1);
		END
	END

	-- Query to handle server roles
	DECLARE cursRoleMemberSQL CURSOR FAST_FORWARD
	FOR
	SELECT 'EXEC sp_addsrvrolemember @loginame = ''' + @NewLogin 
			  + ''', @rolename = ''' + R.name + ''';' AS 'SQL'
	FROM sys.server_role_members AS RM
	  JOIN sys.server_principals AS L
		ON RM.member_principal_id = L.principal_id
	  JOIN sys.server_principals AS R
		ON RM.role_principal_id = R.principal_id
	WHERE L.name = @LoginToClone;

	OPEN cursRoleMemberSQL;

	FETCH FROM cursRoleMemberSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	
	  PRINT @SQL;
	  
	  	IF @OnlyGenSQL = 0
		BEGIN
		  EXECUTE @Return = sp_executesql @SQL;

		  IF (@Return <> 0)
			BEGIN
			  ROLLBACK TRAN;
			  RAISERROR('Error encountered assigning role memberships.', 16, 1);
			  CLOSE cursRoleMembersSQL;
			  DEALLOCATE cursRoleMembersSQL;
			  RETURN(1);
			END
		END
	
	  FETCH NEXT FROM cursRoleMemberSQL INTO @SQL;
	END;

	CLOSE cursRoleMemberSQL;
	DEALLOCATE cursRoleMemberSQL;

	DECLARE cursServerPermissionSQL CURSOR FAST_FORWARD
	FOR
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' TO [' + @NewLogin + '] WITH GRANT OPTION;'
		   ELSE 
			 'USE master;  ' + P.state_desc + ' ' + P.permission_name + ' TO [' + @NewLogin + '];'   
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	WHERE L.name = @LoginToClone
	  AND P.class = 100
	  AND P.type <> 'COSQ'
	UNION ALL
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' ON LOGIN::[' + L2.name + 
			 '] TO [' + @NewLogin + '] WITH GRANT OPTION;' COLLATE DATABASE_DEFAULT
		   ELSE 
			 'USE master; ' + P.state_desc + ' ' + P.permission_name + ' ON LOGIN::[' + L2.name 
			 + '] TO [' + @NewLogin + '];' COLLATE DATABASE_DEFAULT
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	  JOIN sys.server_principals AS L2
		ON P.major_id = L2.principal_id
	WHERE L.name = @LoginToClone
	  AND P.class = 101
	UNION ALL
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' ON ENDPOINT::[' + E.name + 
			 '] TO [' + @NewLogin + '] WITH GRANT OPTION;' COLLATE DATABASE_DEFAULT
		   ELSE 
			 'USE master; ' + P.state_desc + ' ' + P.permission_name + ' ON ENDPOINT::[' + E.name 
			 + '] TO [' + @NewLogin + '];' COLLATE DATABASE_DEFAULT
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	  JOIN sys.endpoints AS E
		ON P.major_id = E.endpoint_id
	WHERE L.name = @LoginToClone
	  AND P.class = 105;

	OPEN cursServerPermissionSQL;

	FETCH FROM cursServerPermissionSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		PRINT @SQL;
		
		IF @OnlyGenSQL = 0
		BEGIN
			EXEC @Return = sp_executesql @SQL;

			IF (@Return <> 0)
			BEGIN
			  ROLLBACK TRAN;
			  RAISERROR('Error encountered adding server level permissions', 16, 1);
			  CLOSE cursServerPermissionSQL;
			  DEALLOCATE cursServerPermissionSQL;
			  RETURN(1);
			END
		END
		
		FETCH NEXT FROM cursServerPermissionSQL INTO @SQL;
	END;

	CLOSE cursServerPermissionSQL;
	DEALLOCATE cursServerPermissionSQL;

	COMMIT TRAN;
	
	IF @OnlyGenSQL = 0
		PRINT 'Login [' + @NewLogin + '] cloned successfully from [' + @LoginToClone + '].';
	ELSE
		PRINT 'Generate SQL Script for Login [' + @NewLogin + '] cloned from [' + @LoginToClone + '] Successfully.';		
END;
GO
/****** Object:  StoredProcedure [dbo].[CloneDBPerms]    Script Date: 03/13/2018 15:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By Brad Chen

CREATE PROC [dbo].[CloneDBPerms]
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBName sysname,
  @OnlyGenSQL bit 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL nvarchar(max);
	DECLARE @Return int;

	CREATE TABLE #DBPermissionsTSQL 
	(
		PermsTSQL nvarchar(MAX)
	);


	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON DATABASE::[' 
		 + @DBName + '] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON DATABASE::[' 
		 + @DBNAME + '] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	WHERE class = 0
	  AND P.[type] <> ''CO''
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON SCHEMA::['' 
		 + S.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON SCHEMA::['' 
		 + S.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.schemas AS S
		ON S.schema_id = P.major_id
	WHERE class = 3
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.objects AS O
		ON O.object_id = P.major_id
	WHERE class = 1
	  AND U.name = ''' + @LoginToClone + '''
	  AND P.major_id > 0
	  AND P.minor_id = 0';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] ('' + C.name + '') TO [' + @NewLogin + '] WITH GRANT OPTION;'' 
		 COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] ('' + C.name + '') TO [' + @NewLogin + '];'' 
		 COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.objects AS O
		ON O.object_id = P.major_id
	  JOIN [' + @DBName + '].sys.columns AS C
		ON C.column_id = P.minor_id AND o.object_id = C.object_id
	WHERE class = 1
	  AND U.name = ''' + @LoginToClone + '''
	  AND P.major_id > 0
	  AND P.minor_id > 0;'
	
	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON USER::['' 
		 + U2.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON USER::['' 
		 + U2.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.database_principals AS U2
		ON U2.principal_id = P.major_id
	WHERE class = 4
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON SYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON SYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.symmetric_keys AS K
		ON P.major_id = K.symmetric_key_id
	WHERE class = 24
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON ASYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON ASYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.asymmetric_keys AS K
		ON P.major_id = K.asymmetric_key_id
	WHERE class = 26
	  AND U.name = ''' + @LoginToClone + ''';';
	
	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON CERTIFICATE::['' 
		 + C.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON CERTIFICATE::['' 
		 + C.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.certificates AS C
		ON P.major_id = C.certificate_id
	WHERE class = 25
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	DECLARE cursDBPermsSQL CURSOR FAST_FORWARD
	FOR
	SELECT PermsTSQL FROM #DBPermissionsTSQL

	OPEN cursDBPermsSQL;

	FETCH FROM cursDBPermsSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	  SET @SQL = 'USE [' + @DBName + ']; ' + @SQL;

		PRINT @SQL;
		
		IF @OnlyGenSQL = 0
		BEGIN

		  EXEC @Return = sp_executesql @SQL;

		  IF (@Return <> 0)
		  BEGIN
			  ROLLBACK TRAN;
			  RAISERROR('Error granting permission', 16, 1);
			  CLOSE cursDBPermsSQL;
			  DEALLOCATE cursDBPermsSQL;
			  RETURN(1);
		  END;
		END;
	
	  FETCH NEXT FROM cursDBPermsSQL INTO @SQL;
	END;

	CLOSE cursDBPermsSQL;
	DEALLOCATE cursDBPermsSQL;
	DROP TABLE #DBPermissionsTSQL;
END;
GO
/****** Object:  StoredProcedure [dbo].[GrantUserRoleMembership]    Script Date: 03/13/2018 15:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By Brad Chen

CREATE PROC [dbo].[GrantUserRoleMembership]
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBName sysname,
  @OnlyGenSQL bit 
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TSQL nvarchar(MAX);
  DECLARE @Return int;

  BEGIN TRAN; 

  CREATE TABLE #RoleMembershipSQL 
  (
    RoleMembersTSQL nvarchar(MAX)
  );

  SET @TSQL = 'INSERT INTO #RoleMembershipSQL (RoleMembersTSQL) 
	SELECT ''EXEC sp_addrolemember @rolename = '''''' + r.name 
      + '''''', @membername = ''''' + @NewLogin + ''''';''
    FROM [' + @DBName + '].sys.database_principals AS U
      JOIN [' + @DBName + '].sys.database_role_members AS RM
        ON U.principal_id = RM.member_principal_id
      JOIN [' + @DBName + '].sys.database_principals AS R
        ON RM.role_principal_id = R.principal_id
    WHERE U.name = ''' + @LoginToClone + ''';';

  EXEC @Return = sp_executesql @TSQL;

  IF (@Return <> 0)
  BEGIN
    ROLLBACK TRAN; 
	RAISERROR('Could not retrieve role memberships.', 16, 1);
	RETURN(1)
  END;

  DECLARE cursDBRoleMembersSQL CURSOR FAST_FORWARD
  FOR
  SELECT RoleMembersTSQL 
  FROM #RoleMembershipSQL;

  OPEN cursDBRoleMembersSQL;

  FETCH FROM cursDBRoleMembersSQL INTO @TSQL;

  WHILE (@@FETCH_STATUS = 0)
    BEGIN
	  SET @TSQL = 'USE [' + @DBName + ']; ' + @TSQL;
	  
		PRINT @TSQL;
		
		IF @OnlyGenSQL = 0
		BEGIN
		
		  EXECUTE @Return = sp_executesql @TSQL;

		  IF (@RETURN <> 0)
			BEGIN
			  ROLLBACK TRAN;
			  RAISERROR('Error encountered assigning DB role memberships.', 16, 1);
			  CLOSE cursDBRoleMembersSQL;
			  DEALLOCATE cursDBRoleMembersSQL;
			END;
		END;
	
      FETCH NEXT FROM cursDBRoleMembersSQL INTO @TSQL;
    END;

  CLOSE cursDBRoleMembersSQL;
  DEALLOCATE cursDBRoleMembersSQL;

  DROP TABLE #RoleMembershipSQL;

  COMMIT TRAN;
END;
GO
/****** Object:  StoredProcedure [dbo].[CreateUserInDB]    Script Date: 03/13/2018 15:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By Brad Chen

CREATE PROC [dbo].[CreateUserInDB]
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBName sysname,
  @OnlyGenSQL bit 
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TSQL nvarchar(MAX);
  DECLARE @Return int;

  BEGIN TRAN; 

  SET @TSQL = 'USE [' + @DBName + ']; IF EXISTS(SELECT name FROM sys.database_principals 
                         WHERE name = ''' + @LoginToClone + ''')
                 BEGIN
				   CREATE USER [' + @NewLogin + '] FROM LOGIN [' + @NewLogin + '];
				 END;';
	PRINT @TSQL;
	IF @OnlyGenSQL = 0
	BEGIN
	  EXEC @Return = sp_executesql @TSQL;

	  IF (@Return <> 0)
		BEGIN
		  ROLLBACK TRAN;
		  RAISERROR('Error creating user', 16, 1);
		  RETURN(1);
		END;
	END;

  COMMIT TRAN;
END;
GO
/****** Object:  StoredProcedure [dbo].[CloneLoginAndAllDBPerms]    Script Date: 03/13/2018 15:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By Brad Chen

CREATE PROC [dbo].[CloneLoginAndAllDBPerms]
  @NewLogin sysname,
  @NewLoginPwd NVARCHAR(MAX),
  @WindowsLogin CHAR(1),
  @LoginToClone sysname,
  @OnlyGenSQL bit 
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Return int;

  BEGIN TRAN;

  EXEC @Return = DBA.dbo.CloneLogin 
    @NewLogin = @NewLogin, 
	@NewLoginPwd = @NewLoginPwd, 
	@WindowsLogin = @WindowsLogin, 
	@LoginToClone = @LoginToClone,
	@OnlyGenSQL = @OnlyGenSQL;

  IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because login could not be created', 16, 1);
	  RETURN(1);
	END

  DECLARE @DBName sysname;
  DECLARE @SQL nvarchar(MAX);

  DECLARE cursDBs CURSOR FAST_FORWARD
  FOR
  SELECT name 
  FROM sys.databases 
  WHERE state_desc = 'ONLINE';

  OPEN cursDBs;

  FETCH FROM cursDBs INTO @DBName;

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    EXEC @Return = DBA.dbo.CreateUserInDB 
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName,
      @OnlyGenSQL = @OnlyGenSQL;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because user could not be created.', 16, 1);
	  RETURN(1);
	END;

	EXEC @Return = DBA.dbo.GrantUserRoleMembership
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName,
      @OnlyGenSQL = @OnlyGenSQL;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because role meberships could not be granted.', 16, 1);
	  RETURN(1);
	END;

	EXEC @Return = DBA.dbo.CloneDBPerms
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName,
      @OnlyGenSQL = @OnlyGenSQL;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because user could not be created.', 16, 1);
	  RETURN(1);
	END;

    FETCH NEXT FROM cursDBs INTO @DBName;
  END;

  CLOSE cursDBs;
  DEALLOCATE cursDBs;

  COMMIT TRAN;
END;
GO
