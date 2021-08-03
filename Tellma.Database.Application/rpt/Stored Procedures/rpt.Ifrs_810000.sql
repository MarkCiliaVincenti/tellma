﻿CREATE PROCEDURE [rpt].[Ifrs_810000]
--[810000] Notes - Corporate information and statement of IFRS compliance
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE [dbo].#IfrsDisclosureDetails(
		[Concept]			NVARCHAR (255)		NOT NULL,
		[Value]				NVARCHAR (255)
	);
	DECLARE @IfrsDisclosureId NVARCHAR (255) = N'DisclosureOfNotesAndOtherExplanatoryInformationExplanatory';

	INSERT INTO #IfrsDisclosureDetails (
			[Concept],
			[Value]
	)
	SELECT	N'NameOfReportingEntityOrOtherMeansOfIdentification',
			[dbo].[fn_Localize]([ShortCompanyName], [ShortCompanyName2], [ShortCompanyName3]) FROM dbo.Settings
	--UNION
	--SELECT	N'DomicileOfEntity',
	--		[dbo].[fn_Localize]([DomicileOfEntity], [DomicileOfEntity2], [DomicileOfEntity3]) FROM dbo.Settings
	--UNION
	--SELECT	N'LegalFormOfEntity',
	--		[dbo].[fn_Localize]([LegalFormOfEntity], [LegalFormOfEntity2], [LegalFormOfEntity3]) FROM dbo.Settings
	--UNION
	--SELECT	N'CountryOfIncorporation',
	--		[dbo].[fn_Localize]([CountryOfIncorporation], [CountryOfIncorporation2], [CountryOfIncorporation3]) FROM dbo.Settings
	--UNION
	--SELECT	N'AddressOfRegisteredOfficeOfEntity',
	--		[dbo].[fn_Localize]([AddressOfRegisteredOffice], [AddressOfRegisteredOffice2], [AddressOfRegisteredOffice3]) FROM dbo.Settings
	--UNION
	--SELECT	N'PrincipalPlaceOfBusiness',
	--		[dbo].[fn_Localize]([PrincipalPlaceOfBusiness], [PrincipalPlaceOfBusiness2], [PrincipalPlaceOfBusiness3]) FROM dbo.Settings
	--UNION
	--SELECT	N'DescriptionOfNatureOfEntitysOperationsAndPrincipalActivities',
	--		[dbo].[fn_Localize]([NatureOfOperations], [NatureOfOperations2], [NatureOfOperations3]) FROM dbo.Settings
	--UNION
	--SELECT	N'NameOfParentEntity',
	--		[dbo].[fn_Localize]([NameOfParentEntity], [NameOfParentEntity2], [NameOfParentEntity3]) FROM dbo.Settings
	--UNION
	--SELECT	N'NameOfUltimateParentOfGroup',
	--		[dbo].[fn_Localize]([NameOfUltimateParentOfGroup], [NameOfUltimateParentOfGroup2], [NameOfUltimateParentOfGroup3]) FROM dbo.Settings
