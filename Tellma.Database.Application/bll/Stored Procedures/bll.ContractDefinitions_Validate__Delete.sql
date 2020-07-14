﻿CREATE PROCEDURE [bll].[ContractDefinitions_Validate__Delete]
	@Ids [dbo].[IndexedIdList] READONLY,
	@Top INT = 10
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];	

	-- Check that Definition is not used
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP(@Top)
		 '[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		N'Error_Definition0AlreadyContainsData',
		dbo.fn_Localize(D.[TitlePlural], D.[TitlePlural2], D.[TitlePlural3]) AS [Contract]
	FROM @Ids FE
	JOIN dbo.[ContractDefinitions] D ON D.[Id] = FE.[Id]
	JOIN dbo.[Contracts] R ON R.[DefinitionId] = FE.[Id]

	-- Check that Definition is not used in Account Definition Filters
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1])
	SELECT TOP(@Top)
		 '[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		N'Error_TheContractDefinition0IsUsedInAccountType1',
		dbo.fn_Localize(D.[TitleSingular], D.[TitleSingular2], D.[TitleSingular3]) AS [Definition],
		dbo.fn_Localize(AD.[Name], AD.[Name2], AD.[Name3]) AS [AccountType]
	FROM @Ids FE
	JOIN dbo.[ContractDefinitions] D ON D.[Id] = FE.[Id]
	JOIN dbo.[AccountTypeContractDefinitions] ADRD ON ADRD.[ContractDefinitionId] = FE.[Id]
	JOIN dbo.[AccountTypes] AD ON AD.[Id] = ADRD.[AccountTypeId]

	SELECT TOP(@Top) * FROM @ValidationErrors;