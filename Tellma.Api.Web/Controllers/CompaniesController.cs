﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Dto;
using Tellma.Controllers.Utilities;
using Tellma.Services.ApiAuthentication;

namespace Tellma.Controllers
{
    [Route("api/companies")]
    [ApiController]
    [AuthorizeJwtBearer]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public class CompaniesController : ControllerBase
    {
        private readonly CompaniesService _service;

        public CompaniesController(CompaniesService service)
        {
            _service = service;
        }

        [HttpGet("client")]
        public async Task<ActionResult<CompaniesForClient>> CompaniesForClient(CancellationToken cancellation)
        {
            var result = await _service.GetForClient(cancellation);
            return Ok(result);
        }
    }
}
