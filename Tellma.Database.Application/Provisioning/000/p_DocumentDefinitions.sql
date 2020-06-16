﻿INSERT INTO @DocumentDefinitions([Index], [Code], [DocumentType], [Description], [TitleSingular], [TitlePlural],[Prefix], [MainMenuSection], [MainMenuSortKey]) VALUES
(0, N'ManualJournal',2, N'Manual lines only',N'Manual Journal Voucher', N'Manual Journal Vouchers', N'JV', N'Financials', 20),
(8, N'ClosingPeriodVoucher',2, N'PPE Depreciation, Intangible Amortization, Exchange Variance, Settling trade accounts',N'Closing Month Voucher', N'Closing Month Vouchers', N'CPV', N'Financials', 30),
(9, N'ClosingYearVoucher',2, N'Fiscal Close, Manual',N'Closing Year Voucher', N'Closing Year Vouchers', N'CYV', N'Financials', 40),

(10, N'PaymentIssueToNonTradingAgents',2, N'payment to partner, debtor, creditor, to other cash, to bank, to exchange, to other',N'Cash Payment Voucher', N'Cash Payment Vouchers', N'PIO', N'Cash', 20),
(11, N'DepositCashToBank',2, N'cash to bank (same currency), check to bank (same currency)',N'Cash Transfer/Exchange Voucher', N'Cash Transfer/Exchange Vouchers', N'CTE', N'Cash', 30),
(12, N'PaymentReceiptFromNonTradingAgents',2, N'payment from partner, debtor, creditor, other',N'Cash Receipt Voucher', N'Cash Receipt Vouchers', N'PRO', N'Cash', 50),

(20, N'StockIssueToNonTradingAgent',2, N'Stock issue to production/maintenance/job/Consumption/Reclassification',N'Stock Issue Voucher (NT)', N'Stock Issue Vouchers (NT)', N'MIO', N'Inventory', 20),
(21, N'StockTransfer',2, N'transfer between warehouses',N'Stock Transfer', N'Stock Transfers (NT)', N'MTV', N'Inventory', 30),
(22, N'StockReceiptFromNonTradingAgent',2, N'FG receipt from production, RM/production supplies return from production/maintenance/job/consumption/Reclassification',N'Stock Receipt Voucher (NT)', N'Stock Receipt Voucher (NT)', N'MRO', N'Inventory', 40),
(23, N'InventoryAdjustment',2, N'Shortage, Overage, impairment, reversal of impairment',N'Inventory Adjustment', N'Inventory Adjustments', N'MAV', N'Inventory', 50),

(30, N'PaymentIssueToTradePayable',2, N'payment to supplier, purchase invoice, stock/PPE/C/S receipt from supplier',N'Cash Payment (Supplier)', N'Cash Payments (Supplier)', N'PIS', N'Purchasing', 20),
(31, N'RefundFromTradePayable',2, N'refund from supplier, credit note (supplier), stock return to supplier, ppe return to supplier',N'Supplier Refund Voucher', N'Suppliers Refund Vouchers', N'PRS', N'Purchasing', 40),
(32, N'WithholdingTaxFromTradePayable',2, N'Witholding tax from suppliers/lessors',N'WT (Supplier)', N'WT (Suppliers)', N'WTS', N'Purchasing', 50),
(33, N'ImportFromTradePayable',2, N'Shipment In Transit, Payment, Commercial Invoice, Related Expenses',N'Import Shipment', N'Import Shipments', N'IRS', N'Purchasing', 60),
(34, N'GoodReceiptFromImport',2, N'goods receipt from import (PPE treated as stock till mise in use)',N'Good Receipt (Import)', N'Goods Receipts (Import)', N'GRI', N'Purchasing', 70),
(35, N'GoodServiceReceiptFromTradePayable',2, N'PPE/consumables/services/rental receipt from supplier, purchase invoice, debit note (supplier)',N'Good/Service Receipt (Purchase)', N'Goods/Services Receipts (Purchase)', N'GSRS', N'Purchasing', 80),

