﻿using BSharp.Controllers.Dto;
using BSharp.Controllers.Misc;
using BSharp.Data;
using BSharp.Data.Queries;
using BSharp.EntityModel;
using BSharp.Services.ImportExport;
using BSharp.Services.Utilities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Transactions;

namespace BSharp.Controllers
{
    [Route("api/measurement-units")]
    [ApplicationApi]
    public class MeasurementUnitsController : CrudControllerBase<MeasurementUnitForSave, MeasurementUnit, int>
    {
        private readonly IModelMetadataProvider _metadataProvider;
        private readonly ILogger _logger;
        private readonly IStringLocalizer _localizer;
        private readonly ApplicationRepository _repo;

        private string VIEW => "measurement-units";

        public MeasurementUnitsController(
            ILogger<MeasurementUnitsController> logger,
            IStringLocalizer<Strings> localizer,
            ApplicationRepository repo,
            IModelMetadataProvider metadataProvider) : base(logger, localizer)
        {
            _logger = logger;
            _localizer = localizer;
            _repo = repo;
            _metadataProvider = metadataProvider;
        }

        [HttpPut("activate")]
        public async Task<ActionResult<EntitiesResponse<MeasurementUnit>>> Activate([FromBody] List<int> ids, [FromQuery] ActivateArguments args)
        {
            bool returnEntities = args.ReturnEntities ?? false;

            return await ControllerUtilities.InvokeActionImpl(() =>
                Activate(ids: ids,
                    returnEntities: returnEntities,
                    expand: args.Expand,
                    isActive: true)
            , _logger);
        }

        [HttpPut("deactivate")]
        public async Task<ActionResult<EntitiesResponse<MeasurementUnit>>> Deactivate([FromBody] List<int> ids, [FromQuery] DeactivateArguments args)
        {
            bool returnEntities = args.ReturnEntities ?? false;

            return await ControllerUtilities.InvokeActionImpl(() =>
                Activate(ids: ids,
                    returnEntities: returnEntities,
                    expand: args.Expand,
                    isActive: false)
            , _logger);
        }

        private async Task<ActionResult<EntitiesResponse<MeasurementUnit>>> Activate([FromBody] List<int> ids, bool returnEntities, string expand, bool isActive)
        {
            // Parse parameters
            var expandExp = ExpandExpression.Parse(expand);
            var idsArray = ids.ToArray();

            // Check user permissions
            await CheckActionPermissions("IsActive", idsArray);

            // Execute and return
            using (var trx = ControllerUtilities.CreateTransaction())
            {
                await _repo.MeasurementUnits__Activate(ids, isActive);

                if (returnEntities)
                {
                    var response = await GetByIdListAsync(idsArray, expandExp);

                    trx.Complete();
                    return Ok(response);
                }
                else
                {
                    trx.Complete();
                    return Ok();
                }
            }
        }

        protected override async Task<IEnumerable<AbstractPermission>> UserPermissions(string action)
        {
            return await _repo.UserPermissions(action, VIEW);
        }

        protected override IRepository GetRepository()
        {
            return _repo;
        }

        protected override Query<MeasurementUnit> Search(Query<MeasurementUnit> query, GetArguments args, IEnumerable<AbstractPermission> filteredPermissions)
        {
            string search = args.Search;
            if (!string.IsNullOrWhiteSpace(search))
            {
                search = search.Replace("'", "''"); // escape quotes by repeating them

                var name = nameof(MeasurementUnit.Name);
                var name2 = nameof(MeasurementUnit.Name2);
                var name3 = nameof(MeasurementUnit.Name3);
                var code = nameof(MeasurementUnit.Code);

                var filterString = $"{name} {Ops.contains} '{search}' or {name2} {Ops.contains} '{search}' or {name3} {Ops.contains} '{search}' or {code} {Ops.contains} '{search}'";
                query = query.Filter(FilterExpression.Parse(filterString));
            }

            return query;
        }

        protected override async Task SaveValidateAsync(List<MeasurementUnitForSave> entities)
        {
            // Check that codes are not duplicated within the arriving collection
            var duplicateCodes = entities.Where(e => e.Code != null).GroupBy(e => e.Code).Where(g => g.Count() > 1);
            if (duplicateCodes.Any())
            {
                // Hash the entities' indices for performance
                Dictionary<MeasurementUnitForSave, int> indices = entities.ToIndexDictionary();

                foreach (var groupWithDuplicateCodes in duplicateCodes)
                {
                    foreach (var entity in groupWithDuplicateCodes)
                    {
                        // This error indicates a bug
                        var index = indices[entity];
                        ModelState.AddModelError($"[{index}].Id", _localizer["Error_TheCode0IsDuplicated", entity.Code]);
                    }
                }
            }

            // No need to invoke SQL if the model state is full of errors
            if (ModelState.HasReachedMaxErrors)
            {
                return;
            }

            // SQL validation
            int remainingErrorCount = ModelState.MaxAllowedErrors - ModelState.ErrorCount;
            var sqlErrors = await _repo.MeasurementUnits_Validate__Save(entities, top: remainingErrorCount);

            // Add errors to model state
            ModelState.AddLocalizedErrors(sqlErrors, _localizer);
        }

        protected override async Task<List<int>> SaveExecuteAsync(List<MeasurementUnitForSave> entities, ExpandExpression expand, bool returnIds)
        {
            return await _repo.MeasurementUnits__Save(entities, returnIds: returnIds);
        }

        protected override async Task DeleteValidateAsync(List<int> ids)
        {
            // SQL validation
            int remainingErrorCount = ModelState.MaxAllowedErrors - ModelState.ErrorCount;
            var sqlErrors = await _repo.MeasurementUnits_Validate__Delete(ids, top: remainingErrorCount);

            // Add errors to model state
            ModelState.AddLocalizedErrors(sqlErrors, _localizer);
        }

        protected override async Task DeleteExecuteAsync(List<int> ids)
        {
            try
            {
                await _repo.MeasurementUnits__Delete(ids);
            }
            catch (ForeignKeyViolationException)
            {
                throw new BadRequestException(_localizer["Error_CannotDelete0AlreadyInUse", _localizer["MeasurementUnit"]]);
            }
        }

        protected override Query<MeasurementUnit> GetAsQuery(List<MeasurementUnitForSave> entities)
        {
            return _repo.MeasurementUnits__AsQuery(entities);
        }
    }
}
