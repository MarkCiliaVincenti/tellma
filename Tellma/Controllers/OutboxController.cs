﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Controllers.Dto;
using Tellma.Data;
using Tellma.Data.Queries;
using Tellma.Entities;

namespace Tellma.Controllers
{
    [Route("api/" + BASE_ADDRESS)]
    [ApplicationController(allowUnobtrusive: true)]
    public class OutboxController : FactWithIdControllerBase<OutboxRecord, int>
    {
        public const string BASE_ADDRESS = "outbox";

        private readonly OutboxService _service;

        public OutboxController(OutboxService service, ILogger<OutboxController> logger) : base(logger)
        {
            _service = service;
        }

        protected override FactWithIdServiceBase<OutboxRecord, int> GetFactWithIdService()
        {
            return _service;
        }
    }

    public class OutboxService : FactWithIdServiceBase<OutboxRecord, int>
    {
        private readonly ApplicationRepository _repo;

        public OutboxService(ApplicationRepository repo, IStringLocalizer<Strings> localizer) : base(localizer)
        {
            _repo = repo;
        }

        protected override OrderByExpression DefaultOrderBy()
        {
            return OrderByExpression.Parse("CreatedAt desc");
        }

        protected override IRepository GetRepository()
        {
            return _repo;
        }

        protected override Query<OutboxRecord> Search(Query<OutboxRecord> query, GetArguments args, IEnumerable<AbstractPermission> filteredPermissions)
        {
            string search = args.Search;
            if (!string.IsNullOrWhiteSpace(search))
            {
                search = search.Replace("'", "''"); // escape quotes by repeating them

                var assigneeProp = nameof(OutboxRecord.Assignee);
                var nameProp = $"{assigneeProp}/{nameof(User.Name)}";
                var name2Prop = $"{assigneeProp}/{nameof(User.Name2)}";
                var name3Prop = $"{assigneeProp}/{nameof(User.Name3)}";

                var commentProp = nameof(OutboxRecord.Comment);
                var memoProp = $"{nameof(OutboxRecord.Document)}/{nameof(Document.Memo)}";

                // Prepare the filter string
                var filterString = $"{nameProp} {Ops.contains} '{search}' or {name2Prop} {Ops.contains} '{search}' or {name3Prop} {Ops.contains} '{search}' or {commentProp} {Ops.contains} '{search}' or {memoProp} {Ops.contains} '{search}'";

                // Apply the filter
                query = query.Filter(FilterExpression.Parse(filterString));
            }

            return query;
        }

        protected override Task<IEnumerable<AbstractPermission>> UserPermissions(string action, CancellationToken cancellation)
        {
            // Outbox is always filtered per user
            IEnumerable<AbstractPermission> permissions = new List<AbstractPermission> {
                new AbstractPermission
                {
                     View = "-", // Not important
                     Action = "Read"
                }
            };

            return Task.FromResult(permissions);
        }
    }
}