(40, N'PaymentReceiptFromTradeReceivable',2, N'payment from customer, sales invoice, Goods/Service issue to customer',N'Cash Receipt (Customer)', N'Cash Receipts (Customers)', N'PRC', N'Sales', 20),
(41, N'RefundToTradeReceivable',2, N'payment to customer, credit note (customer), stock receipt from customer',N'Customer Refund', N'Customer Refunds', N'PIC', N'Sales', 40),
(42, N'WithholdingTaxByTradeReceivable',2, N'Witholding tax by customers/lessees',N'WT (Customer)', N'WT (Customers)', N'WTC', N'Sales', 50),
(43, N'GoodIssueToExport',2, N'goods issue to export, payment, sales invoice, FOB destination',N'Export Shipment', N'Goods Issues (Exports)', N'GIE', N'Sales', 60),
(44, N'ExportToTradeReceivable',2, N'goods delivery from export',N'Goods Delivery (Export)', N'Goods Deliveries (Exports)', N'EIC', N'Sales', 70),
(45, N'GoodServiceIssueToTradeReceivable',2, N'stock/rental/service issue to customer, sales invoice, debit note (customer)',N'Good/Service Issue (Customer)', N'Goods/Services Issue (Customer)', N'GSIC', N'Sales', 80),

(50, N'SteelProduction',2, N'DM/DL/OH to WIP/Byproduct, DM/DL/OH + WIP to WIP/Byproduct, DM/DL/OH + WIP to FG/Byproduct',N'Steel Production Voucher', N'Steel Production Vouchers', N'PV1', N'Production', 20),
(51, N'PlasticProduction',2, N'',N'Plastic Production Voucher', N'Plastic Production Vouchers', N'PV2', N'Production', 30),
(52, N'PaintProduction',2, N'',N'Paint Production Voucher', N'Paint Production Vouchers', N'PV3', N'Production', 40),
(53, N'VehicleAssembly',2, N'',N'Vehicle Assembly Voucher', N'Vehicle Assembly Vouchers', N'PV4', N'Production', 50),
(54, N'GrainProcessing',2, N'',N'Grain Processing Voucher', N'Grain Processing Vouchers', N'PV5', N'Production', 60),
(55, N'OilMilling',2, N'',N'Oil Milling Voucher', N'Oil Milling Vouchers', N'PV6', N'Production', 70),

(69, N'Maintenance',2, N'DM/DL/OH to Job, then total allocated to machine',N'Internal Maintenance Job', N'Internal Maintenance Jobs', N'IMJ', N'Production', 80),

(70, N'PaymentIssueToEmployee',2, N'payment - employee benefits, payment - employee loan, salary, overtime, absence, deduction, due installments, Bonus',N'Cash Payment', N'Cash Payments', N'PIE', N'HumanCapital', 20),
(71, N'EmployeeLoan',2, N'salary advance, long term loan, loan installments',N'Employee Loan Voucher', N'', N'ELN', N'HumanCapital', 30),
(72, N'AttendanceRegister',2, N'arrivals, departures',N'Attendance Register', N'Attendance Register', N'SRE', N'HumanCapital', 40),
(73, N'EmployeeOvertime',2, N'Overtime (Employee)',N'Overtime', N'Overtime', N'ORE', N'HumanCapital', 50),
(74, N'EmployeePenalty',2, N'absence penalty, Other penalties',N'Penalty', N'Penalties', N'PTE', N'HumanCapital', 60),
(75, N'EmployeeReward',2, N'periodic bonus, special bonus',N'Reward', N'Rewards', N'RTE', N'HumanCapital', 70),
(76, N'EmployeeLeave',2, N'Paid leave, Unpaid leave, hourly leave',N'Leave', N'Leaves', N'LIE', N'HumanCapital', 80),
(77, N'EmployeeLeaveAllowance',2, N'Yearly Leave',N'Leave Allowance', N'Leave Allowances', N'LAE', N'HumanCapital', 90),
(78, N'EmployeeTravel',2, N'Per diem, Petty Cash, Fuel Allowance, ...',N'Travel', N'Travels', N'TIE', N'HumanCapital', 100);
INSERT @DocumentDefinitionLineDefinitions([Index], [HeaderIndex], [LineDefinitionId], [IsVisibleByDefault]) VALUES
(0,0, @ManualLineLD, 1),
(0,10, @CashPaymentToOtherLD, 1),
(4,10, @CashTransferExchangeLD, 1),
(0,11, @DepositCashToBankLD, 1),
(1,11, @DepositCheckToBankLD, 1),
(0,12, @CashReceiptFromOtherLD, 1),
(1,12, @CheckReceiptFromOtherInCashierLD, 1),
(0,30, @CashPaymentToTradePayableLD, 1),
(1,30, @InvoiceFromTradePayableLD, 1),
(2,30, @StockReceiptFromTradePayableLD, 1),
(3,30, @PPEReceiptFromTradePayableLD, 1),
(4,30, @ConsumableServiceReceiptFromTradePayableLD, 1),
(5,30, @RentalReceiptFromTradePayableLD, 1);


