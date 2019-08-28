﻿-- Returns all the permissions of the current user
CREATE PROCEDURE [dal].[GetUserPermissions]
AS
	DECLARE @UserId INT = CONVERT(INT, SESSION_CONTEXT(N'UserId'));

    SELECT [ViewId], [Criteria], [Action], [Mask] 
    FROM [dbo].[Permissions] P
    JOIN [dbo].[Roles] R ON P.RoleId = R.Id
    JOIN [dbo].[RoleMemberships] RM ON R.Id = RM.[RoleId]
    WHERE R.[IsActive] = 1 
    AND RM.[AgentId] = @UserId
    UNION
    SELECT [ViewId], [Criteria], [Action], [Mask] 
    FROM [dbo].[Permissions] P
    JOIN [dbo].[Roles] R ON P.[RoleId] = R.Id
    WHERE R.[IsPublic] = 1 
    AND R.[IsActive] = 1


