﻿CREATE PROCEDURE [api].[Resources__Save]
	@DefinitionId INT,
	@Entities [dbo].[ResourceList] READONLY,
	@ResourceUnits [dbo].[ResourceUnitList] READONLY,
	@ReturnIds BIT = 0,
	@UserId INT,
	@Culture NVARCHAR(50),
	@NeutralCulture NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Set the global values of the session context
	DECLARE @UserLanguageIndex TINYINT = [dbo].[fn_User__Language](@Culture, @NeutralCulture);
    EXEC sys.sp_set_session_context @key = N'UserLanguageIndex', @value = @UserLanguageIndex;
	
	-- (1) Validate
	DECLARE @IsError BIT;
	EXEC [bll].[Resources_Validate__Save]
		@DefinitionId = @DefinitionId,
		@Entities = @Entities,
		@ResourceUnits = @ResourceUnits,
		@UserId = @UserId,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1
		RETURN;

	EXEC [dal].[Resources__Save]
		@DefinitionId = @DefinitionId,
		@Entities = @Entities,
		@ResourceUnits = @ResourceUnits,
		@ReturnIds = @ReturnIds,
		@UserId = @UserId;
END;