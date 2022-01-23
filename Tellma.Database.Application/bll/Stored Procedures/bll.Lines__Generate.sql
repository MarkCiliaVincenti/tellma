﻿CREATE PROCEDURE [bll].[Lines__Generate]
	@LineDefinitionId INT,
	@GenerateArguments [GenerateArgumentList] READONLY,
	@Documents [dbo].[DocumentList] READONLY,
	@DocumentLineDefinitionEntries [dbo].[DocumentLineDefinitionEntryList] READONLY,
	@Lines [dbo].[LineList] READONLY, 
	@Entries [dbo].[EntryList] READONLY
AS
	SET NOCOUNT ON;
	DECLARE @Script NVARCHAR (MAX);
	DECLARE @WideLines WideLineList;
	DECLARE @LinesResult LineList, @EntriesResult EntryList;
	SELECT @Script = [GenerateScript] FROM dbo.LineDefinitions WHERE [Id] = @LineDefinitionId;

	INSERT INTO @WideLines
	EXECUTE	dbo.sp_executesql @Script, N'@GenerateArguments [GenerateArgumentList] READONLY, @Documents [dbo].[DocumentList] READONLY,@DocumentLineDefinitionEntries [dbo].[DocumentLineDefinitionEntryList] READONLY, @Lines [dbo].[LineList] READONLY, @Entries [dbo].[EntryList] READONLY',
			@GenerateArguments = @GenerateArguments, 
			@Documents = @Documents, 
			@DocumentLineDefinitionEntries = @DocumentLineDefinitionEntries, 
			@Lines = @Lines, 
			@Entries = @Entries;

	UPDATE @WideLines SET DefinitionId =  @LineDefinitionId
	
	INSERT INTO @LinesResult([Index], [DocumentIndex], [DefinitionId], [PostingDate], [Memo], [Boolean1], [Decimal1], [Text1])
	SELECT [Index], 0, @LineDefinitionId, [PostingDate], [Memo], [Boolean1], [Decimal1], [Text1] FROM @WideLines

	INSERT INTO @EntriesResult
	EXEC [bll].[WideLines__Unpivot] @WideLines;

	SELECT
		[L].[DefinitionId],
		[L].[PostingDate],
		[L].[Memo],
		[L].[Boolean1],
		[L].[Decimal1],
		[L].[Text1],
		[L].[Index]
	FROM @LinesResult AS [L] -- LineList
	ORDER BY [L].[Index] ASC

	SELECT
		E.[AccountId],
		E.[CurrencyId],
		E.[AgentId],
		E.[NotedAgentId],
		E.[ResourceId],
		E.[NotedResourceId],
		E.[EntryTypeId],
		E.[CenterId],
		E.[UnitId],
		E.[Direction],
		E.[MonetaryValue],
		E.[Quantity],
		E.[Value],
		E.[Time1],
		E.[Time2],
		E.[Duration],
		E.[DurationUnitId],
		E.[ExternalReference],
		E.[ReferenceSourceId],
		E.[InternalReference],
		E.[NotedAgentName],
		E.[NotedAmount],
		E.[NotedDate],
		E.[LineIndex]
	FROM @EntriesResult AS E
	ORDER BY E.[Index] ASC
	
	-- Accounts
	SELECT 
		A.[Id], 
		A.[Name], 
		A.[Name2], 
		A.[Name3], 
		A.[Code] 
	FROM [map].[Accounts]() A 
	WHERE [Id] IN (SELECT [AccountId] FROM @EntriesResult);

	-- Currency
	SELECT 
		C.[Id], 
		C.[Name],
		C.[Name2], 
		C.[Name3], 
		C.[E]
	FROM [map].[Currencies]() C 
	WHERE [Id] IN (SELECT [CurrencyId] FROM @EntriesResult);

	-- Resource
	SELECT 
		R.[Id], 
		R.[Name], 
		R.[Name2], 
		R.[Name3], 
		R.[DefinitionId] 
	FROM [map].[Resources]() R 
	WHERE [Id] IN (SELECT [ResourceId] FROM @EntriesResult)
	OR [Id] IN  (SELECT [NotedResourceId] FROM @EntriesResult);

	-- Agent (From 3 places)
	SELECT 
		R.[Id], 
		R.[Name],
		R.[Name2],
		R.[Name3],
		R.[DefinitionId]
	FROM [map].[Agents]() R 
	WHERE [Id] IN (SELECT [AgentId] FROM @EntriesResult)
	OR [Id] IN  (SELECT [NotedAgentId] FROM @EntriesResult);

	-- EntryType
	SELECT 
		ET.[Id],
		ET.[Name], 
		ET.[Name2], 
		ET.[Name3]
	FROM [map].[EntryTypes]() ET
	WHERE [Id] IN (SELECT [EntryTypeId] FROM @EntriesResult);
	
	-- Center
	SELECT 
		C.[Id], 
		C.[Name], 
		C.[Name2], 
		C.[Name3] 
	FROM [map].[Centers]() C 
	WHERE [Id] IN (SELECT [CenterId] FROM @EntriesResult);

	-- Unit
	SELECT 
		U.[Id], 
		U.[Name], 
		U.[Name2], 
		U.[Name3] 
	FROM [map].[Units]() U 
	WHERE [Id] IN (SELECT [UnitId] FROM @EntriesResult);