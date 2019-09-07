﻿CREATE TABLE [dbo].[Resources] (
	[Id]						INT					CONSTRAINT [PK_Resources] PRIMARY KEY IDENTITY,
/*
The resource type specifies the Ifrs Asset Classification and the labels for the dynamic columns.
So, we have:
	- ?: financial-instruments, banknotes, investment-bonds, shares, ...
	- RawMaterials:, hot-rolls, cold-rolls, checkered-plates, skd
	- PeoductionSupplies: 
	- work-in-progress: strips, skd-in-process, food-in-process,..
	- FinishedGoods: finished-goods-general, hsp, sm, ssm, vehicles
	- SpareParts:
	for PPE, we can have:
	- Buildings
	- MotorVehicles: Truck, Salon, Motorcycle, ...
	Or simply: (more practical, unless categories are significant for
	- PropertyPlantAndEquipment 

	Money,
	Intangible [rights,..]
	Material/Good [RM, WIP, FG, TM]
	PPE (leases, investments ?)
	Biological
	Lease services
	Employee Job
	general services
*/
	[CustomClassificationId]					INT,
	-- Once the data is imported, the classification of accounts in a manner that is consistent with Ifrs can start.
	-- The allowable values are the lowest level of the calculation trees in Ifrs Taxonomies: (financial position, comprehensive income, by function)
	-- To generate the above financial statements , classifications of childen of same parent can all be aggregated to the parent,
	-- or can some be combined into catchall "other", like Other Inventories, Other property plant and equipment, etc.
	-- To generate additional disclosures, the user must design disclosures using appropriate Ifrs concepts, and then each account 
	-- could be mapped to any concept from that disclosure.
	[IfrsClassificationId]						NVARCHAR (255),--		CONSTRAINT [FK_Resources__IfrsClassificationId] FOREIGN KEY ([IfrsClassificationId]) REFERENCES [dbo].[IfrsResourceClassifications] ([Id]),

	[ResourceType]				NVARCHAR (255)		NOT NULL,
	[Name]						NVARCHAR (255)		NOT NULL CONSTRAINT [CX_Resources__Name] UNIQUE,
	[Name2]						NVARCHAR (255),
	[Name3]						NVARCHAR (255),
	[IsActive]					BIT					NOT NULL DEFAULT 1,
-- IsBatch = 1 <=> BatchNumber is REQUIRED in table TransactionEntries when Document in Completed state
-- HasBatch, IsTrackable, 
	[IsBatch]					BIT					NOT NULL DEFAULT 0,
	[UnitId]					INT					NOT NULL,
	[UnitMonetaryValue]			DECIMAL,		-- if not null, it specifies the conversion rate Monetary Value/Primary Unit
	[CurrencyId]				INT					CONSTRAINT [FK_Resources__CurrencyId] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[MeasurementUnits] ([Id]),
	[UnitMass]					DECIMAL,		-- if not null, it specifies the conversion rate Mass/Primary Unit
	[MassUnitId]				INT					CONSTRAINT [FK_Resources__MassUnitId] FOREIGN KEY ([MassUnitId]) REFERENCES [dbo].[MeasurementUnits] ([Id]),
	[UnitVolume]				DECIMAL,		-- if not null, it specifies the conversion rate Volume/Primary Unit
	[VolumeUnitId]				INT					CONSTRAINT [FK_Resources__VolumeUnitId] FOREIGN KEY ([VolumeUnitId]) REFERENCES [dbo].[MeasurementUnits] ([Id]),
	[UnitArea]					DECIMAL,		-- if not null, it specifies the conversion rate Area/Primary Unit
	[AreaUnitId]				INT,-- FK, Table Units
	[UnitLength]				DECIMAL,		-- if not null, it specifies the conversion rate Length/Primary Unit
	[LengthUnitId]				INT,-- FK, Table Units
	[UnitTime]					DECIMAL,		-- if not null, it specifies the conversion rate Time/Primary Unit
	[TimeUnitId]				INT,-- FK, Table Units
	[UnitCount]					DECIMAL,
	[CountUnitId]				INT,-- FK, Table Units
	[Code]						NVARCHAR (255),

 -- functional currency, common stock, basic, allowance, overtime/types, 
	[SystemCode]				NVARCHAR (255),
	[Memo]						NVARCHAR (2048), -- description
	[CustomsReference]			NVARCHAR (255), -- how it is referred to by Customs
	[UniversalProductCode]		NVARCHAR (255), -- for barcode readers
	[PreferredSupplierId]		INT,-- FK, Table Agents, specially for purchasing
--	Useful for smart posting, we may need a list of compatible accounts ResourceId, AccountId.
-- If no compatible list, we get all accounts compatible with IFRS. They come at the top
-- Must have in the tree at least one account per warehouse.
	[ExpenseAccountId]			INT,
	[RevenueAccountId]			INT, -- additional accounts to be decided when we reach smart posting
	-- The following properties are user-defined, used for reporting
	-- Examples for Steel finished goods are: Thickness and width. For cars: make and model.
	[ProductCategoryId]			INT,
	[ResourceLookup1Id]			INT					CONSTRAINT [FK_Resources__ResourceLookup1Id] FOREIGN KEY ([ResourceLookup1Id]) REFERENCES [dbo].[ResourceLookup1s] ([Id]),
	[ResourceLookup2Id]			INT,			-- UDL 
	[ResourceLookup3Id]			INT,			-- UDL 
	[ResourceLookup4Id]			INT,			-- UDL 
	[CreatedAt]					DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[CreatedById]				INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	[ModifiedAt]				DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[ModifiedById]				INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	-- repeat for all lookups
	CONSTRAINT [FK_Resources__ProductCategoryId] FOREIGN KEY ([ProductCategoryId]) REFERENCES [dbo].[ProductCategories] ([Id]),
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Resources__Name2]
  ON [dbo].[Resources]([Name2]) WHERE [Name2] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Resources__Name3]
  ON [dbo].[Resources]([Name3]) WHERE [Name3] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Resources__Code]
  ON [dbo].[Resources]([Code]) WHERE [Code] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Resources__SystemCode]
  ON [dbo].[Resources]([SystemCode]) WHERE [SystemCode] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Resources__UniversalProductCode]
  ON [dbo].[Resources]([UniversalProductCode]) WHERE [UniversalProductCode] IS NOT NULL;
