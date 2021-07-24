﻿using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Controllers.Dto;
using Tellma.Controllers.Utilities;
using Tellma.Model.Application;

namespace Tellma.Controllers
{
    [Route("api/markup-templates")]
    [ApplicationController]
    public class MarkupTemplatesController : CrudControllerBase<MarkupTemplateForSave, MarkupTemplate, int>
    {
        private readonly MarkupTemplatesService _service;

        public MarkupTemplatesController(MarkupTemplatesService service, IServiceProvider sp) : base(sp)
        {
            _service = service;
        }

        [HttpPut("preview-by-filter")]
        public async Task<ActionResult<MarkupPreviewResponse>> PreviewByFilter([FromBody] MarkupPreviewTemplate entity, [FromQuery] GenerateMarkupByFilterArguments<object> args, CancellationToken cancellation)
        {
            return await ControllerUtilities.InvokeActionImpl(async () =>
            {
                var (body, downloadName) = await _service.PreviewByFilter(entity, args, cancellation);

                // Prepare and return the response
                var response = new MarkupPreviewResponse
                {
                    Body = body,
                    DownloadName = downloadName
                };

                return Ok(response);
            },
            _logger);
        }

        [HttpPut("preview-by-id/{id}")]
        public async Task<ActionResult<MarkupPreviewResponse>> PreviewById([FromRoute] string id, [FromBody] MarkupPreviewTemplate entity, [FromQuery] GenerateMarkupByIdArguments args, CancellationToken cancellation)
        {
            return await ControllerUtilities.InvokeActionImpl(async () =>
            {
                var (body, downloadName) = await _service.PreviewById(id, entity, args, cancellation);

                // Prepare and return the response
                var response = new MarkupPreviewResponse
                {
                    Body = body,
                    DownloadName = downloadName
                };

                return Ok(response);
            },
            _logger);
        }

        [HttpPut("preview")]
        public async Task<ActionResult<MarkupPreviewResponse>> Preview([FromBody] MarkupPreviewTemplate entity, [FromQuery] GenerateMarkupArguments args, CancellationToken cancellation)
        {
            return await ControllerUtilities.InvokeActionImpl(async () =>
            {
                var (body, downloadName) = await _service.Preview(entity, args, cancellation);

                // Prepare and return the response
                var response = new MarkupPreviewResponse
                {
                    Body = body,
                    DownloadName = downloadName
                };

                return Ok(response);
            },
            _logger);
        }

        protected override CrudServiceBase<MarkupTemplateForSave, MarkupTemplate, int> GetCrudService()
        {
            return _service;
        }
    }
}
