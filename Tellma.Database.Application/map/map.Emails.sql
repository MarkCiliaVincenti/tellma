﻿CREATE FUNCTION [map].[Emails]()
RETURNS TABLE
AS
RETURN (
	SELECT * FROM [dbo].[Emails]
);