﻿CREATE FUNCTION [rpt].[Roles] ()
RETURNS TABLE
AS
RETURN (
	SELECT * FROM [dbo].[Roles]
);
