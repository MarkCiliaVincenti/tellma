﻿CREATE FUNCTION [map].[Roles] ()
RETURNS TABLE
AS
RETURN (
	SELECT * FROM [dbo].[Roles]
);
