﻿CREATE TABLE [dbo].[Accounts] (
	[Id]						INT				CONSTRAINT [PK_Accounts] PRIMARY KEY NONCLUSTERED IDENTITY,
	[AccountTypeId]				INT				NOT NULL CONSTRAINT [FK_Accounts__AccountTypeId] REFERENCES [dbo].[AccountTypes] ([Id]),
	[CenterId]					INT				CONSTRAINT [FK_Accounts__CenterId] REFERENCES [dbo].[Centers] ([Id]),
	[Name]						NVARCHAR (255)	NOT NULL,
	[Name2]						NVARCHAR (255),
	[Name3]						NVARCHAR (255),
	[Code]						NVARCHAR (50),--	CONSTRAINT [IX_Accounts__Code]  ,
	[ClassificationId]			INT				CONSTRAINT [FK_Accounts__ClassificationId] REFERENCES [dbo].[AccountClassifications] ([Id]),
	-- Any non null values gets replicated to Entries
	[RelationDefinitionId]		INT				CONSTRAINT [FK_Accounts__RelationDefinitionId] REFERENCES [dbo].[RelationDefinitions] ([Id]),
	[RelationId]				INT				CONSTRAINT [FK_Accounts__RelationId] REFERENCES [dbo].[Relations] ([Id]),
	[CustodianId]				INT				CONSTRAINT [FK_Accounts__CustodianId] REFERENCES dbo.[Relations] ([Id]),
	[ResourceDefinitionId]		INT				CONSTRAINT [FK_Accounts__ResourceDefinitionId] REFERENCES [dbo].[ResourceDefinitions] ([Id]),
	[ResourceId]				INT				CONSTRAINT [FK_Accounts__ResourceId] REFERENCES [dbo].[Resources] ([Id]),
	[NotedRelationDefinitionId]	INT				CONSTRAINT [FK_Accounts__NotedRelationDefinitionId] REFERENCES [dbo].[RelationDefinitions] ([Id]),
	[NotedRelationId]			INT				CONSTRAINT [FK_Accounts__NotedRelationId] REFERENCES dbo.[Relations] ([Id]),
	[CurrencyId]				NCHAR (3)		CONSTRAINT [FK_Accounts__CurrencyId] REFERENCES [dbo].[Currencies] ([Id]),
	[EntryTypeId]				INT				CONSTRAINT [FK_Accounts__EntryTypeId] REFERENCES [dbo].[EntryTypes],
	[IsActive]					BIT				NOT NULL DEFAULT 1,
	-- Audit details
	[CreatedAt]					DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[CreatedById]				INT					NOT NULL CONSTRAINT [FK_Accounts__CreatedById] REFERENCES [dbo].[Users] ([Id]),
	[ModifiedAt]				DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[ModifiedById]				INT					NOT NULL CONSTRAINT [FK_Accounts__ModifiedById] REFERENCES [dbo].[Users] ([Id])
);
GO
CREATE CLUSTERED INDEX [IX_Accounts__Code] ON dbo.Accounts([Code]);
GO
CREATE INDEX [IX_Accounts__AccountTypeId] ON [dbo].[Accounts]([AccountTypeId]);
GO
CREATE INDEX [IX_Accounts__AccountClassificationId] ON [dbo].[Accounts]([ClassificationId]);
GO
CREATE INDEX [IX_Accounts__RelationId] ON [dbo].[Accounts]([RelationId]);
GO
CREATE INDEX [IX_Accounts__ResourceDefinitionId_ResourceId] ON [dbo].[Accounts]([ResourceDefinitionId], [ResourceId]);
GO