/*	TODO: Add all the following
	LengthOfLifeOfLimitedLifeEntity
	StatementOfIFRSCompliance
	ManagementConclusionOnFairPresentationAsConsequenceOfDeparture
	ExplanationOfDepartureFromIFRS
	ExplanationOfFinancialEffectOfDepartureFromIFRS
	ExplanationOfNatureOfRequirementInIFRSAndConclusionWhyRequirementIsInConflictWithFairPresentation
	ExplanationOfAdjustmentsThatWouldBeNecessaryToAchieveFairPresentation
	DescriptionOfUncertaintiesOfEntitysAbilityToContinueAsGoingConcern
	ExplanationOfFactAndBasisForPreparationOfFinancialStatementsWhenNotGoingConcernBasis
	ExplanationWhyFinancialStatementsNotPreparedOnGoingConcernBasis
	DescriptionOfReasonForUsingLongerOrShorterReportingPeriod
	DescriptionOfReasonWhyFinancialStatementsAreNotEntirelyComparable
	DisclosureOfReclassificationsOrChangesInPresentationExplanatory
	DisclosureOfReclassificationsOrChangesInPresentationAbstract
	DisclosureOfReclassificationsOrChangesInPresentationTable
	ReclassifiedItemsAxis
	ReclassifiedItemsMember
	DisclosureOfReclassificationsOrChangesInPresentationLineItems
	DescriptionOfNatureOfReclassificationOrChangesInPresentation
	AmountOfReclassificationsOrChangesInPresentation
	DescriptionOfReasonForReclassificationOrChangesInPresentation
	DescriptionOfReasonWhyReclassificationOfComparativeAmountsIsImpracticable
	DescriptionOfNatureOfNecessaryAdjustmentToProvideComparativeInformation
	DisclosureOfAmountsToBeRecoveredOrSettledAfterTwelveMonthsForClassesOfAssetsAndLiabilitiesThatContainAmountsToBeRecoveredOrSettledBothNoMoreAndMoreThanTwelveMonthsAfterReportingDateExplanatory
	DisclosureOfAmountsToBeRecoveredOrSettledAfterTwelveMonthsForClassesOfAssetsAndLiabilitiesThatContainAmountsToBeRecoveredOrSettledBothNoMoreAndMoreThanTwelveMonthsAfterReportingDateAbstract
	DisclosureOfAmountsToBeRecoveredOrSettledAfterTwelveMonthsForClassesOfAssetsAndLiabilitiesThatContainAmountsToBeRecoveredOrSettledBothNoMoreAndMoreThanTwelveMonthsAfterReportingDateTable
	MaturityAxis
	AggregatedTimeBandsMember
	NotLaterThanOneYearMember
	LaterThanOneYearMember
	DisclosureOfAmountsToBeRecoveredOrSettledAfterTwelveMonthsForClassesOfAssetsAndLiabilitiesThatContainAmountsToBeRecoveredOrSettledBothNoMoreAndMoreThanTwelveMonthsAfterReportingDateLineItems
	Inventories
	CurrentTradeReceivables
	TradeAndOtherCurrentPayablesToTradeSuppliers
	DisclosureOfSummaryOfSignificantAccountingPoliciesExplanatory
	ExplanationOfMeasurementBasesUsedInPreparingFinancialStatements
	DescriptionOfOtherAccountingPoliciesRelevantToUnderstandingOfFinancialStatements
	ExplanationOfManagementJudgementsInApplyingEntitysAccountingPoliciesWithSignificantEffectOnRecognisedAmounts
	ExplanationOfAssumptionAboutFutureWithSignificantRiskOfResultingInMaterialAdjustments
	DisclosureOfAssetsAndLiabilitiesWithSignificantRiskOfMaterialAdjustmentExplanatory
	DisclosureOfAssetsAndLiabilitiesWithSignificantRiskOfMaterialAdjustmentAbstract
	DisclosureOfAssetsAndLiabilitiesWithSignificantRiskOfMaterialAdjustmentTable
	AssetsAndLiabilitiesAxis
	AssetsAndLiabilitiesMember
	DisclosureOfAssetsAndLiabilitiesWithSignificantRiskOfMaterialAdjustmentLineItems
	DescriptionOfNatureOfAssetsWithSignificantRiskOfMaterialAdjustmentsWithinNextFinancialYear
	DescriptionOfNatureOfLiabilitiesWithSignificantRiskOfMaterialAdjustmentsWithinNextFinancialYear
	AssetsWithSignificantRiskOfMaterialAdjustmentsWithinNextFinancialYear
	LiabilitiesWithSignificantRiskOfMaterialAdjustmentsWithinNextFinancialYear
	DisclosureOfObjectivesPoliciesAndProcessesForManagingCapitalExplanatory
	DisclosureOfObjectivesPoliciesAndProcessesForManagingCapitalAbstract
	DisclosureOfObjectivesPoliciesAndProcessesForManagingCapitalTable
	CapitalRequirementsAxis
	CapitalRequirementsMember
	DisclosureOfObjectivesPoliciesAndProcessesForManagingCapitalLineItems
	QualitativeInformationAboutEntitysObjectivesPoliciesAndProcessesForManagingCapital
	SummaryOfQuantitativeDataAboutWhatEntityManagesAsCapital
	DescriptionOfChangesInEntitysObjectivesPoliciesAndProcessesForManagingCapitalAndWhatEntityManagesAsCapital
	InformationWhetherEntityCompliedWithAnyExternallyImposedCapitalRequirements
	InformationAboutConsequencesOfNoncomplianceWithExternallyImposedCapitalRequirements
	DividendsRecognisedAsDistributionsToOwnersPerShare
	DividendsProposedOrDeclaredBeforeFinancialStatementsAuthorisedForIssueButNotRecognisedAsDistributionToOwners
	DividendsProposedOrDeclaredBeforeFinancialStatementsAuthorisedForIssueButNotRecognisedAsDistributionToOwnersPerShare
	CumulativePreferenceDividendsNotRecognised
	DescriptionOfNatureOfNoncashAssetsHeldForDistributionToOwnersDeclaredBeforeFinancialStatementsAuthorisedForIssue
	NoncashAssetsDeclaredForDistributionToOwnersBeforeFinancialStatementsAuthorisedForIssue
	NoncashAssetsDeclaredForDistributionToOwnersBeforeFinancialStatementsAuthorisedForIssueAtFairValue
	DescriptionOfMethodsUsedToMeasureFairValueOfNoncashAssetsDeclaredForDistributionToOwnersBeforeFinancialStatementsAuthorisedForIssue
	DividendsPayable
	IncreaseDecreaseInDividendsPayableThroughChangeInFairValueOfNoncashAssetsHeldForDistributionToOwners
	EquityReclassifiedIntoFinancialLiabilities
	FinancialLiabilitiesReclassifiedIntoEquity
	DescriptionOfTimingAndReasonOfReclassificationBetweenFinancialLiabilitiesAndEquity
*/
	SELECT 	@IfrsDisclosureId, [Concept], [Value]
	FROM #IfrsDisclosureDetails;
	
	DROP TABLE #IfrsDisclosureDetails;
END