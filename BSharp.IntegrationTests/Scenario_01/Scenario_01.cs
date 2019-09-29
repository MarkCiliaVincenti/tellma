﻿using BSharp.Controllers.Dto;
using BSharp.Entities;
using BSharp.IntegrationTests.Utilities;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Xunit;
using Xunit.Abstractions;

// To order the tests, as per https://bit.ly/2lFONcE
[assembly: TestCollectionOrderer(TestCollectionOrderer.TypeName, TestCollectionOrderer.AssemblyName)]
[assembly: CollectionBehavior(DisableTestParallelization = true)]

namespace BSharp.IntegrationTests.Scenario_01
{
    [Collection(nameof(Scenario_01))]
    [TestCaseOrderer(TestCaseOrderer.TypeName, TestCaseOrderer.AssemblyName)]
    public abstract class Scenario_01
    {
        /// <summary>
        /// The <see cref="HttpClient"/> used by all test methods
        /// </summary>
        protected HttpClient Client { set; get; }

        /// <summary>
        /// A dictionary-like collection shared across test methods
        /// </summary>
        protected SharedCollection Shared { set; get; }

        /// <summary>
        /// Output for the test methods to do some logging
        /// </summary>
        protected ITestOutputHelper Output { set; get; }

        public Scenario_01(Scenario_01_WebApplicationFactory factory, ITestOutputHelper output)
        {
            Client = factory.GetClient();
            Shared = factory.GetSharedCollection();
            Output = output;
        }

        protected async Task GrantPermissionToSecurityAdministrator(string viewId, string level, string criteria)
        {
            // Query the API for the Id that was just returned from the Save
            var response = await Client.GetAsync($"/api/roles/{1}?expand=Permissions,Members/Agent");
            // Output.WriteLine(await response.Content.ReadAsStringAsync());
            var getByIdResponse = await response.Content.ReadAsAsync<GetByIdResponse<Role>>();
            var role = getByIdResponse.Result;

            role.Permissions.Add(new Permission
            {
                ViewId = viewId,
                Action = level,
                Criteria = criteria
            });

            var dtosForSave = new List<Role> { role };
            var postResponse = await Client.PostAsJsonAsync($"/api/roles?expand=Permissions,Members/Agent", dtosForSave);
            Output.WriteLine(await postResponse.Content.ReadAsStringAsync());
        }
    }
}
