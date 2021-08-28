﻿	CREATE PROCEDURE [bll].[Lines__Pivot]
	@Lines dbo.[LineList] READONLY,
	@Entries dbo.[EntryList] READONLY
AS
	DECLARE @WideLines dbo.WideLineList;

	INSERT INTO @WideLines(
		[Index],
		[DocumentIndex],
		[Id],
		[DefinitionId],
		[PostingDate],
		[Memo],
		[Boolean1],
		[Decimal1],
		[Text1],

		[Id0],
		[Direction0],
		[AccountId0],
		[AgentId0],
		[NotedAgentId0],
		[ResourceId0],
		[CenterId0],
		[CurrencyId0],
		[EntryTypeId0],
		[MonetaryValue0],
		[Quantity0],
		[UnitId0],
		[Value0],
		[Time10],
		[Duration0],
		[DurationUnitId0],
		[Time20],
		[ExternalReference0],
		[InternalReference0],
		[NotedAgentName0],
		[NotedAmount0],
		[NotedDate0],

		[Id1],
		[Direction1],
		[AccountId1],
		[AgentId1],
		[NotedAgentId1],
		[ResourceId1],
		[CenterId1],
		[CurrencyId1],
		[EntryTypeId1],
		[MonetaryValue1],
		[Quantity1],
		[UnitId1],
		[Value1],
		[Time11],
		[Duration1],
		[DurationUnitId1],
		[Time21],
		[ExternalReference1],
		[InternalReference1],
		[NotedAgentName1],
		[NotedAmount1],
		[NotedDate1],

		[Id2],
		[Direction2],
		[AccountId2],
		[AgentId2],
		[NotedAgentId2],
		[ResourceId2],
		[CenterId2],
		[CurrencyId2],
		[EntryTypeId2],
		[MonetaryValue2],
		[Quantity2],
		[UnitId2],
		[Value2],
		[Time12],
		[Duration2],
		[DurationUnitId2],
		[Time22],
		[ExternalReference2],
		[InternalReference2],
		[NotedAgentName2],
		[NotedAmount2],
		[NotedDate2],

		[Id3],
		[Direction3],
		[AccountId3],
		[AgentId3],
		[NotedAgentId3],
		[ResourceId3],
		[CenterId3],
		[CurrencyId3],
		[EntryTypeId3],
		[MonetaryValue3],
		[Quantity3],
		[UnitId3],
		[Value3],
		[Time13],
		[Duration3],
		[DurationUnitId3],
		[Time23],
		[ExternalReference3],
		[InternalReference3],
		[NotedAgentName3],
		[NotedAmount3],
		[NotedDate3],

		[Id4],
		[Direction4],
		[AccountId4],
		[AgentId4],
		[NotedAgentId4],
		[ResourceId4],
		[CenterId4],
		[CurrencyId4],
		[EntryTypeId4],
		[MonetaryValue4],
		[Quantity4],
		[UnitId4],
		[Value4],
		[Time14],
		[Duration4],
		[DurationUnitId4],
		[Time24],
		[ExternalReference4],
		[InternalReference4],
		[NotedAgentName4],
		[NotedAmount4],
		[NotedDate4],

		[Id5],
		[Direction5],
		[AccountId5],
		[AgentId5],
		[NotedAgentId5],
		[ResourceId5],
		[CenterId5],
		[CurrencyId5],
		[EntryTypeId5],
		[MonetaryValue5],
		[Quantity5],
		[UnitId5],
		[Value5],
		[Time15],
		[Duration5],
		[DurationUnitId5],
		[Time25],
		[ExternalReference5],
		[InternalReference5],
		[NotedAgentName5],
		[NotedAmount5],
		[NotedDate5],

		[Id6],
		[Direction6],
		[AccountId6],
		[AgentId6],
		[NotedAgentId6],
		[ResourceId6],
		[CenterId6],
		[CurrencyId6],
		[EntryTypeId6],
		[MonetaryValue6],
		[Quantity6],
		[UnitId6],
		[Value6],
		[Time16],
		[Duration6],
		[DurationUnitId6],
		[Time26],
		[ExternalReference6],
		[InternalReference6],
		[NotedAgentName6],
		[NotedAmount6],
		[NotedDate6],

		[Id7],
		[Direction7],
		[AccountId7],
		[AgentId7],
		[NotedAgentId7],
		[ResourceId7],
		[CenterId7],
		[CurrencyId7],
		[EntryTypeId7],
		[MonetaryValue7],
		[Quantity7],
		[UnitId7],
		[Value7],
		[Time17],
		[Duration7],
		[DurationUnitId7],
		[Time27],
		[ExternalReference7],
		[InternalReference7],
		[NotedAgentName7],
		[NotedAmount7],
		[NotedDate7],

		[Id8],
		[Direction8],
		[AccountId8],
		[AgentId8],
		[NotedAgentId8],
		[ResourceId8],
		[CenterId8],
		[CurrencyId8],
		[EntryTypeId8],
		[MonetaryValue8],
		[Quantity8],
		[UnitId8],
		[Value8],
		[Time18],
		[Duration8],
		[DurationUnitId8],
		[Time28],
		[ExternalReference8],
		[InternalReference8],
		[NotedAgentName8],
		[NotedAmount8],
		[NotedDate8],

		[Id9],
		[Direction9],
		[AccountId9],
		[AgentId9],
		[NotedAgentId9],
		[ResourceId9],
		[CenterId9],
		[CurrencyId9],
		[EntryTypeId9],
		[MonetaryValue9],
		[Quantity9],
		[UnitId9],
		[Value9],
		[Time19],
		[Duration9],
		[DurationUnitId9],
		[Time29],
		[ExternalReference9],
		[InternalReference9],
		[NotedAgentName9],
		[NotedAmount9],
		[NotedDate9],

		[Id10],
		[Direction10],
		[AccountId10],
		[AgentId10],
		[NotedAgentId10],
		[ResourceId10],
		[CenterId10],
		[CurrencyId10],
		[EntryTypeId10],
		[MonetaryValue10],
		[Quantity10],
		[UnitId10],
		[Value10],
		[Time110],
		[Duration10],
		[DurationUnitId10],
		[Time210],
		[ExternalReference10],
		[InternalReference10],
		[NotedAgentName10],
		[NotedAmount10],
		[NotedDate10],

		[Id11],
		[Direction11],
		[AccountId11],
		[AgentId11],
		[NotedAgentId11],
		[ResourceId11],
		[CenterId11],
		[CurrencyId11],
		[EntryTypeId11],
		[MonetaryValue11],
		[Quantity11],
		[UnitId11],
		[Value11],
		[Time111],
		[Duration11],
		[DurationUnitId11],
		[Time211],
		[ExternalReference11],
		[InternalReference11],
		[NotedAgentName11],
		[NotedAmount11],
		[NotedDate11],

		[Id12],
		[Direction12],
		[AccountId12],
		[AgentId12],
		[NotedAgentId12],
		[ResourceId12],
		[CenterId12],
		[CurrencyId12],
		[EntryTypeId12],
		[MonetaryValue12],
		[Quantity12],
		[UnitId12],
		[Value12],
		[Time112],
		[Duration12],
		[DurationUnitId12],
		[Time212],
		[ExternalReference12],
		[InternalReference12],
		[NotedAgentName12],
		[NotedAmount12],
		[NotedDate12],

		[Id13],
		[Direction13],
		[AccountId13],
		[AgentId13],
		[NotedAgentId13],
		[ResourceId13],
		[CenterId13],
		[CurrencyId13],
		[EntryTypeId13],
		[MonetaryValue13],
		[Quantity13],
		[UnitId13],
		[Value13],
		[Time113],
		[Duration13],
		[DurationUnitId13],
		[Time213],
		[ExternalReference13],
		[InternalReference13],
		[NotedAgentName13],
		[NotedAmount13],
		[NotedDate13],

		[Id14],
		[Direction14],
		[AccountId14],
		[AgentId14],
		[NotedAgentId14],
		[ResourceId14],
		[CenterId14],
		[CurrencyId14],
		[EntryTypeId14],
		[MonetaryValue14],
		[Quantity14],
		[UnitId14],
		[Value14],
		[Time114],
		[Duration14],
		[DurationUnitId14],
		[Time214],
		[ExternalReference14],
		[InternalReference14],
		[NotedAgentName14],
		[NotedAmount14],
		[NotedDate14],

		[Id15],
		[Direction15],
		[AccountId15],
		[AgentId15],
		[NotedAgentId15],
		[ResourceId15],
		[CenterId15],
		[CurrencyId15],
		[EntryTypeId15],
		[MonetaryValue15],
		[Quantity15],
		[UnitId15],
		[Value15],
		[Time115],
		[Duration15],
		[DurationUnitId15],
		[Time215],
		[ExternalReference15],
		[InternalReference15],
		[NotedAgentName15],
		[NotedAmount15],
		[NotedDate15]
	)
	SELECT
		L.[Index],
		L.[DocumentIndex],
		L.[Id],
		L.[DefinitionId],
		L.[PostingDate],
		L.[Memo],
		L.[Boolean1],
		L.[Decimal1],
		L.[Text1],

		E0.[Id],
		E0.[Direction],
		E0.[AccountId],
		E0.[AgentId],
		E0.[NotedAgentId],
		E0.[ResourceId],
		E0.[CenterId],
		E0.[CurrencyId],
		E0.[EntryTypeId],
		E0.[MonetaryValue],
		E0.[Quantity],
		E0.[UnitId],
		E0.[Value],
		E0.[Time1],

		E0.[Duration],
		E0.[DurationUnitId],
		E0.[Time2],
		E0.[ExternalReference],
		E0.[InternalReference],
		E0.[NotedAgentName],
		E0.[NotedAmount],
		E0.[NotedDate],

		E1.[Id],
		E1.[Direction],
		E1.[AccountId],
		E1.[AgentId],
		E1.[NotedAgentId],
		E1.[ResourceId],
		E1.[CenterId],
		E1.[CurrencyId],
		E1.[EntryTypeId],
		E1.[MonetaryValue],
		E1.[Quantity],
		E1.[UnitId],
		E1.[Value],
		E1.[Time1],
		E1.[Duration],
		E1.[DurationUnitId],
		E1.[Time2],
		E1.[ExternalReference],
		E1.[InternalReference],
		E1.[NotedAgentName],
		E1.[NotedAmount],
		E1.[NotedDate],

		E2.[Id],
		E2.[Direction],
		E2.[AccountId],
		E2.[AgentId],
		E2.[NotedAgentId],
		E2.[ResourceId],
		E2.[CenterId],
		E2.[CurrencyId],
		E2.[EntryTypeId],
		E2.[MonetaryValue],
		E2.[Quantity],
		E2.[UnitId],
		E2.[Value],
		E2.[Time1],
		E2.[Duration],
		E2.[DurationUnitId],
		E2.[Time2],
		E2.[ExternalReference],
		E2.[InternalReference],
		E2.[NotedAgentName],
		E2.[NotedAmount],
		E2.[NotedDate],

		E3.[Id],
		E3.[Direction],
		E3.[AccountId],
		E3.[AgentId],
		E3.[NotedAgentId],
		E3.[ResourceId],
		E3.[CenterId],
		E3.[CurrencyId],
		E3.[EntryTypeId],
		E3.[MonetaryValue],
		E3.[Quantity],
		E3.[UnitId],
		E3.[Value],
		E3.[Time1],
		E3.[Duration],
		E3.[DurationUnitId],
		E3.[Time2],
		E3.[ExternalReference],
		E3.[InternalReference],
		E3.[NotedAgentName],
		E3.[NotedAmount],
		E3.[NotedDate],

		E4.[Id],
		E4.[Direction],
		E4.[AccountId],
		E4.[AgentId],
		E4.[NotedAgentId],
		E4.[ResourceId],
		E4.[CenterId],
		E4.[CurrencyId],
		E4.[EntryTypeId],
		E4.[MonetaryValue],
		E4.[Quantity],
		E4.[UnitId],
		E4.[Value],
		E4.[Time1],
		E4.[Duration],
		E4.[DurationUnitId],
		E4.[Time2],
		E4.[ExternalReference],
		E4.[InternalReference],
		E4.[NotedAgentName],
		E4.[NotedAmount],
		E4.[NotedDate],

		E5.[Id],
		E5.[Direction],
		E5.[AccountId],
		E5.[AgentId],
		E5.[NotedAgentId],
		E5.[ResourceId],
		E5.[CenterId],
		E5.[CurrencyId],
		E5.[EntryTypeId],
		E5.[MonetaryValue],
		E5.[Quantity],
		E5.[UnitId],
		E5.[Value],
		E5.[Time1],
		E5.[Duration],
		E5.[DurationUnitId],
		E5.[Time2],
		E5.[ExternalReference],
		E5.[InternalReference],
		E5.[NotedAgentName],
		E5.[NotedAmount],
		E5.[NotedDate],

		E6.[Id],
		E6.[Direction],
		E6.[AccountId],
		E6.[AgentId],
		E6.[NotedAgentId],
		E6.[ResourceId],
		E6.[CenterId],
		E6.[CurrencyId],
		E6.[EntryTypeId],
		E6.[MonetaryValue],
		E6.[Quantity],
		E6.[UnitId],
		E6.[Value],
		E6.[Time1],
		E6.[Duration],
		E6.[DurationUnitId],
		E6.[Time2],
		E6.[ExternalReference],
		E6.[InternalReference],
		E6.[NotedAgentName],
		E6.[NotedAmount],
		E6.[NotedDate],

		E7.[Id],
		E7.[Direction],
		E7.[AccountId],
		E7.[AgentId],
		E7.[NotedAgentId],
		E7.[ResourceId],
		E7.[CenterId],
		E7.[CurrencyId],
		E7.[EntryTypeId],
		E7.[MonetaryValue],
		E7.[Quantity],
		E7.[UnitId],
		E7.[Value],
		E7.[Time1],
		E7.[Duration],
		E7.[DurationUnitId],
		E7.[Time2],
		E7.[ExternalReference],
		E7.[InternalReference],
		E7.[NotedAgentName],
		E7.[NotedAmount],
		E7.[NotedDate],

		E8.[Id],
		E8.[Direction],
		E8.[AccountId],
		E8.[AgentId],
		E8.[NotedAgentId],
		E8.[ResourceId],
		E8.[CenterId],
		E8.[CurrencyId],
		E8.[EntryTypeId],
		E8.[MonetaryValue],
		E8.[Quantity],
		E8.[UnitId],
		E8.[Value],
		E8.[Time1],
		E8.[Duration],
		E8.[DurationUnitId],
		E8.[Time2],
		E8.[ExternalReference],
		E8.[InternalReference],
		E8.[NotedAgentName],
		E8.[NotedAmount],
		E8.[NotedDate],

		E9.[Id],
		E9.[Direction],
		E9.[AccountId],
		E9.[AgentId],
		E9.[NotedAgentId],
		E9.[ResourceId],
		E9.[CenterId],
		E9.[CurrencyId],
		E9.[EntryTypeId],
		E9.[MonetaryValue],
		E9.[Quantity],
		E9.[UnitId],
		E9.[Value],
		E9.[Time1],
		E9.[Duration],
		E9.[DurationUnitId],
		E9.[Time2],
		E9.[ExternalReference],
		E9.[InternalReference],
		E9.[NotedAgentName],
		E9.[NotedAmount],
		E9.[NotedDate],

		E10.[Id],
		E10.[Direction],
		E10.[AccountId],
		E10.[AgentId],
		E10.[NotedAgentId],
		E10.[ResourceId],
		E10.[CenterId],
		E10.[CurrencyId],
		E10.[EntryTypeId],
		E10.[MonetaryValue],
		E10.[Quantity],
		E10.[UnitId],
		E10.[Value],
		E10.[Time1],
		E10.[Duration],
		E10.[DurationUnitId],
		E10.[Time2],
		E10.[ExternalReference],
		E10.[InternalReference],
		E10.[NotedAgentName],
		E10.[NotedAmount],
		E10.[NotedDate],

		E11.[Id],
		E11.[Direction],
		E11.[AccountId],
		E11.[AgentId],
		E11.[NotedAgentId],
		E11.[ResourceId],
		E11.[CenterId],
		E11.[CurrencyId],
		E11.[EntryTypeId],
		E11.[MonetaryValue],
		E11.[Quantity],
		E11.[UnitId],
		E11.[Value],
		E11.[Time1],
		E11.[Duration],
		E11.[DurationUnitId],
		E11.[Time2],
		E11.[ExternalReference],
		E11.[InternalReference],
		E11.[NotedAgentName],
		E11.[NotedAmount],
		E11.[NotedDate],

		E12.[Id],
		E12.[Direction],
		E12.[AccountId],
		E12.[AgentId],
		E12.[NotedAgentId],
		E12.[ResourceId],
		E12.[CenterId],
		E12.[CurrencyId],
		E12.[EntryTypeId],
		E12.[MonetaryValue],
		E12.[Quantity],
		E12.[UnitId],
		E12.[Value],
		E12.[Time1],
		E12.[Duration],
		E12.[DurationUnitId],
		E12.[Time2],
		E12.[ExternalReference],
		E12.[InternalReference],
		E12.[NotedAgentName],
		E12.[NotedAmount],
		E12.[NotedDate],

		E13.[Id],
		E13.[Direction],
		E13.[AccountId],
		E13.[AgentId],
		E13.[NotedAgentId],
		E13.[ResourceId],
		E13.[CenterId],
		E13.[CurrencyId],
		E13.[EntryTypeId],
		E13.[MonetaryValue],
		E13.[Quantity],
		E13.[UnitId],
		E13.[Value],
		E13.[Time1],
		E13.[Duration],
		E13.[DurationUnitId],
		E13.[Time2],
		E13.[ExternalReference],
		E13.[InternalReference],
		E13.[NotedAgentName],
		E13.[NotedAmount],
		E13.[NotedDate],

		E14.[Id],
		E14.[Direction],
		E14.[AccountId],
		E14.[AgentId],
		E14.[NotedAgentId],
		E14.[ResourceId],
		E14.[CenterId],
		E14.[CurrencyId],
		E14.[EntryTypeId],
		E14.[MonetaryValue],
		E14.[Quantity],
		E14.[UnitId],
		E14.[Value],
		E14.[Time1],
		E14.[Duration],
		E14.[DurationUnitId],
		E14.[Time2],
		E14.[ExternalReference],
		E14.[InternalReference],
		E14.[NotedAgentName],
		E14.[NotedAmount],
		E14.[NotedDate],

		E15.[Id],
		E15.[Direction],
		E15.[AccountId],
		E15.[AgentId],
		E15.[NotedAgentId],
		E15.[ResourceId],
		E15.[CenterId],
		E15.[CurrencyId],
		E15.[EntryTypeId],
		E15.[MonetaryValue],
		E15.[Quantity],
		E15.[UnitId],
		E15.[Value],
		E15.[Time1],
		E15.[Duration],
		E15.[DurationUnitId],
		E15.[Time2],
		E15.[ExternalReference],
		E15.[InternalReference],
		E15.[NotedAgentName],
		E15.[NotedAmount],
		E15.[NotedDate]

	FROM @Lines L
	JOIN	  @Entries E0 ON L.[Index] = E0.[LineIndex] AND L.[DocumentIndex] = E0.[DocumentIndex] AND E0.[Index] = 0
	LEFT JOIN @Entries E1 ON L.[Index] = E1.[LineIndex] AND L.[DocumentIndex] = E1.[DocumentIndex] AND E1.[Index] = 1
	LEFT JOIN @Entries E2 ON L.[Index] = E2.[LineIndex] AND L.[DocumentIndex] = E2.[DocumentIndex] AND E2.[Index] = 2
	LEFT JOIN @Entries E3 ON L.[Index] = E3.[LineIndex] AND L.[DocumentIndex] = E3.[DocumentIndex] AND E3.[Index] = 3
	LEFT JOIN @Entries E4 ON L.[Index] = E4.[LineIndex] AND L.[DocumentIndex] = E4.[DocumentIndex] AND E4.[Index] = 4
	LEFT JOIN @Entries E5 ON L.[Index] = E5.[LineIndex] AND L.[DocumentIndex] = E5.[DocumentIndex] AND E5.[Index] = 5
	LEFT JOIN @Entries E6 ON L.[Index] = E6.[LineIndex] AND L.[DocumentIndex] = E6.[DocumentIndex] AND E6.[Index] = 6
	LEFT JOIN @Entries E7 ON L.[Index] = E7.[LineIndex] AND L.[DocumentIndex] = E7.[DocumentIndex] AND E7.[Index] = 7
	LEFT JOIN @Entries E8 ON L.[Index] = E8.[LineIndex] AND L.[DocumentIndex] = E8.[DocumentIndex] AND E8.[Index] = 8
	LEFT JOIN @Entries E9 ON L.[Index] = E9.[LineIndex] AND L.[DocumentIndex] = E9.[DocumentIndex] AND E9.[Index] = 9
	LEFT JOIN @Entries E10 ON L.[Index] = E10.[LineIndex] AND L.[DocumentIndex] = E10.[DocumentIndex] AND E10.[Index] = 10
	LEFT JOIN @Entries E11 ON L.[Index] = E11.[LineIndex] AND L.[DocumentIndex] = E11.[DocumentIndex] AND E11.[Index] = 11
	LEFT JOIN @Entries E12 ON L.[Index] = E12.[LineIndex] AND L.[DocumentIndex] = E12.[DocumentIndex] AND E12.[Index] = 12
	LEFT JOIN @Entries E13 ON L.[Index] = E13.[LineIndex] AND L.[DocumentIndex] = E13.[DocumentIndex] AND E13.[Index] = 13
	LEFT JOIN @Entries E14 ON L.[Index] = E14.[LineIndex] AND L.[DocumentIndex] = E14.[DocumentIndex] AND E14.[Index] = 14
	LEFT JOIN @Entries E15 ON L.[Index] = E15.[LineIndex] AND L.[DocumentIndex] = E15.[DocumentIndex] AND E15.[Index] = 15
	SELECT * FROM @WideLines;