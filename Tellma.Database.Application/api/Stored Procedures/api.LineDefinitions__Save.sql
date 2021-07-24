﻿CREATE PROCEDURE [api].[LineDefinitions__Save]
	@Entities [dbo].[LineDefinitionList] READONLY,
	@LineDefinitionEntries [dbo].[LineDefinitionEntryList] READONLY,
	@LineDefinitionEntryRelationDefinitions [dbo].[LineDefinitionEntryRelationDefinitionList] READONLY,
	@LineDefinitionEntryResourceDefinitions [dbo].[LineDefinitionEntryResourceDefinitionList] READONLY,
	@LineDefinitionEntryNotedRelationDefinitions [dbo].[LineDefinitionEntryNotedRelationDefinitionList] READONLY,
	@LineDefinitionColumns [dbo].[LineDefinitionColumnList] READONLY,
	@LineDefinitionGenerateParameters [dbo].[LineDefinitionGenerateParameterList] READONLY,
	@LineDefinitionStateReasons [dbo].[LineDefinitionStateReasonList] READONLY,
	@Workflows [dbo].[WorkflowList] READONLY,
	@WorkflowSignatures [dbo].[WorkflowSignatureList] READONLY,
	@ReturnIds BIT = 0,
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	
	-- (1) Validate the Entities
	DECLARE @IsError BIT;
	EXEC [bll].[LineDefinitions_Validate__Save]
		@Entities = @Entities,
		@LineDefinitionEntries = @LineDefinitionEntries,
		@LineDefinitionEntryRelationDefinitions = @LineDefinitionEntryRelationDefinitions,
		@LineDefinitionEntryResourceDefinitions = @LineDefinitionEntryResourceDefinitions,
		@LineDefinitionEntryNotedRelationDefinitions = @LineDefinitionEntryNotedRelationDefinitions,
		@LineDefinitionColumns = @LineDefinitionColumns,
		@LineDefinitionGenerateParameters = @LineDefinitionGenerateParameters,
		@LineDefinitionStateReasons = @LineDefinitionStateReasons,
		@Workflows = @Workflows,
		@WorkflowSignatures = @WorkflowSignatures,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1
		RETURN;
		
	-- (2) Save the entities
	EXEC [dal].[LineDefinitions__Save]
		@Entities = @Entities,
		@LineDefinitionEntryRelationDefinitions = @LineDefinitionEntryRelationDefinitions,
		@LineDefinitionEntryResourceDefinitions = @LineDefinitionEntryResourceDefinitions,
		@LineDefinitionEntryNotedRelationDefinitions = @LineDefinitionEntryNotedRelationDefinitions,
		@LineDefinitionColumns = @LineDefinitionColumns,
		@LineDefinitionGenerateParameters = @LineDefinitionGenerateParameters,
		@LineDefinitionEntries = @LineDefinitionEntries,
		@LineDefinitionStateReasons = @LineDefinitionStateReasons,
		@Workflows = @Workflows,
		@WorkflowSignatures = @WorkflowSignatures,
		@ReturnIds = @ReturnIds,
		@UserId = @UserId;
END;