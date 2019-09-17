﻿CREATE TABLE [dbo].[ResourceClassifications]
(
	[Id]							INT					PRIMARY KEY NONCLUSTERED IDENTITY,
	[ResourceDefinitionId]			NVARCHAR(255)		NOT NULL CONSTRAINT [FK_ResourceClassifications__ResourceDefinitionId] FOREIGN KEY ([ResourceDefinitionId]) REFERENCES [dbo].[ResourceDefinitions] ([Id]),
	[ParentId]						INT					CONSTRAINT [FK_ResourceClassifications__ParentId] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[ResourceClassifications] ([Id]),
	[IsLeaf]						BIT					NOT NULL DEFAULT 1,
	[Name]							NVARCHAR(255)		NOT NULL,
	[Name2]							NVARCHAR (255),
	[Name3]							NVARCHAR (255),
	[Code]							NVARCHAR(255), -- unique per resource definition

	-- Additional properties, Is Active at the end
	[IsActive]						BIT					NOT NULL DEFAULT 1,
	-- Audit details
	[CreatedAt]						DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET() CONSTRAINT [FK_ResourceClassifications__CreatedById] FOREIGN KEY ([CreatedById]) REFERENCES [dbo].[Users] ([Id]),
	[CreatedById]					INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	[ModifiedAt]					DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET() CONSTRAINT [FK_ResourceClassifications__ModifiedById] FOREIGN KEY ([ModifiedById]) REFERENCES [dbo].[Users] ([Id]),
	[ModifiedById]					INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	-- Pure SQL properties and computed properties
	[Node]							HIERARCHYID			NOT NULL,
	[ParentNode]					AS [Node].GetAncestor(1),
);
GO;
CREATE UNIQUE CLUSTERED INDEX [IX_ResourceClassifications__ResourceDefinitionId_Node]
	ON [dbo].[ResourceClassifications]([ResourceDefinitionId], [Node]);
GO
CREATE UNIQUE INDEX [IX_ResourceClassifications__ResourceDefinitionId_Code]
	ON [dbo].[ResourceClassifications]([ResourceDefinitionId], [Code]) WHERE [Code] IS NOT NULL;
GO