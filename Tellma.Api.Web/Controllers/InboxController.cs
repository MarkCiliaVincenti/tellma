﻿using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Controllers.Utilities;
using Tellma.Model.Application;

namespace Tellma.Controllers
{
    [Route("api/inbox")]
    [ApplicationController]
    public class InboxController : FactWithIdControllerBase<InboxRecord, int>
    {
        private readonly InboxService _service;

        public InboxController(InboxService service, IServiceProvider sp) : base(sp)
        {
            _service = service;
        }

        [HttpPut("check")]
        public async Task<ActionResult> CheckInbox([FromBody] DateTimeOffset now)
        {
            return await ControllerUtilities.InvokeActionImpl(async () =>
            {
                await _service.CheckInbox(now);
                return Ok();
            }
            , _logger);
        }

        protected override FactWithIdServiceBase<InboxRecord, int> GetFactWithIdService()
        {
            return _service;
        }
    }
}
