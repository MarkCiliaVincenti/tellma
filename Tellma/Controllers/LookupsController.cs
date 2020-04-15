﻿using Tellma.Controllers.Dto;
using Tellma.Controllers.Utilities;
using Tellma.Data;
using Tellma.Data.Queries;
using Tellma.Entities;
using Tellma.Services.MultiTenancy;
using Tellma.Services.Utilities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;

namespace Tellma.Controllers
{
    [Route("api/" + BASE_ADDRESS + "{definitionId}")]
    [ApplicationController]
    public class LookupsController : CrudControllerBase<LookupForSave, Lookup, int>
    {
        public const string BASE_ADDRESS = "lookups/";

        private readonly ILogger _logger;
        private readonly IStringLocalizer _localizer;
        private readonly ApplicationRepository _repo;
        private readonly IDefinitionsCache _definitionsCache;

        private string DefinitionId => RouteData.Values["definitionId"]?.ToString() ?? 
            throw new BadRequestException("URI must be of the form 'api/lookups/{definitionId}'");

        private LookupDefinitionForClient Definition() => _definitionsCache.GetCurrentDefinitionsIfCached()?.Data?.Lookups?
            .GetValueOrDefault(DefinitionId) ?? throw new InvalidOperationException($"Definition for '{DefinitionId}' was missing from the cache");

        private string View => $"{BASE_ADDRESS}{DefinitionId}";

        public LookupsController(
            ILogger<LookupsController> logger,
            IStringLocalizer<Strings> localizer,
            ApplicationRepository repo,
            IDefinitionsCache definitionsCache) : base(logger, localizer)
        {
            _logger = logger;
            _localizer = localizer;
            _repo = repo;
            _definitionsCache = definitionsCache;
        }

        [HttpPut("activate")]
        public async Task<ActionResult<EntitiesResponse<Lookup>>> Activate([FromBody] List<int> ids, [FromQuery] ActivateArguments args)
        {
            return await ControllerUtilities.InvokeActionImpl(() => ActivateImpl(ids: ids, args, isActive: true), _logger);
        }

        [HttpPut("deactivate")]
        public async Task<ActionResult<EntitiesResponse<Lookup>>> Deactivate([FromBody] List<int> ids, [FromQuery] DeactivateArguments args)
        {
            return await ControllerUtilities.InvokeActionImpl(() => ActivateImpl(ids: ids, args, isActive: false), _logger);
        }

        private async Task<ActionResult<EntitiesResponse<Lookup>>> ActivateImpl(List<int> ids, ActionArguments args, bool isActive)
        {
            // Check user permissions
            await CheckActionPermissions("IsActive", ids);

            // Execute and return
            using var trx = ControllerUtilities.CreateTransaction();
            await _repo.Lookups__Activate(ids, isActive);

            if (args.ReturnEntities ?? false)
            {
                var response = await LoadDataByIdsAndTransform(ids, args);

                trx.Complete();
                return Ok(response);
            }
            else
            {
                trx.Complete();
                return Ok();
            }
        }

        protected override async Task<IEnumerable<AbstractPermission>> UserPermissions(string action, CancellationToken cancellation)
        {
            return await _repo.UserPermissions(action, View, cancellation);
        }

        protected override IRepository GetRepository()
        {
            string filter = $"{nameof(Lookup.DefinitionId)} eq '{DefinitionId}'";
            return new FilteredRepository<Lookup>(_repo, filter);
        }

        protected override Query<Lookup> Search(Query<Lookup> query, GetArguments args, IEnumerable<AbstractPermission> filteredPermissions)
        {
            string search = args.Search;
            if (!string.IsNullOrWhiteSpace(search))
            {
                search = search.Replace("'", "''"); // escape quotes by repeating them

                var name = nameof(Lookup.Name);
                var name2 = nameof(Lookup.Name2);
                var name3 = nameof(Lookup.Name3);
                var code = nameof(Lookup.Code);

                var filterString = $"{name} {Ops.contains} '{search}' or {name2} {Ops.contains} '{search}' or {name3} {Ops.contains} '{search}' or {code} {Ops.contains} '{search}'";
                query = query.Filter(FilterExpression.Parse(filterString));
            }

            return query;
        }

        protected override async Task SaveValidateAsync(List<LookupForSave> entities)
        {
            // SQL validation
            int remainingErrorCount = ModelState.MaxAllowedErrors - ModelState.ErrorCount;
            var sqlErrors = await _repo.Lookups_Validate__Save(DefinitionId, entities, top: remainingErrorCount);

            // Add errors to model state
            ModelState.AddLocalizedErrors(sqlErrors, _localizer);
        }

        protected override async Task<List<int>> SaveExecuteAsync(List<LookupForSave> entities, bool returnIds)
        {
            return await _repo.Lookups__Save(DefinitionId, entities, returnIds: returnIds);
        }

        protected override async Task DeleteValidateAsync(List<int> ids)
        {
            // SQL validation
            int remainingErrorCount = ModelState.MaxAllowedErrors - ModelState.ErrorCount;
            var sqlErrors = await _repo.Lookups_Validate__Delete(DefinitionId, ids, top: remainingErrorCount);

            // Add errors to model state
            ModelState.AddLocalizedErrors(sqlErrors, _localizer);
        }

        protected override async Task DeleteExecuteAsync(List<int> ids)
        {
            try
            {
                await _repo.Lookups__Delete(ids);
            }
            catch (ForeignKeyViolationException)
            {
                // TODO: test
                var definition = Definition();
                var tenantInfo = await _repo.GetTenantInfoAsync(cancellation: default);
                var titleSingular = tenantInfo.Localize(definition.TitleSingular, definition.TitleSingular2, definition.TitleSingular3);

                throw new BadRequestException(_localizer["Error_CannotDelete0AlreadyInUse", titleSingular]);
            }
        }

        protected override OrderByExpression DefaultOrderBy()
        {
            return OrderByExpression.Parse("SortKey,Id desc");
        }
    }
}
