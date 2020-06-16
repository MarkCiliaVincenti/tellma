﻿CREATE PROCEDURE [dal].[LineDefinitions__Save]
	@Entities [LineDefinitionList] READONLY,
	@LineDefinitionEntries [LineDefinitionEntryList] READONLY,
	@LineDefinitionEntryAccountTypes LineDefinitionEntryAccountTypeList READONLY,
	@LineDefinitionEntryContractDefinitions LineDefinitionEntryContractDefinitionList READONLY,
	@LineDefinitionEntryResourceDefinitions LineDefinitionEntryResourceDefinitionList READONLY,
	@LineDefinitionEntryNotedContractDefinitions LineDefinitionEntryNotedContractDefinitionList READONLY,
	@LineDefinitionColumns [LineDefinitionColumnList] READONLY,
	@LineDefinitionStateReasons [LineDefinitionStateReasonList] READONLY,
	@Workflows [WorkflowList] READONLY,
	@WorkflowSignatures [WorkflowSignatureList] READONLY,
	@ReturnIds BIT = 0
AS
SET NOCOUNT ON;
	DECLARE @LineDefinitionsIndexedIds [dbo].[IndexedIdList], @LineDefinitionEntriesIndexIds [dbo].[IndexIdWithHeaderList];
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
	DECLARE @UserId INT = CONVERT(INT, SESSION_CONTEXT(N'UserId'));
	DECLARE @WorkflowIndexedIds [dbo].[IndexIdWithStringHeaderList];

	INSERT INTO @LineDefinitionsIndexedIds([Index], [Id])
	SELECT x.[Index], x.[Id]
	FROM
	(
		MERGE INTO [dbo].[LineDefinitions] AS t
		USING (
			SELECT
				[Index],
				[Id],
				[Code],
				[Description],
				[Description2],
				[Description3],
				[TitleSingular],
				[TitleSingular2],
				[TitleSingular3],
				[TitlePlural],
				[TitlePlural2],
				[TitlePlural3],
				[AllowSelectiveSigning],
				[ViewDefaultsToForm],
				[Script]
			FROM @Entities 
		) AS s ON (t.[Id] = s.[Id])
		WHEN MATCHED
			AND (
			t.[Code]						<> s.[Code] OR
			t.[TitleSingular]				<> s.[TitleSingular] OR	
			t.[TitlePlural]					<> s.[TitlePlural] OR
			t.[AllowSelectiveSigning]		<> s.[AllowSelectiveSigning] OR
			ISNULL(t.[Description], N'')	<> ISNULL(s.[Description], N'') OR	
			ISNULL(t.[Description2], N'')	<> ISNULL(s.[Description2], N'') OR
			ISNULL(t.[Description3], N'')	<> ISNULL(s.[Description3], N'') OR	
			ISNULL(t.[TitleSingular2], N'')	<> ISNULL(s.[TitleSingular2], N'') OR	
			ISNULL(t.[TitlePlural2], N'')	<> ISNULL(s.[TitlePlural2], N'') OR
			ISNULL(t.[TitleSingular3], N'')	<> ISNULL(s.[TitleSingular3], N'') OR	
			ISNULL(t.[TitlePlural3], N'')	<> ISNULL(s.[TitlePlural3], N'') OR
			ISNULL(t.[Script], N'')			<> ISNULL(s.[Script], N'')
			)
		THEN
			UPDATE SET
				t.[Code]						= s.[Code],
				t.[Description]					= s.[Description],
				t.[Description2]				= s.[Description2],
				t.[Description3]				= s.[Description3],
				t.[TitleSingular]				= s.[TitleSingular],
				t.[TitleSingular2]				= s.[TitleSingular2],
				t.[TitleSingular3]				= s.[TitleSingular3],
				t.[TitlePlural]					= s.[TitlePlural],
				t.[TitlePlural2]				= s.[TitlePlural2],
				t.[TitlePlural3]				= s.[TitlePlural3],
				t.[AllowSelectiveSigning]		= s.[AllowSelectiveSigning],
				t.[ViewDefaultsToForm]			= s.[ViewDefaultsToForm],
				t.[Script]						= s.[Script],
				t.[SavedById]					= @UserId
		WHEN NOT MATCHED THEN
			INSERT (
				[Code],
				[Description],
				[Description2],
				[Description3],
				[TitleSingular],
				[TitleSingular2],
				[TitleSingular3],
				[TitlePlural],
				[TitlePlural2],
				[TitlePlural3],
				[AllowSelectiveSigning],
				[ViewDefaultsToForm],
				[Script]
			)
			VALUES (
				s.[Code],
				s.[Description],
				s.[Description2],
				s.[Description3],
				s.[TitleSingular],
				s.[TitleSingular2],
				s.[TitleSingular3],
				s.[TitlePlural],
				s.[TitlePlural2],
				s.[TitlePlural3],
				s.[AllowSelectiveSigning],
				s.[ViewDefaultsToForm],
				s.[Script])
		OUTPUT s.[Index], inserted.[Id]
	) AS x;

	WITH BLDE AS (
		SELECT * FROM dbo.[LineDefinitionEntries]
		WHERE LineDefinitionId IN (SELECT [Id] FROM @LineDefinitionsIndexedIds)
	)
	INSERT INTO @LineDefinitionEntriesIndexIds([Index], [HeaderId], [Id])
	SELECT x.[Index], x.[LineDefinitionId], x.[Id]
	FROM
	(
		MERGE [dbo].[LineDefinitionEntries] AS t
		USING (
			SELECT
				LDE.[Id],
				II.[Id] AS [LineDefinitionId],
				LDE.[Index],
				LDE.[Direction],
				LDE.[EntryTypeId]
			FROM @LineDefinitionEntries LDE
			JOIN @Entities LD ON LDE.HeaderIndex = LD.[Index]
			JOIN @LineDefinitionsIndexedIds II ON LD.[Index] = II.[Index]
		) AS s
		ON s.[Id] = t.[Id]
		WHEN MATCHED 
		AND (
				t.[Direction]						<> s.[Direction] OR
				ISNULL(t.[EntryTypeId],0)			<> ISNULL(s.[EntryTypeId],0)
		)
		THEN
			UPDATE SET
				t.[Index]					= s.[Index],
				t.[Direction]				= s.[Direction],
				t.[EntryTypeId]				= s.[EntryTypeId],
				t.[SavedById]				= @UserId
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				[LineDefinitionId],
				[Index],
				[Direction],
				[EntryTypeId]
			)
			VALUES (
				s.[LineDefinitionId],
				s.[Index],
				s.[Direction],
				s.[EntryTypeId]
			)
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE
		OUTPUT s.[Index], inserted.[Id], inserted.[LineDefinitionId]
	) AS x
	WHERE [Index] IS NOT NULL;

	WITH BLDEACT AS (
		SELECT * FROM dbo.[LineDefinitionEntryAccountTypes]
		WHERE [LineDefinitionEntryId] IN (SELECT [Id] FROM @LineDefinitionEntriesIndexIds)
	)
	MERGE INTO BLDEACT AS t
	USING (
		SELECT
			E.[Id], LI.Id AS [LineDefinitionEntryId], E.[AccountTypeId]
		FROM @LineDefinitionEntryAccountTypes E
		JOIN @LineDefinitionsIndexedIds DI ON E.[LineDefinitionIndex] = DI.[Index]
		JOIN @LineDefinitionEntriesIndexIds LI ON E.[LineDefinitionEntryIndex] = LI.[Index] AND LI.[HeaderId] = DI.[Id]
	) AS s ON (t.Id = s.Id)
	WHEN MATCHED AND (t.[AccountTypeId]	= s.[AccountTypeId]) THEN
		UPDATE SET
			t.[AccountTypeId]			= s.[AccountTypeId],
			t.[ModifiedAt]				= @Now,
			t.[ModifiedById]			= @UserId
	WHEN NOT MATCHED THEN
		INSERT ([LineDefinitionEntryId], [AccountTypeId])
		VALUES (s.[LineDefinitionEntryId], s.[AccountTypeId])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	WITH BLDERD AS (
		SELECT * FROM dbo.[LineDefinitionEntryResourceDefinitions]
		WHERE [LineDefinitionEntryId] IN (SELECT [Id] FROM @LineDefinitionEntriesIndexIds)
	)
	MERGE INTO BLDERD AS t
	USING (
		SELECT
			E.[Id], LI.Id AS [LineDefinitionEntryId], E.[ResourceDefinitionId]
		FROM @LineDefinitionEntryResourceDefinitions E
		JOIN @LineDefinitionsIndexedIds DI ON E.[LineDefinitionIndex] = DI.[Index]
		JOIN @LineDefinitionEntriesIndexIds LI ON E.[LineDefinitionEntryIndex] = LI.[Index] AND LI.[HeaderId] = DI.[Id]
	) AS s ON (t.Id = s.Id)
	WHEN MATCHED AND (t.[ResourceDefinitionId]	= s.[ResourceDefinitionId]) THEN
		UPDATE SET
			t.[ResourceDefinitionId]			= s.[ResourceDefinitionId],
			t.[ModifiedAt]				= @Now,
			t.[ModifiedById]			= @UserId
	WHEN NOT MATCHED THEN
		INSERT ([LineDefinitionEntryId], [ResourceDefinitionId])
		VALUES (s.[LineDefinitionEntryId], s.[ResourceDefinitionId])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	WITH BLDECD AS (
		SELECT * FROM dbo.[LineDefinitionEntryContractDefinitions]
		WHERE [LineDefinitionEntryId] IN (SELECT [Id] FROM @LineDefinitionEntriesIndexIds)
	)
	MERGE INTO BLDECD AS t
	USING (
		SELECT
			E.[Id], LI.Id AS [LineDefinitionEntryId], E.[ContractDefinitionId]
		FROM @LineDefinitionEntryContractDefinitions E
		JOIN @LineDefinitionsIndexedIds DI ON E.[LineDefinitionIndex] = DI.[Index]
		JOIN @LineDefinitionEntriesIndexIds LI ON E.[LineDefinitionEntryIndex] = LI.[Index] AND LI.[HeaderId] = DI.[Id]
	) AS s ON (t.Id = s.Id)
	WHEN MATCHED AND (t.[ContractDefinitionId]	= s.[ContractDefinitionId]) THEN
		UPDATE SET
			t.[ContractDefinitionId]			= s.[ContractDefinitionId],
			t.[ModifiedAt]				= @Now,
			t.[ModifiedById]			= @UserId
	WHEN NOT MATCHED THEN
		INSERT ([LineDefinitionEntryId], [ContractDefinitionId])
		VALUES (s.[LineDefinitionEntryId], s.[ContractDefinitionId])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	WITH BLDENCD AS (
		SELECT * FROM dbo.[LineDefinitionEntryNotedContractDefinitions]
		WHERE [LineDefinitionEntryId] IN (SELECT [Id] FROM @LineDefinitionEntriesIndexIds)
	)
	MERGE INTO BLDENCD AS t
	USING (
		SELECT
			E.[Id], LI.Id AS [LineDefinitionEntryId], E.[NotedContractDefinitionId]
		FROM @LineDefinitionEntryNotedContractDefinitions E
		JOIN @LineDefinitionsIndexedIds DI ON E.[LineDefinitionIndex] = DI.[Index]
		JOIN @LineDefinitionEntriesIndexIds LI ON E.[LineDefinitionEntryIndex] = LI.[Index] AND LI.[HeaderId] = DI.[Id]
	) AS s ON (t.Id = s.Id)
	WHEN MATCHED AND (t.[NotedContractDefinitionId]	= s.[NotedContractDefinitionId]) THEN
		UPDATE SET
			t.[NotedContractDefinitionId]			= s.[NotedContractDefinitionId],
			t.[ModifiedAt]				= @Now,
			t.[ModifiedById]			= @UserId
	WHEN NOT MATCHED THEN
		INSERT ([LineDefinitionEntryId], [NotedContractDefinitionId])
		VALUES (s.[LineDefinitionEntryId], s.[NotedContractDefinitionId])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

