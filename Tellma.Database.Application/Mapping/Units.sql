﻿CREATE FUNCTION [map].[Units] ()
RETURNS TABLE
AS
RETURN (
	SELECT * FROM [dbo].[Units]
);