GO
ALTER TABLE [dbo].[Resources] ADD CONSTRAINT [CK_Resources__UnitMeasure] CHECK (
	([CurrencyId] IS NOT NULL AND [UnitId] = [CurrencyId] AND [UnitMonetaryValue] IS NOT NULL AND [UnitMonetaryValue] = 1) OR 
	([MassUnitId] IS NOT NULL AND [UnitId] = [MassUnitId] AND [UnitMass] IS NOT NULL AND [UnitMass] = 1 ) OR 
	([VolumeUnitId] IS NOT NULL AND [UnitId] = [VolumeUnitId] AND [UnitVolume] IS NOT NULL AND [UnitVolume] = 1) OR
	([AreaUnitId] IS NOT NULL AND [UnitId] = [AreaUnitId] AND [UnitArea] IS NOT NULL AND [UnitArea] = 1) OR
	([LengthUnitId] IS NOT NULL AND [UnitId] = [LengthUnitId] AND [UnitLength] IS NOT NULL AND [UnitLength] = 1) OR
	([TimeUnitId] IS NOT NULL AND [UnitId] = [TimeUnitId] AND [UnitTime] IS NOT NULL AND [UnitTime] = 1) OR
	([CountUnitId] IS NOT NULL AND [UnitId] = [CountUnitId] AND [UnitCount] IS NOT NULL AND [UnitCount] = 1)
);
GO