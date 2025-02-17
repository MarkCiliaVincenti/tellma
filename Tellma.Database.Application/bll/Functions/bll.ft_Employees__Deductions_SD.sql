﻿CREATE FUNCTION [bll].[ft_Employees__Deductions_SD](
	--@EmployeeIds dbo.IdList READONLY,
	--@LineIds dbo.IdList READONLY,
	@PeriodBenefitsEntries dbo.PeriodBenefitsList READONLY,
	@PeriodStart DATE,
	@PeriodEnd DATE
)
RETURNS @MyResult TABLE (
	[EmployeeId] INT,
	[SocialSecurityDeduction] DECIMAL (19, 6),
	[Zakaat] DECIMAL (19, 6),
	[EmployeeIncomeTax] DECIMAL (19, 6)
)
AS BEGIN
	IF @PeriodEnd < N'2022-04-01' RETURN;
	DECLARE @T TABLE (
		[EmployeeId] INT,
		[ResourceCode] NVARCHAR (50),
		[Value] DECIMAL (19, 6),
		[ValueSubjectToSocialSecurity] DECIMAL (19, 6),
		[ValueSubjectToZakaat] DECIMAL (19, 6),
		[ValueSubjectToEmployeeIncomeTax] DECIMAL (19, 6)
	);

	--INSERT INTO @T -- 
	--SELECT [EmployeeId], [ResourceCode], SUM([Value]), SUM([Value]), SUM([Value]), SUM([Value])
	--FROM bll.ft_Employees__MonthlyBenefits(@EmployeeIds, @LineIds, @PeriodStart, @PeriodEnd)
	--GROUP BY [EmployeeId], [ResourceCode]

	INSERT INTO @T
	SELECT [EmployeeId], [ResourceCode], SUM([Value]), SUM([Value]), SUM([Value]), SUM([Value])
	--FROM bll.ft_Employees__MonthlyBenefits(@EmployeeIds, @LineIds, @PeriodStart, @PeriodEnd)
	FROM @PeriodBenefitsEntries
	GROUP BY [EmployeeId], [ResourceCode]
	
	UPDATE @T
	SET
		[ValueSubjectToSocialSecurity] = 0
	WHERE [ResourceCode]  IN (N'EndOfService', N'SocialSecurityContribution');

	UPDATE @T
	SET [ValueSubjectToZakaat] = 0
	WHERE [ResourceCode] IN (N'EndOfService', N'SocialSecurityContribution', N'TransportationAllowance', N'MealAllowance');

	UPDATE @T
	SET [ValueSubjectToEmployeeIncomeTax] = 0
	WHERE [ResourceCode] IN (N'EndOfService', N'SocialSecurityContribution', N'IncomeTaxReimbursement',
		N'BookAllowance', N'DetectiveAllowance', N'ReadinessAllowance', N'EnvoyAllowance', N'SecurityAllowance');

--	The following formula, while faster, is not accurate.
--	UPDATE @T SET [ValueSubjectToEmployeeIncomeTax] = 0.95 * [ValueSubjectToEmployeeIncomeTax]
--  We can only exempt 5% is there is indeed NonExempt Allowances of more than 5% of Gross Salary
	UPDATE T
	SET  [ValueSubjectToEmployeeIncomeTax] =
		IIF(G.NonExemptAllowances >= 0.05 * [ValueGrossSalary],
			0.95 * [ValueSubjectToEmployeeIncomeTax],
			(1 - G.NonExemptAllowances / [ValueGrossSalary]))
	FROM @T T
	CROSS APPLY (
		SELECT SUM([Value]) AS [ValueGrossSalary],
		SUM(IIF([ResourceCode] = N'BasicSalary' OR [ValueSubjectToEmployeeIncomeTax] <> [Value], 0, [Value])) AS NonExemptAllowances
		FROM @T WHERE [EmployeeId] = T.[EmployeeId]
	) G
	WHERE [ValueSubjectToEmployeeIncomeTax] = [Value]

	INSERT INTO @MyResult
	SELECT DISTINCT [EmployeeId], 0, 0, 0
	FROM @T

	-- SS Deduction, assuming we recorded a contribution of 17%
	Update R
	SET [SocialSecurityDeduction] = 0.25 * SS.[TotalValueSubjectToSocialSecurity]
	FROM @MyResult R
	CROSS APPLY (
		SELECT SUM([ValueSubjectToSocialSecurity]) AS [TotalValueSubjectToSocialSecurity]
		FROM @T
		WHERE [EmployeeId] = R.[EmployeeId]
	) SS

	-- Zakaat Deduction
	DECLARE @BasicExpenditures DECIMAL (19, 4) = 215617, @ZakaatThreshold DECIMAL (19, 4) = 156129;

	Update R
	SET [Zakaat] = IIF(SS.[TotalValueSubjectToZakaat] - @BasicExpenditures >= @ZakaatThreshold,
					ROUND(0.025 * (SS.[TotalValueSubjectToZakaat] - @BasicExpenditures), 2), 0)
	FROM @MyResult R
	CROSS APPLY (
		SELECT SUM([ValueSubjectToZakaat]) AS [TotalValueSubjectToZakaat]
		FROM @T
		WHERE [EmployeeId] = R.[EmployeeId]
	) SS

	-- Income Tax Deduction
	Update R
	SET [EmployeeIncomeTax] = ROUND(
		CASE
			WHEN [TotalValueSubjectToEmployeeIncomeTax] >= 27000	THEN 0.20 * ([TotalValueSubjectToEmployeeIncomeTax] - 27000) + 3300
			WHEN [TotalValueSubjectToEmployeeIncomeTax] >= 7000		THEN 0.15 * ([TotalValueSubjectToEmployeeIncomeTax] - 7000) + 300
			WHEN [TotalValueSubjectToEmployeeIncomeTax] >= 5000		THEN 0.10 * ([TotalValueSubjectToEmployeeIncomeTax] - 5000) + 100
			WHEN [TotalValueSubjectToEmployeeIncomeTax] >= 3000		THEN 0.05 * ([TotalValueSubjectToEmployeeIncomeTax] - 3000)
			ELSE 0
		END, 2) - [Zakaat]
	FROM @MyResult R
	CROSS APPLY (
		SELECT SUM([ValueSubjectToEmployeeIncomeTax])  - SUM([ValueSubjectToSocialSecurity]) * 0.08	AS [TotalValueSubjectToEmployeeIncomeTax]
		FROM @T
		WHERE [EmployeeId] = R.[EmployeeId]
	) SS

	RETURN
END