-- TODO: Reduce updates by verifying that information has indeed been changed (like we did for LD, LDV, and LDE)
	MERGE [dbo].[LineDefinitionColumns] AS t
	USING (
		SELECT
			LDC.[Id],
			II.[Id] AS [LineDefinitionId],
			LDC.[Index],
			LDC.[ColumnName],
			LDC.[EntryIndex],
			LDC.[Label],
			LDC.[Label2],
			LDC.[Label3],
			LDC.[RequiredState],
			LDC.[ReadOnlyState],
			LDC.[InheritsFromHeader],
			LDC.[IsVisibleInTemplate]
		FROM @LineDefinitionColumns LDC
		JOIN @Entities LD ON LDC.HeaderIndex = LD.[Index]
		JOIN @LineDefinitionsIndexedIds II ON LD.[Index] = II.[Index]
	) AS s
	ON s.[Id] = t.[Id]
	WHEN MATCHED THEN
		UPDATE SET
			t.[Index]			= s.[Index],
			t.[ColumnName]		= s.[ColumnName],
			t.[EntryIndex]		= s.[EntryIndex],
			t.[Label]			= s.[Label],
			t.[Label2]			= s.[Label2],
			t.[Label3]			= s.[Label3],
			t.[RequiredState]	= s.[RequiredState],
			t.[ReadOnlyState]	= s.[ReadOnlyState],
			t.[InheritsFromHeader]=s.[InheritsFromHeader],
			t.[IsVisibleInTemplate]=s.[IsVisibleInTemplate],
			t.[SavedById]		= @UserId
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([LineDefinitionId],		[Index],	[ColumnName],	[EntryIndex], [Label],	[Label2],	[Label3],	[RequiredState], [ReadOnlyState], [InheritsFromHeader], [IsVisibleInTemplate])
		VALUES (s.[LineDefinitionId], s.[Index], s.[ColumnName], s.[EntryIndex], s.[Label], s.[Label2], s.[Label3], s.[RequiredState], s.[ReadOnlyState], s.[InheritsFromHeader],s.[IsVisibleInTemplate]);

	MERGE [dbo].[LineDefinitionStateReasons] AS t
	USING (
		SELECT
			LDSR.[Id],
			II.[Id] AS [LineDefinitionId],
			LDSR.[State],
			LDSR.[Name],
			LDSR.[Name2],
			LDSR.[Name3],
			LDSR.[IsActive]
		FROM @LineDefinitionStateReasons LDSR
		JOIN @Entities LD ON LDSR.HeaderIndex = LD.[Index]
		JOIN @LineDefinitionsIndexedIds II ON LD.[Index] = II.[Index]
	)AS s
	ON s.Id = t.Id
	WHEN MATCHED THEN
		UPDATE SET
			t.[LineDefinitionId]= s.[LineDefinitionId],
			t.[State]			= s.[State],
			t.[Name]			= s.[Name],
			t.[Name2]			= s.[Name2],
			t.[Name3]			= s.[Name3],
			t.[IsActive]		= s.[IsActive],
			t.[SavedById]		= @UserId
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([LineDefinitionId],		[State], [Name],	[Name2], [Name3], [IsActive])
		VALUES (s.[LineDefinitionId], s.[State], s.[Name], s.[Name2], s.[Name3], s.[IsActive]);

	WITH BW AS (
		SELECT * FROM dbo.[Workflows]
		WHERE LineDefinitionId IN (SELECT [Id] FROM @LineDefinitionsIndexedIds)
	)
	INSERT INTO @WorkflowIndexedIds([Index], [HeaderId], [Id])
	SELECT x.[Index], x.[LineDefinitionId], x.[Id]
	FROM
	(
		MERGE [dbo].[Workflows] AS t
		USING (
			SELECT
				W.[Index],
				W.[Id],
				II.[Id] AS [LineDefinitionId],
				W.[ToState]
			FROM @Workflows W
			JOIN @Entities LD ON W.[LineDefinitionIndex] = LD.[Index]
			JOIN @LineDefinitionsIndexedIds II ON LD.[Index] = II.[Index]
		) AS s
		ON s.[Id] = t.[Id]
		WHEN MATCHED THEN
			UPDATE SET
				t.[ToState]		= s.[ToState],
				t.[SavedById]	= @UserId
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				[LineDefinitionId],
				[ToState]
			)
			VALUES (
				s.[LineDefinitionId],
				s.[ToState]
			)
		OUTPUT s.[Index], inserted.[LineDefinitionId], inserted.[Id]
	) AS x;
	WITH BWS AS (
		SELECT * FROM dbo.[WorkflowSignatures]
		WHERE [WorkflowId] IN (SELECT [Id] FROM @WorkflowIndexedIds)
	)
	MERGE [dbo].[WorkflowSignatures] AS t
	USING (
		SELECT
			WS.[Index],
			WS.[Id],
			WI.[Id] AS WorkflowId,
			II.[Id] AS [LineDefinitionId],
			WS.[RuleType],
			WS.[RuleTypeEntryIndex],
			WS.[RoleId],
			WS.[UserId],
			WS.[PredicateType],
			WS.[PredicateTypeEntryIndex],
			WS.[Value],
			WS.[ProxyRoleId]
		FROM @WorkflowSignatures WS
		JOIN @WorkflowIndexedIds WI ON WS.[WorkflowIndex] = WI.[Index]
		JOIN @Entities LD ON 
			WI.[HeaderId] = LD.[Id]
		AND WS.[LineDefinitionIndex] = LD.[Index]
		JOIN @LineDefinitionsIndexedIds II ON LD.[Index] = II.[Index]
	) AS s ON s.[Id] = t.[Id]
	WHEN MATCHED THEN
		UPDATE SET
			t.[RuleType]				= s.[RuleType],
			t.[RuleTypeEntryIndex]		= s.[RuleTypeEntryIndex],
			t.[RoleId]					= s.[RoleId],
			t.[UserId]					= s.[UserId],
			t.[PredicateType]			= s.[PredicateType],
			t.[PredicateTypeEntryIndex]	= s.[PredicateTypeEntryIndex],
			t.[Value]					= s.[Value],
			t.[ProxyRoleId]				= s.[ProxyRoleId],
			t.[SavedById]	= @UserId
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[WorkflowId],
			[RuleType],
			[RuleTypeEntryIndex],
			[RoleId],
			[UserId],
			[PredicateType],
			[PredicateTypeEntryIndex],
			[Value],
			[ProxyRoleId]
		)
		VALUES (
			s.[WorkflowId],
			s.[RuleType],
			s.[RuleTypeEntryIndex],
			s.[RoleId],
			s.[UserId],
			s.[PredicateType],
			s.[PredicateTypeEntryIndex],
			s.[Value],
			s.[ProxyRoleId]
		);

	-- Signal clients to refresh their cache
	UPDATE [dbo].[Settings] SET [DefinitionsVersion] = NEWID();

IF @ReturnIds = 1
	SELECT * FROM @LineDefinitionsIndexedIds;