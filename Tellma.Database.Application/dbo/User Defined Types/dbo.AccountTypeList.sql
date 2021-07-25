﻿CREATE TYPE [dbo].[AccountTypeList] AS TABLE (
	[Index]						INT PRIMARY KEY ,
	[Id]						INT,
	[ParentIndex]				INT,
	[ParentId]					INT,
	[Code]						NVARCHAR (50),
	[Concept]					NVARCHAR (255),
	[Name]						NVARCHAR (255),
	[Name2]						NVARCHAR (255),
	[Name3]						NVARCHAR (255),
	[Description]				NVARCHAR (1024),
	[Description2]				NVARCHAR (1024),
	[Description3]				NVARCHAR (1024),
	[IsMonetary]				BIT,
	[IsAssignable]				BIT,
	[StandardAndPure]			BIT,
	[CustodianDefinitionId]		INT,
	[EntryTypeParentId]			INT,
	[Time1Label]				NVARCHAR (50),
	[Time1Label2]				NVARCHAR (50),
	[Time1Label3]				NVARCHAR (50),
	[Time2Label]				NVARCHAR (50),
	[Time2Label2]				NVARCHAR (50),
	[Time2Label3]				NVARCHAR (50),
	[ExternalReferenceLabel]	NVARCHAR (50),
	[ExternalReferenceLabel2]	NVARCHAR (50),
	[ExternalReferenceLabel3]	NVARCHAR (50),
	[ReferenceSourceLabel]		NVARCHAR (50),
	[ReferenceSourceLabel2]		NVARCHAR (50),
	[ReferenceSourceLabel3]		NVARCHAR (50),
	[InternalReferenceLabel]	NVARCHAR (50),
	[InternalReferenceLabel2]	NVARCHAR (50),
	[InternalReferenceLabel3]	NVARCHAR (50),
	[NotedAgentNameLabel]		NVARCHAR (50),
	[NotedAgentNameLabel2]		NVARCHAR (50),
	[NotedAgentNameLabel3]		NVARCHAR (50),
	[NotedAmountLabel]			NVARCHAR (50),
	[NotedAmountLabel2]			NVARCHAR (50),
	[NotedAmountLabel3]			NVARCHAR (50),
	[NotedDateLabel]			NVARCHAR (50),
	[NotedDateLabel2]			NVARCHAR (50),
	[NotedDateLabel3]			NVARCHAR (50)
);