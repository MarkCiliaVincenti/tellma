﻿CREATE PROCEDURE [bll].[Documents_Validate__Save]
	@DefinitionId NVARCHAR(50),
	@Documents [dbo].[DocumentList] READONLY,
	@Lines [dbo].[LineList] READONLY, 
	@Entries [dbo].EntryList READONLY,
	@Top INT = 10
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET()
	DECLARE @UserId INT = CONVERT(INT, SESSION_CONTEXT(N'UserId'));
	DECLARE @IsOriginalDocument BIT = (SELECT IsOriginalDocument FROM dbo.DocumentDefinitions WHERE [Id] = @DefinitionId);

	--=-=-=-=-=-=- [C# Validation]
	/* 
	
	 [✓] The SerialNumber is required if original document
	 [✓] The SerialNumber is not duplicated in the uploaded list
	 [✓] The PostingDate is not after 1 day in the future
	 [✓] The PostingDate cannot be before archive date
	 [✓] If Entry.CurrencyId is functional, the value must be the same as monetary value

	*/

	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	--          Common Validation (JV + Smart)
	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
	-- Serial number must not be already in the back end
	IF @IsOriginalDocument = 0
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP (@Top)
		'[' + CAST(FE.[Index] AS NVARCHAR (255)) + '].SerialNumber',
		N'Error_TheSerialNumber0IsUsed',
		CAST(FE.[SerialNumber] AS NVARCHAR (50))
	FROM @Documents FE
	JOIN [dbo].[Documents] BE ON FE.[SerialNumber] = BE.[SerialNumber]
	WHERE
		FE.[SerialNumber] IS NOT NULL
	AND BE.DefinitionId = @DefinitionId
	AND FE.Id <> BE.Id;
	-- TODO: Validate that all non-zero attachment Ids exist in the DB
	
	-- Must not edit a document that is already posted/canceled
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		CASE
			WHEN D.[PostingState] = 1 THEN N'Error_CannotEditPostedDocuments'
			WHEN D.[PostingState] = -1 THEN N'Error_CannotEditCanceledDocuments'
		END
	FROM @Documents FE
	JOIN [dbo].[Documents] D ON FE.[Id] = D.[Id]
	WHERE D.[PostingState] <> 0;
	-- Must not delete a line not in draft state
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT DISTINCT TOP (@Top)
		'[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		N'Error_CanOnlyDeleteDraftLines'
	FROM @Documents FE
	JOIN [dbo].[Lines] BL ON FE.[Id] = BL.[DocumentId]
	LEFT JOIN @Lines L ON L.[Id] = BL.[Id]
	WHERE BL.[State] <> 0 AND L.Id IS NULL;


	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	--             Smart Screen Validation
	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
-- TODO: validate that the CenterType is conformant with the AccountType
--	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0]) VALUES(DEFAULT,DEFAULT,DEFAULT);
	
	--CONTINUE;
	-- The Entry Type must be compatible with the LDE Account Type
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1])
	SELECT TOP (@Top)
		'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + '].EntryTypeId',
		N'Error_TheField0Value1IsIncompatible',
		dbo.fn_Localize(LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [EntryTypeFieldName],
		dbo.fn_Localize([ETE].[Name], [ETE].[Name2], [ETE].[Name3]) AS EntryType
	FROM @Entries E
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN [dbo].[LineDefinitionEntries] LDE ON LDE.LineDefinitionId = L.DefinitionId AND LDE.[Index] = E.[Index]
	JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[TableName] = N'Entries' AND LDC.[EntryIndex] = E.[Index] AND LDC.[ColumnName] = N'EntryTypeId'
	JOIN [dbo].[AccountTypes] [AT] ON LDE.[AccountTypeParentCode] = [AT].[Code] 
	JOIN dbo.[EntryTypes] ETE ON E.[EntryTypeId] = ETE.Id
	JOIN dbo.[EntryTypes] ETA ON [AT].[EntryTypeParentId] = ETA.[Id]
	WHERE ETE.[Node].IsDescendantOf(ETA.[Node]) = 0 AND L.[DefinitionId] <> N'ManualLine';
	-- Validate that ResourceId descends from LDE.AccountTypeParentId IFF it is has IsResourceClassification = 1
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1], [Argument2], [Argument3])
	SELECT TOP (@Top)
		N'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + N'].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + N'].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + N'].ResourceId',
		N'Error_TheField01Classification2IsIncompatibleWith3',
		dbo.fn_Localize(LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [FieldName],
		dbo.fn_Localize(R.[Name], R.[Name2], R.[Name3]) AS [Resource],
		dbo.fn_Localize(RC.[Name], RC.[Name2], RC.[Name3]) AS [ResourceClassification],
		dbo.fn_Localize(ATP.[Name], ATP.[Name2], ATP.[Name3]) AS [DefinitionAccountClassification]
	FROM @Entries E	
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[TableName] = N'Entries' AND LDC.[EntryIndex] = E.[Index] AND LDC.[ColumnName] = N'ResourceId'
	JOIN dbo.LineDefinitionEntries LDE ON LDE.LineDefinitionId = L.DefinitionId AND LDE.[Index] = E.[Index]
	JOIN dbo.Resources R ON E.[ResourceId] = R.[Id]
	JOIN dbo.AccountTypes RC ON R.AccountTypeId = RC.[Id]
	JOIN dbo.AccountTypes ATP ON LDE.AccountTypeParentCode = ATP.[Code]
	WHERE RC.[Node].IsDescendantOf(ATP.[Node]) = 0
	AND ATP.[IsResourceClassification] = 1
	AND L.[DefinitionId] <> N'ManualLine';

	-- verify that all required fields are available
	DECLARE @LineState SMALLINT, @L LineList, @E EntryList;
		SELECT @LineState = MIN([State])
		FROM dbo.Lines
		WHERE [State] > 0
		AND [Id] IN (SELECT [Id] FROM @Lines)
	
	WHILE @LineState IS NOT NULL
	BEGIN
		DELETE FROM @L; DELETE FROM @E;
		INSERT INTO @L SELECT * FROM @Lines WHERE [Id] IN (SELECT [Id] FROM dbo.Lines WHERE [State] = @LineState);
		INSERT INTO @E SELECT E.* FROM @Entries E JOIN @L L ON E.LineIndex = L.[Index] AND E.DocumentIndex = L.DocumentIndex
		INSERT INTO @ValidationErrors
		EXEC [bll].[Lines_Validate__State_Update]
		@Lines = @L, @Entries = @E, @ToState = @LineState;

		SET @LineState = (
			SELECT MIN([State])
			FROM dbo.Lines
			WHERE [State] > @LineState
			AND [Id] IN (SELECT [Id] FROM @Lines)
		)
	END
	SELECT TOP (@Top) * FROM @ValidationErrors;