﻿using Tellma.Controllers.Dto;
using Tellma.Data;
using Tellma.Entities;
using Tellma.Services.ApiAuthentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace Tellma.Controllers
{
    [Route("api/definitions")]
    [AuthorizeAccess]
    [ApplicationApi]
    [ApiController]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public class DefinitionsController : ControllerBase
    {
        // Private fields

        private readonly IDefinitionsCache _definitionsCache;
        private readonly ILogger<SettingsController> _logger;

        public DefinitionsController(IDefinitionsCache definitionsCache,
            ILogger<SettingsController> logger)
        {
            _definitionsCache = definitionsCache;
            _logger = logger;
        }

        [HttpGet("client")]
        public ActionResult<DataWithVersion<DefinitionsForClient>> DefinitionsForClient()
        {
            try
            {
                // Simply retrieves the cached definitions, which were refreshed by ApiController
                var result = _definitionsCache.GetCurrentDefinitionsIfCached();
                if (result == null)
                {
                    throw new InvalidOperationException("The definitions were missing from the cache");
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message} {ex.StackTrace}");
                return BadRequest(ex.Message);
            }
        }

        private static string MapVisibility(string visibility)
        {
            if (visibility == Visibility.None)
            {
                return null;
            }

            return visibility;
        }

        private static LookupDefinitionForClient MapLookupDefinition(LookupDefinition def)
        {
            return new LookupDefinitionForClient
            {
                MainMenuIcon = def.MainMenuIcon,
                MainMenuSortKey = def.MainMenuSortKey ?? 0m,
                MainMenuSection = def.MainMenuSection,
                TitlePlural = def.TitlePlural,
                TitlePlural2 = def.TitlePlural2,
                TitlePlural3 = def.TitlePlural3,
                TitleSingular = def.TitleSingular,
                TitleSingular2 = def.TitleSingular2,
                TitleSingular3 = def.TitleSingular3,
            };
        }

        private static AgentDefinitionForClient MapAgentDefinition(AgentDefinition def)
        {
            return new AgentDefinitionForClient
            {
                MainMenuIcon = def.MainMenuIcon,
                MainMenuSortKey = def.MainMenuSortKey ?? 0m,
                MainMenuSection = def.MainMenuSection,
                TitlePlural = def.TitlePlural,
                TitlePlural2 = def.TitlePlural2,
                TitlePlural3 = def.TitlePlural3,
                TitleSingular = def.TitleSingular,
                TitleSingular2 = def.TitleSingular2,
                TitleSingular3 = def.TitleSingular3,

                TaxIdentificationNumberVisibility = MapVisibility(def.TaxIdentificationNumberVisibility),
                ImageVisibility = MapVisibility(def.ImageVisibility),
                StartDateVisibility = MapVisibility(def.StartDateVisibility),
                StartDateLabel = def.StartDateLabel,
                StartDateLabel2 = def.StartDateLabel2,
                StartDateLabel3 = def.StartDateLabel3,
                JobVisibility = MapVisibility(def.JobVisibility),
                RatesVisibility = MapVisibility(def.RatesVisibility),
                RatesLabel = def.RatesLabel,
                RatesLabel2 = def.RatesLabel2,
                RatesLabel3 = def.RatesLabel3,
                BankAccountNumberVisibility = MapVisibility(def.BankAccountNumberVisibility),

            };
        }

        private static ResourceDefinitionForClient MapResourceDefinition(ResourceDefinition def)
        {
            return new ResourceDefinitionForClient
            {
                MainMenuIcon = def.MainMenuIcon,
                MainMenuSortKey = def.MainMenuSortKey ?? 0m,
                MainMenuSection = def.MainMenuSection,
                TitlePlural = def.TitlePlural,
                TitlePlural2 = def.TitlePlural2,
                TitlePlural3 = def.TitlePlural3,
                TitleSingular = def.TitleSingular,
                TitleSingular2 = def.TitleSingular2,
                TitleSingular3 = def.TitleSingular3,

                IdentifierLabel = def.IdentifierLabel,
                IdentifierLabel2 = def.IdentifierLabel2,
                IdentifierLabel3 = def.IdentifierLabel3,
                IdentifierVisibility = MapVisibility(def.IdentifierVisibility),
                CurrencyVisibility = MapVisibility(def.CurrencyVisibility),
                DescriptionVisibility = MapVisibility(def.DescriptionVisibility),
                CostObjectVisibility = MapVisibility(def.CostObjectVisibility),
                ExpenseEntryTypeVisibility = MapVisibility(def.ExpenseEntryTypeVisibility),
                ExpenseCenterVisibility = MapVisibility(def.ExpenseCenterVisibility),
                InvestmentCenterVisibility = MapVisibility(def.InvestmentCenterVisibility),
                ResidualMonetaryValueVisibility = MapVisibility(def.ResidualMonetaryValueVisibility),
                ResidualValueVisibility = MapVisibility(def.ResidualValueVisibility),
                ReorderLevelVisibility = MapVisibility(def.ReorderLevelVisibility),
                EconomicOrderQuantityVisibility = MapVisibility(def.EconomicOrderQuantityVisibility),
                AvailableSinceLabel = def.AvailableSinceLabel,
                AvailableSinceLabel2 = def.AvailableSinceLabel2,
                AvailableSinceLabel3 = def.AvailableSinceLabel3,
                AvailableSinceVisibility = MapVisibility(def.AvailableSinceVisibility),
                AvailableTillLabel = def.AvailableTillLabel,
                AvailableTillLabel2 = def.AvailableTillLabel2,
                AvailableTillLabel3 = def.AvailableTillLabel3,
                AvailableTillVisibility = MapVisibility(def.AvailableTillVisibility),

                Decimal1Label = def.Decimal1Label,
                Decimal1Label2 = def.Decimal1Label2,
                Decimal1Label3 = def.Decimal1Label3,
                Decimal1Visibility = MapVisibility(def.Decimal1Visibility),

                Decimal2Label = def.Decimal2Label,
                Decimal2Label2 = def.Decimal2Label2,
                Decimal2Label3 = def.Decimal2Label3,
                Decimal2Visibility = MapVisibility(def.Decimal2Visibility),

                Int1Label = def.Int1Label,
                Int1Label2 = def.Int1Label2,
                Int1Label3 = def.Int1Label3,
                Int1Visibility = MapVisibility(def.Int1Visibility),

                Int2Label = def.Int2Label,
                Int2Label2 = def.Int2Label2,
                Int2Label3 = def.Int2Label3,
                Int2Visibility = MapVisibility(def.Int2Visibility),

                Lookup1Label = def.Lookup1Label,
                Lookup1Label2 = def.Lookup1Label2,
                Lookup1Label3 = def.Lookup1Label3,
                Lookup1Visibility = MapVisibility(def.Lookup1Visibility),
                Lookup1DefinitionId = def.Lookup1DefinitionId,

                Lookup2Label = def.Lookup2Label,
                Lookup2Label2 = def.Lookup2Label2,
                Lookup2Label3 = def.Lookup2Label3,
                Lookup2Visibility = MapVisibility(def.Lookup2Visibility),
                Lookup2DefinitionId = def.Lookup2DefinitionId,

                Lookup3Label = def.Lookup3Label,
                Lookup3Label2 = def.Lookup3Label2,
                Lookup3Label3 = def.Lookup3Label3,
                Lookup3Visibility = MapVisibility(def.Lookup3Visibility),
                Lookup3DefinitionId = def.Lookup3DefinitionId,

                Lookup4Label = def.Lookup4Label,
                Lookup4Label2 = def.Lookup4Label2,
                Lookup4Label3 = def.Lookup4Label3,
                Lookup4Visibility = MapVisibility(def.Lookup4Visibility),
                Lookup4DefinitionId = def.Lookup4DefinitionId,

                DueDateLabel = def.DueDateLabel,
                DueDateLabel2 = def.DueDateLabel2,
                DueDateLabel3 = def.DueDateLabel3,
                DueDateVisibility = MapVisibility(def.DueDateVisibility),

                Text1Label = def.Text1Label,
                Text1Label2 = def.Text1Label2,
                Text1Label3 = def.Text1Label3,
                Text1Visibility = MapVisibility(def.Text1Visibility),

                Text2Label = def.Text2Label,
                Text2Label2 = def.Text2Label2,
                Text2Label3 = def.Text2Label3,
                Text2Visibility = MapVisibility(def.Text2Visibility),
            };
        }

        private static ReportDefinitionForClient MapReportDefinition(ReportDefinition def)
        {
            return new ReportDefinitionForClient
            {
                // Basics
                Collection = def.Collection,
                DefinitionId = def.DefinitionId,
                Type = def.Type,

                // Data
                Rows = def.Rows?.Select(r => new ReportDimensionDefinitionForClient
                {
                    Path = r.Path,
                    Label = r.Label,
                    Label2 = r.Label2,
                    Label3 = r.Label3,
                    AutoExpand = r.AutoExpand ?? false,
                    Modifier = r.Modifier,
                    OrderDirection = r.OrderDirection,
                }).ToList(),
                ShowRowsTotal = def.ShowRowsTotal ?? false,

                Columns = def.Columns?.Select(c => new ReportDimensionDefinitionForClient
                {
                    Path = c.Path,
                    Label = c.Label,
                    Label2 = c.Label2,
                    Label3 = c.Label3,
                    AutoExpand = c.AutoExpand ?? false,
                    Modifier = c.Modifier,
                    OrderDirection = c.OrderDirection,
                }).ToList(),
                ShowColumnsTotal = def.ShowColumnsTotal ?? false,

                Measures = def.Measures?.Select(m => new ReportMeasureDefinitionForClient
                {
                    Path = m.Path,
                    Label = m.Label,
                    Label2 = m.Label2,
                    Label3 = m.Label3,
                    OrderDirection = m.OrderDirection,
                    Aggregation = m.Aggregation,
                }).ToList(),

                Select = def.Select?.Select(s => new ReportSelectDefinitionForClient
                {
                    Path = s.Path,
                    Label = s.Label,
                    Label2 = s.Label2,
                    Label3 = s.Label3,
                }).ToList(),

                OrderBy = def.OrderBy,
                Top = def.Top ?? 0,

                // Filter
                Filter = def.Filter,
                Parameters = def.Parameters?.Select(p => new ReportParameterDefinitionForClient
                {
                    Key = p.Key,
                    Label = p.Label,
                    Label2 = p.Label2,
                    Label3 = p.Label3,
                    Visibility = p.Visibility,
                    Value = p.Value,
                }).ToList(),

                // Chart
                Chart = def.Chart,
                DefaultsToChart = def.DefaultsToChart ?? false,

                // Title
                Title = def.Title,
                Title2 = def.Title2,
                Title3 = def.Title3,
                Description = def.Description,
                Description2 = def.Description2,
                Description3 = def.Description3,

                // Main Menu
                ShowInMainMenu = def.ShowInMainMenu ?? false,
                MainMenuIcon = def.MainMenuIcon,
                MainMenuSortKey = def.MainMenuSortKey ?? 0m,
                MainMenuSection = def.MainMenuSection,
            };
        }

        private static LineDefinitionForClient MapLineDefinition(LineDefinition def)
        {
            return new LineDefinitionForClient
            {
                TitlePlural = def.TitlePlural,
                TitlePlural2 = def.TitlePlural2,
                TitlePlural3 = def.TitlePlural3,
                TitleSingular = def.TitleSingular,
                TitleSingular2 = def.TitleSingular2,
                TitleSingular3 = def.TitleSingular3,

                AllowSelectiveSigning = def.AllowSelectiveSigning ?? false,
                ViewDefaultsToForm = def.ViewDefaultsToForm ?? false,
                Entries = def.Entries?.Select(e => new LineDefinitionEntryForClient
                {
                    Direction = e.Direction.Value,
                    AccountTypeParentId = e.AccountTypeParentId,
                    AgentDefinitionId = e.AgentDefinitionId,
                    NotedAgentDefinitionId = e.NotedAgentDefinitionId,
                    EntryTypeId = e.EntryTypeId,
                    AccountTypeParentIsResourceClassification = e.AccountTypeParentIsResourceClassification ?? false,
                    EntryTypeParentId = e.EntryTypeParentId
                })?.ToList(),

                Columns = def.Columns?.Select(c => new LineDefinitionColumnForClient
                {
                    TableName = c.TableName,
                    ColumnName = c.ColumnName,
                    EntryIndex = c.EntryIndex.Value,
                    Label = c.Label,
                    Label2 = c.Label2,
                    Label3 = c.Label3,
                    ReadOnlyState = c.ReadOnlyState,
                    RequiredState = c.RequiredState,
                    InheritsFromHeader = c.InheritsFromHeader == false ? null : c.InheritsFromHeader
                })?.ToList(),

                StateReasons = def.StateReasons?.Select(r => new LineDefinitionStateReasonForClient
                {
                    Id = r.Id,
                    State = r.State,
                    Name = r.Name,
                    Name2 = r.Name2,
                    Name3 = r.Name3,
                    IsActive = r.IsActive ?? false,
                })?.ToList(),
            };
        }

        private static DocumentDefinitionForClient MapDocumentDefinition(DocumentDefinition def, Dictionary<string, LineDefinitionForClient> lineDefsDic)
        {
            var result = new DocumentDefinitionForClient
            {
                IsOriginalDocument = def.IsOriginalDocument ?? false,
                TitlePlural = def.TitlePlural,
                TitlePlural2 = def.TitlePlural2,
                TitlePlural3 = def.TitlePlural3,
                TitleSingular = def.TitleSingular,
                TitleSingular2 = def.TitleSingular2,
                TitleSingular3 = def.TitleSingular3,
                Prefix = def.Prefix,
                CodeWidth = def.CodeWidth ?? 4,

                MemoVisibility = def.MemoVisibility,
                ClearanceVisibility = MapVisibility(def.ClearanceVisibility),

                CanReachState1 = def.CanReachState1 ?? false,
                CanReachState2 = def.CanReachState2 ?? false,
                CanReachState3 = def.CanReachState3 ?? false,
                HasWorkflow = def.HasWorkflow ?? false,

                LineDefinitions = def.LineDefinitions?.Select(d => new DocumentDefinitionLineDefinitionForClient
                {
                    LineDefinitionId = d.LineDefinitionId,
                    IsVisibleByDefault = d.IsVisibleByDefault ?? false
                }).ToList(),

                MainMenuIcon = def.MainMenuIcon,
                MainMenuSortKey = def.MainMenuSortKey ?? 0m,
                MainMenuSection = def.MainMenuSection,
            };

            // Here we compute some values based on the associated line definitions
            var documentLineDefinitions = result.LineDefinitions
                .Select(e => lineDefsDic.GetValueOrDefault(e.LineDefinitionId))
                .Where(e => e != null);

            // AgentId
            foreach (var lineDef in documentLineDefinitions)
            {
                foreach (var colDef in lineDef.Columns.Where(c => c.InheritsFromHeader ?? false))
                {
                    if (colDef.TableName == "Lines" && colDef.ColumnName == nameof(Line.Memo))
                    {
                        result.MemoIsCommonVisibility = true;
                        if (string.IsNullOrWhiteSpace(result.MemoLabel))
                        {
                            result.MemoLabel = colDef.Label;
                            result.MemoLabel2 = colDef.Label2;
                            result.MemoLabel3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.MemoRequiredState ?? 5))
                        {
                            result.MemoRequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.MemoReadOnlyState ?? 5))
                        {
                            result.MemoReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Agents
                    if (colDef.EntryIndex < lineDef.Entries.Count)
                    {
                        var entryDef = lineDef.Entries[colDef.EntryIndex];

                        // DebitAgent
                        if (colDef.ColumnName == nameof(Entry.AgentId) && entryDef.Direction == 1)
                        {
                            result.DebitAgentVisibility = true;
                            if (string.IsNullOrWhiteSpace(result.DebitAgentLabel))
                            {
                                result.DebitAgentLabel ??= colDef.Label;
                                result.DebitAgentLabel2 ??= colDef.Label2;
                                result.DebitAgentLabel3 ??= colDef.Label3;
                            }

                            if (string.IsNullOrWhiteSpace(result.DebitAgentDefinitionId))
                            {
                                result.DebitAgentDefinitionId = entryDef.AgentDefinitionId;
                            }

                            if (colDef.RequiredState < (result.DebitAgentRequiredState ?? 5))
                            {
                                result.DebitAgentRequiredState = colDef.RequiredState;
                            }

                            if (colDef.ReadOnlyState < (result.DebitAgentReadOnlyState ?? 5))
                            {
                                result.DebitAgentReadOnlyState = colDef.ReadOnlyState;
                            }
                        }

                        // CreditAgent
                        if (colDef.ColumnName == nameof(Entry.AgentId) && entryDef.Direction == -1)
                        {
                            result.CreditAgentVisibility = true;
                            if (string.IsNullOrWhiteSpace(result.CreditAgentLabel))
                            {
                                result.CreditAgentLabel = colDef.Label;
                                result.CreditAgentLabel2 = colDef.Label2;
                                result.CreditAgentLabel3 = colDef.Label3;
                            }

                            if (string.IsNullOrWhiteSpace(result.CreditAgentDefinitionId))
                            {
                                result.CreditAgentDefinitionId = entryDef.AgentDefinitionId;
                            }

                            if (colDef.RequiredState < (result.CreditAgentRequiredState ?? 5))
                            {
                                result.CreditAgentRequiredState = colDef.RequiredState;
                            }

                            if (colDef.ReadOnlyState < (result.CreditAgentReadOnlyState ?? 5))
                            {
                                result.CreditAgentReadOnlyState = colDef.ReadOnlyState;
                            }
                        }

                        // NotedAgent
                        if (colDef.ColumnName == nameof(Entry.NotedAgentId))
                        {
                            result.NotedAgentVisibility = true;
                            if (string.IsNullOrWhiteSpace(result.NotedAgentLabel))
                            {
                                result.NotedAgentLabel = colDef.Label;
                                result.NotedAgentLabel2 = colDef.Label2;
                                result.NotedAgentLabel3 = colDef.Label3;
                            }

                            if (string.IsNullOrWhiteSpace(result.NotedAgentDefinitionId))
                            {
                                result.NotedAgentDefinitionId = entryDef.NotedAgentDefinitionId;
                            }

                            if (colDef.RequiredState < (result.NotedAgentRequiredState ?? 5))
                            {
                                result.NotedAgentRequiredState = colDef.RequiredState;
                            }

                            if (colDef.ReadOnlyState < (result.NotedAgentReadOnlyState ?? 5))
                            {
                                result.NotedAgentReadOnlyState = colDef.ReadOnlyState;
                            }
                        }
                    }

                    // InvestmentCenter
                    if (colDef.ColumnName == nameof(Entry.CenterId))
                    {
                        result.InvestmentCenterVisibility = true;
                        if (string.IsNullOrWhiteSpace(result.InvestmentCenterLabel))
                        {
                            result.InvestmentCenterLabel = colDef.Label;
                            result.InvestmentCenterLabel2 = colDef.Label2;
                            result.InvestmentCenterLabel3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.InvestmentCenterRequiredState ?? 5))
                        {
                            result.InvestmentCenterRequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.InvestmentCenterReadOnlyState ?? 5))
                        {
                            result.InvestmentCenterReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Time1
                    if (colDef.ColumnName == nameof(Entry.Time1))
                    {
                        result.Time1Visibility = true;
                        if (string.IsNullOrWhiteSpace(result.Time1Label))
                        {
                            result.Time1Label = colDef.Label;
                            result.Time1Label2 = colDef.Label2;
                            result.Time1Label3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.Time1RequiredState ?? 5))
                        {
                            result.Time1RequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.Time1ReadOnlyState ?? 5))
                        {
                            result.Time1ReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Time2
                    if (colDef.ColumnName == nameof(Entry.Time2))
                    {
                        result.Time2Visibility = true;
                        if (string.IsNullOrWhiteSpace(result.Time2Label))
                        {
                            result.Time2Label = colDef.Label;
                            result.Time2Label2 = colDef.Label2;
                            result.Time2Label3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.Time2RequiredState ?? 5))
                        {
                            result.Time2RequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.Time2ReadOnlyState ?? 5))
                        {
                            result.Time2ReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Quantity
                    if (colDef.ColumnName == nameof(Entry.Quantity))
                    {
                        result.QuantityVisibility = true;
                        if (string.IsNullOrWhiteSpace(result.QuantityLabel))
                        {
                            result.QuantityLabel = colDef.Label;
                            result.QuantityLabel2 = colDef.Label2;
                            result.QuantityLabel3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.QuantityRequiredState ?? 5))
                        {
                            result.QuantityRequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.QuantityReadOnlyState ?? 5))
                        {
                            result.QuantityReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Unit
                    if (colDef.ColumnName == nameof(Entry.UnitId))
                    {
                        result.UnitVisibility = true;
                        if (string.IsNullOrWhiteSpace(result.UnitLabel))
                        {
                            result.UnitLabel = colDef.Label;
                            result.UnitLabel2 = colDef.Label2;
                            result.UnitLabel3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.UnitRequiredState ?? 5))
                        {
                            result.UnitRequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.UnitReadOnlyState ?? 5))
                        {
                            result.UnitReadOnlyState = colDef.ReadOnlyState;
                        }
                    }

                    // Currency
                    if (colDef.ColumnName == nameof(Entry.CurrencyId))
                    {
                        result.CurrencyVisibility = true;
                        if (string.IsNullOrWhiteSpace(result.CurrencyLabel))
                        {
                            result.CurrencyLabel = colDef.Label;
                            result.CurrencyLabel2 = colDef.Label2;
                            result.CurrencyLabel3 = colDef.Label3;
                        }
                        if (colDef.RequiredState < (result.CurrencyRequiredState ?? 5))
                        {
                            result.CurrencyRequiredState = colDef.RequiredState;
                        }

                        if (colDef.ReadOnlyState < (result.CurrencyReadOnlyState ?? 5))
                        {
                            result.CurrencyReadOnlyState = colDef.ReadOnlyState;
                        }
                    }
                }
            }

            return result;
        }

        public static async Task<DataWithVersion<DefinitionsForClient>> LoadDefinitionsForClient(ApplicationRepository repo)
        {
            var (version, lookupDefs, agentDefs, resourceDefs, reportDefs, docDefs, lineDefs) = await repo.Definitions__Load();

            var lineDefsDictionary = lineDefs.ToDictionary(e => e.Id, e => e);

            var result = new DefinitionsForClient
            {
                Lookups = lookupDefs.ToDictionary(def => def.Id, def => MapLookupDefinition(def)),
                Agents = agentDefs.ToDictionary(def => def.Id, def => MapAgentDefinition(def)),
                Resources = resourceDefs.ToDictionary(def => def.Id, def => MapResourceDefinition(def)),
                Reports = reportDefs.ToDictionary(def => def.Id, def => MapReportDefinition(def)),
                Lines = lineDefs.ToDictionary(def => def.Id, def => MapLineDefinition(def)),
            };
            result.Documents = docDefs.ToDictionary(def => def.Id, def => MapDocumentDefinition(def, result.Lines));

            // REturn result
            return new DataWithVersion<DefinitionsForClient>
            {
                Data = result,
                Version = version.ToString()
            };
        }
    }
}