EXEC dal.DocumentDefinitions__Save
	@Entities = @DocumentDefinitions,
	@DocumentDefinitionLineDefinitions = @DocumentDefinitionLineDefinitions;
	
--Declarations
DECLARE @ManualJournalDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'ManualJournal')
DECLARE @ClosingPeriodVoucherDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'ClosingPeriodVoucher')
DECLARE @ClosingYearVoucherDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'ClosingYearVoucher')

DECLARE @PaymentIssueToNonTradingAgentsDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaymentIssueToNonTradingAgents')
DECLARE @DepositCashToBankDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'DepositCashToBank')
DECLARE @PaymentReceiptFromNonTradingAgentsDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaymentReceiptFromNonTradingAgents')

DECLARE @StockIssueToNonTradingAgentDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'StockIssueToNonTradingAgent')
DECLARE @StockTransferDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'StockTransfer')
DECLARE @StockReceiptFromNonTradingAgentDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'StockReceiptFromNonTradingAgent')
DECLARE @InventoryAdjustmentDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'InventoryAdjustment')

DECLARE @PaymentIssueToTradePayableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaymentIssueToTradePayable')
DECLARE @RefundFromTradePayableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'RefundFromTradePayable')
DECLARE @WithholdingTaxFromTradePayableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'WithholdingTaxFromTradePayable')
DECLARE @ImportFromTradePayableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'ImportFromTradePayable')
DECLARE @GoodReceiptFromImportDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'GoodReceiptFromImport')
DECLARE @GoodServiceReceiptFromTradePayableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'GoodServiceReceiptFromTradePayable')

DECLARE @PaymentReceiptFromTradeReceivableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaymentReceiptFromTradeReceivable')
DECLARE @RefundToTradeReceivableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'RefundToTradeReceivable')
DECLARE @WithholdingTaxByTradeReceivableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'WithholdingTaxByTradeReceivable')
DECLARE @GoodIssueToExportDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'GoodIssueToExport')
DECLARE @ExportToTradeReceivableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'ExportToTradeReceivable')
DECLARE @GoodServiceIssueToTradeReceivableDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'GoodServiceIssueToTradeReceivable')

DECLARE @SteelProductionDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'SteelProduction')
DECLARE @PlasticProductionDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PlasticProduction')
DECLARE @PaintProductionDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaintProduction')
DECLARE @VehicleAssemblyDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'VehicleAssembly')
DECLARE @GrainProcessingDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'GrainProcessing')
DECLARE @OilMillingDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'OilMilling')

DECLARE @MaintenanceDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'Maintenance')

DECLARE @PaymentIssueToEmployeeDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'PaymentIssueToEmployee')
DECLARE @EmployeeLoanDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeLoan')
DECLARE @AttendanceRegisterDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'AttendanceRegister')
DECLARE @EmployeeOvertimeDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeOvertime')
DECLARE @EmployeePenaltyDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeePenalty')
DECLARE @EmployeeRewardDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeReward')
DECLARE @EmployeeLeaveDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeLeave')
DECLARE @EmployeeLeaveAllowanceDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeLeaveAllowance')
DECLARE @EmployeeTravelDD INT = (SELECT [Id] FROM dbo.DocumentDefinitions WHERE [Code] = N'EmployeeTravel')