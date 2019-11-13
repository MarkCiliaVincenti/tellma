﻿using System.Collections.Generic;

namespace BSharp.Controllers.Dto
{
    /// <summary>
    /// A structure that stores all definitions of a particular database
    /// </summary>
    public class DefinitionsForClient
    {
        /// <summary>
        /// Mapping from document definition Id to document definition
        /// </summary>
        public Dictionary<string, DocumentDefinitionForClient> Documents { get; set; }

        /// <summary>
        /// Mapping from line type Id to line type
        /// </summary>
        public Dictionary<string, LineTypeForClient> Lines { get; set; }

        /// <summary>
        /// Mapping from resource definition Id to resource definition
        /// </summary>
        public Dictionary<string, ResourceDefinitionForClient> Resources { get; set; }

        /// <summary>
        /// Mapping from resource definition Id to resource definition
        /// </summary>
        public Dictionary<string, AccountDefinitionForClient> Accounts { get; set; }

        /// <summary>
        /// Mapping from lookup definition Id to lookup definition
        /// </summary>
        public Dictionary<string, LookupDefinitionForClient> Lookups { get; set; }

        /// <summary>
        /// Mapping from report definition Id to lookup definition
        /// </summary>
        public Dictionary<string, ReportDefinitionForClient> Reports { get; set; }
    }

    public abstract class DefinitionForClient
    {
        public string MainMenuSection { get; set; }
        public string MainMenuIcon { get; set; }
        public decimal MainMenuSortKey { get; set; }
    }

    public abstract class MasterDetailDefinitionForClient : DefinitionForClient
    {
        public string TitleSingular { get; set; }
        public string TitleSingular2 { get; set; }
        public string TitleSingular3 { get; set; }
        public string TitlePlural { get; set; }
        public string TitlePlural2 { get; set; }
        public string TitlePlural3 { get; set; }
    }

    public class ReportDefinitionForClient : DefinitionForClient
    {
        public string Title { get; set; }
        public string Title2 { get; set; }
        public string Title3 { get; set; }
        public string Description { get; set; }
        public string Description2 { get; set; }
        public string Description3 { get; set; }
        public string Type { get; set; } // "Summary" or "Details"
        public string DefaultView { get; set; }
        public string Collection { get; set; }
        public string DefinitionId { get; set; }
        public List<ReportParameterDefinition> Parameters { get; set; }
        public string Filter { get; set; } // On drill down for summary
        public string OrderBy { get; set; } // On drill down for summary
        public List<ReportSelectDefinition> Select { get; set; }
        public List<ReportDimensionDefinition> Rows { get; set; }
        public List<ReportDimensionDefinition> Columns { get; set; }
        public List<ReportMeasureDefinition> Measures { get; set; }
        public int Top { get; set; }
        public bool ShowColumnsTotal { get; set; }
        public bool ShowRowsTotal { get; set; }
    }

    public class ReportParameterDefinition
    {
        public string Key { get; set; }
        public string Label { get; set; }
        public string Label2 { get; set; }
        public string Label3 { get; set; }
        public bool IsRequired { get; set; }
    }
    
    public class ReportSelectDefinition
    {
        public string Path { get; set; }
        public string Label { get; set; }
        public string Label2 { get; set; }
        public string Label3 { get; set; }
    }

    public class ReportDimensionDefinition
    {
        public string Path { get; set; }
        public string Label { get; set; }
        public string Label2 { get; set; }
        public string Label3 { get; set; }
        public string OrderDirection { get; set; }
        public bool AutoExpand { get; set; }
    }

    public class ReportMeasureDefinition
    {
        public string Path { get; set; }
        public string Label { get; set; }
        public string Label2 { get; set; }
        public string Label3 { get; set; }
        public string OrderDirection { get; set; }
        public string Aggregation { get; set; }
    }

    public class DocumentDefinitionForClient : MasterDetailDefinitionForClient
    {
        // TODO
        public bool IsSourceDocument { get; internal set; }
        public string FinalState { get; internal set; }
    }

    public class LineTypeForClient // related entity for document definition
    {
        // TODO
    }

    public class AccountDefinitionForClient : MasterDetailDefinitionForClient
    {
        public string ResponsibilityCenter_Label { get; set; }
        public string ResponsibilityCenter_Label2 { get; set; }
        public string ResponsibilityCenter_Label3 { get; set; }
        public string ResponsibilityCenter_Visibility { get; set; }
        public int? ResponsibilityCenter_DefaultValue { get; set; }

        public string Custodian_Label { get; set; }
        public string Custodian_Label2 { get; set; }
        public string Custodian_Label3 { get; set; }
        public string Custodian_Visibility { get; set; }
        public int? Custodian_DefaultValue { get; set; }

        public string Resource_Label { get; set; }
        public string Resource_Label2 { get; set; }
        public string Resource_Label3 { get; set; }
        public string Resource_Visibility { get; set; }
        public int? Resource_DefaultValue { get; set; }
        public string Resource_DefinitionList { get; set; }

