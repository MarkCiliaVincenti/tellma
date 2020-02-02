﻿DECLARE @ResourceDefinitions dbo.ResourceDefinitionList;

IF @DB = N'100'
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitleSingular],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'Property, plant and equipment',dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(1,N'investment-properties',			N'Investment properties',				N'Investment property',			dbo.fn_ATCode__Id(N'InvestmentProperty')),
	(2,N'intangible-assets',				N'Intangible assets',					N'Intangible asset',			dbo.fn_ATCode__Id(N'IntangibleAssetsOtherThanGoodwill')),
	(3,N'biological-assets',				N'Biological assets',					N'Biological asset',			dbo.fn_ATCode__Id(N'BiologicalAssets')),
	(4,N'inventories',						N'Inventory items',						N'Inventory Item',				dbo.fn_ATCode__Id(N'InventoriesTotal')),
	(5,N'services-expenses',				N'Services expenses',					N'Service expense',				dbo.fn_ATCode__Id(N'ServicesExpense'));
END
ELSE IF @DB = N'101' -- Banan SD, USD, en
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitleSingular],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'Property, plant and equipment',dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(2,N'intangible-assets',				N'Intangible assets',					N'Intangible asset',			dbo.fn_ATCode__Id(N'IntangibleAssetsOtherThanGoodwill')),
	(5,N'services-expenses',				N'Services expenses',					N'Service expense',				dbo.fn_ATCode__Id(N'ServicesExpense'));
END
ELSE IF @DB = N'102' -- Banan ET, ETB, en
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitleSingular],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'Property, plant and equipment',dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(5,N'services-expenses',				N'Services expenses',					N'Service expense',				dbo.fn_ATCode__Id(N'ServicesExpense'));
END
ELSE IF @DB = N'103' -- Lifan Cars, ETB, en/zh
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitleSingular],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'Property, plant and equipment',dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(4,N'inventories',						N'Inventory items',						N'Inventory Item',				dbo.fn_ATCode__Id(N'InventoriesTotal')),
	(5,N'services-expenses',				N'Services expenses',					N'Service expense',				dbo.fn_ATCode__Id(N'ServicesExpense'));
END
ELSE IF @DB = N'104' -- Walia Steel, ETB, en/am
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitleSingular],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'Property, plant and equipment',dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(1,N'investment-properties',			N'Investment properties',				N'Investment property',			dbo.fn_ATCode__Id(N'InvestmentProperty')),
	(4,N'inventories',						N'Inventory items',						N'Inventory Item',				dbo.fn_ATCode__Id(N'InventoriesTotal')),
	(5,N'services-expenses',				N'Services expenses',					N'Service expense',				dbo.fn_ATCode__Id(N'ServicesExpense'));
END
ELSE IF @DB = N'105' -- Simpex, SAR, en/ar
BEGIN
	INSERT INTO @ResourceDefinitions([Index],
	[Id],									[TitlePlural],							[TitlePlural2],						[TitleSingular],					[TitleSingular2],				[ParentAccountTypeId]) VALUES
	(0,N'properties-plants-and-equipment',	N'Properties, plants and equipment',	N'الممتلكات والمنشآت والمعدات',	N'Property, plant and equipment',	N'الممتلكة -المنشأة-المعدة',	dbo.fn_ATCode__Id(N'PropertyPlantAndEquipment')),
	(4,N'paper-products',					N'Paper Products',						N'منتجات الورق',					N'Paper Product',					N'منتج ورق',					dbo.fn_ATCode__Id(N'Merchandise')),
	(5,N'services-expenses',				N'Services',							N'الخدمات',							N'Service',							N'الخدمة',						dbo.fn_ATCode__Id(N'ServicesExpense'));

	UPDATE @ResourceDefinitions
	SET
		[CountUnitVisibility] = N'Optional',
		[MassUnitVisibility] = N'Required',
		[DescriptionVisibility] = N'Optional',
		[Lookup1Label]	= N'Origin',
		[Lookup1Label2]	= N'التصنيع'	,
		[Lookup1Visibility] = N'Required',
		[Lookup1DefinitionId] = N'paper-origins',
		[Lookup2Label]	= N'Group',
		[Lookup2Label2]	= N'المجموعة'	,
		[Lookup2Visibility] = N'Required',
		[Lookup2DefinitionId] = N'paper-groups',
		[Lookup3Label]	= N'Type',
		[Lookup3Label2]	= N'النوع'	,
		[Lookup3Visibility] = N'Required',
		[Lookup3DefinitionId] = N'paper-types'
	WHERE [Id] = N'paper-products'
END

EXEC [api].[ResourceDefinitions__Save]
	@Entities = @ResourceDefinitions,
	@ValidationErrorsJson = @ValidationErrorsJson OUTPUT;

IF @ValidationErrorsJson IS NOT NULL 
BEGIN
	Print 'Resource Definitions Standard: Inserting: ' + @ValidationErrorsJson
	GOTO Err_Label;
END;		