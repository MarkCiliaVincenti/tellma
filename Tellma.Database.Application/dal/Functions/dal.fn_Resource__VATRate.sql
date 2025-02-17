﻿CREATE FUNCTION [dal].[fn_Resource__VATRate] (
	@ResourceId INT
)
RETURNS DECIMAL (19, 4)
AS
BEGIN
	RETURN 	(
		SELECT [VATRate] FROM [dbo].[Resources]
		WHERE [Id] = @ResourceId
	)
END