        public string Location_Label { get; set; }
        public string Location_Label2 { get; set; }
        public string Location_Label3 { get; set; }
        public string Location_Visibility { get; set; }
        public int? Location_DefaultValue { get; set; }
        public string Location_DefinitionList { get; set; }

        public string PartyReference_Label { get; set; }
        public string PartyReference_Label2 { get; set; }
        public string PartyReference_Label3 { get; set; }
        public string PartyReference_Visibility { get; set; }
    }

    public class ResourceDefinitionForClient : MasterDetailDefinitionForClient
    {
        public string MassUnit_Label { get; set; }
        public string MassUnit_Label2 { get; set; }
        public string MassUnit_Label3 { get; set; }
        public byte MassUnit_Visibility { get; set; }
        public int? MassUnit_DefaultValue { get; set; }


        public string VolumeUnit_Label { get; set; }
        public string VolumeUnit_Label2 { get; set; }
        public string VolumeUnit_Label3 { get; set; }
        public byte VolumeUnit_Visibility { get; set; }
        public int? VolumeUnit_DefaultValue { get; set; }


        public string AreaUnit_Label { get; set; }
        public string AreaUnit_Label2 { get; set; }
        public string AreaUnit_Label3 { get; set; }
        public byte AreaUnit_Visibility { get; set; }
        public int? AreaUnit_DefaultValue { get; set; }


        public string LengthUnit_Label { get; set; }
        public string LengthUnit_Label2 { get; set; }
        public string LengthUnit_Label3 { get; set; }
        public byte LengthUnit_Visibility { get; set; }
        public int? LengthUnit_DefaultValue { get; set; }


        public string TimeUnit_Label { get; set; }
        public string TimeUnit_Label2 { get; set; }
        public string TimeUnit_Label3 { get; set; }
        public byte TimeUnit_Visibility { get; set; }
        public int? TimeUnit_DefaultValue { get; set; }


        public string CountUnit_Label { get; set; }
        public string CountUnit_Label2 { get; set; }
        public string CountUnit_Label3 { get; set; }
        public byte CountUnit_Visibility { get; set; }
        public int? CountUnit_DefaultValue { get; set; }


        public string Memo_Label { get; set; }
        public string Memo_Label2 { get; set; }
        public string Memo_Label3 { get; set; }
        public byte Memo_Visibility { get; set; }
        public string Memo_DefaultValue { get; set; }

        public string CustomsReference_Label { get; set; }
        public string CustomsReference_Label2 { get; set; }
        public string CustomsReference_Label3 { get; set; }
        public byte CustomsReference_Visibility { get; set; }
        public string CustomsReference_DefaultValue { get; set; }


        // Resource Lookup 1
        public string ResourceLookup1_Label { get; set; }
        public string ResourceLookup1_Label2 { get; set; }
        public string ResourceLookup1_Label3 { get; set; }
        public byte ResourceLookup1_Visibility { get; set; } // 0, 1, 2 (not visible, visible, visible and required)
        public int? ResourceLookup1_DefaultValue { get; set; }
        public string ResourceLookup1_DefinitionId { get; set; }

        // Resource Lookup 2
        public string ResourceLookup2_Label { get; set; }
        public string ResourceLookup2_Label2 { get; set; }
        public string ResourceLookup2_Label3 { get; set; }
        public byte ResourceLookup2_Visibility { get; set; }
        public int? ResourceLookup2_DefaultValue { get; set; }
        public string ResourceLookup2_DefinitionId { get; set; }

        // Resource Lookup 3
        public string ResourceLookup3_Label { get; set; }
        public string ResourceLookup3_Label2 { get; set; }
        public string ResourceLookup3_Label3 { get; set; }
        public byte ResourceLookup3_Visibility { get; set; }
        public int? ResourceLookup3_DefaultValue { get; set; }
        public string ResourceLookup3_DefinitionId { get; set; }

        // Resource Lookup 4
        public string ResourceLookup4_Label { get; set; }
        public string ResourceLookup4_Label2 { get; set; }
        public string ResourceLookup4_Label3 { get; set; }
        public byte ResourceLookup4_Visibility { get; set; }
        public int? ResourceLookup4_DefaultValue { get; set; }
        public string ResourceLookup4_DefinitionId { get; set; }
    }

    public class LookupDefinitionForClient : MasterDetailDefinitionForClient
    {

    }

    public static class Visibility
    {
        public const byte Hidden = 0;
        public const byte Visible = 1;
        public const byte Required = 2;
    }

    public static class AccountVisibility
    {
        public const string None = nameof(None);
        public const string RequiredInAccounts = nameof(RequiredInAccounts);
        public const string RequiredInEntries = nameof(RequiredInEntries);
        public const string OptionalInEntries = nameof(OptionalInEntries);
    }

    public static class ReportType
    {
        public const string Summary = nameof(Summary);
        public const string Details = nameof(Details);
    }

    public static class ReportOrderDirection
    {
        public const string Asc = "asc";
        public const string Desc = "desc";

    }
}
