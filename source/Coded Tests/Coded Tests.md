---
title: Coded Tests
lang: en
toc-title: Contents
pagetitle: Coded Tests
---

[logic_logo]: image/Logic_icon.png
[system_logo]: image/System_icon.png
[documentation_logo]: image/Documentation_icon.png
[acceptance_logo]: image/Acceptance_icon.png
[tdd_logo]: image/TDD_icon.png

>"A test is a way of demonstrating that something is
important. It shows you care." [Kevlin Henney]

# Theory

## Testing pyramid

![Test Pyramid](image/testPyramid.png "Test Pyramid")

Mike Cohn's original test pyramid consists of three layers that a test suite should consist of (bottom to top):

- Unit Tests
- Service Tests
- User Interface Tests

From a modern point of view the test pyramid seems overly simplistic and can therefore be misleading. Due to the test pyramid's simplicity the essence of the **test pyramid serves as a good rule of thumb** when it comes to establishing a test suite [[The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)]:

- Write tests with different granularity;
- The more high-level you get the fewer tests you should have.

![New Test Pyramid](image/newTestPyramid.png "New Test Pyramid")

## Write the tests you need

If a higher-level test gives you more confidence that your application works correctly, you should have it [[The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)].

Writing a unit test for a Controller class helps to test the logic within the Controller itself. This test won't tell you whether the controller's REST endpoint responds to HTTP requests. You move up the test pyramid and add a test that checks for exactly that - but nothing more [[The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)].

You don't test all the conditional logic and edge cases that your lower-level tests already cover in the higher-level test again. Make sure that the higher-level test focuses on the part that the lower-level tests couldn't cover [[The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)].

![Test Level](image/Test_level.svg)

## How big is a unit

A unit test is a piece of code that invokes a unit of work and checks one specific end result of that unit of work. If the assumptions on the end result turn out to be wrong, the unit test has failed. A unit test's scope can span as little as a method or as much as multiple classes. [[The art of unit testing](https://livebook.manning.com/book/the-art-of-unit-testing-second-edition/chapter-1/24)]

## Code coverage

>"Test coverage is a useful tool for finding untested parts of a codebase. Test coverage is of little use as a numeric statement of how good your tests are." [Martin Fowler]

Test coverage should only be used to find untested code. Code coverage cannot show if code is tested but only that it is not tested. Just because code is executed by a test (code is reported as covered) does not mean it is checked by a test.

![Code coverage](image/CodeCoverage.png "Code coverage")

# Test Suit

Here are four common goals of tests:

- I want to show the logic is correct.
- I want to show the system works.
- I want to show how to use this.
- I want to show this completes the user story.

## Logic Proof

<font size="+2"><span style="color:green"> ![logic logo][logic_logo] **I want to show the logic is correct.**</span></font>

When trying to prove logic correct you should:

### Only execute the logic

Mock all other code. The mocks should contain as little code as possible. You don't want to tests Mock logic.

### Check all possible inputs

You should check the logic against all possible input values.

If the input space is to big to run tests on all possible inputs, random testing is sufficient when we tests smaller units of code.

> Partition testing (code path testing) is typically a bit better at uncovering failures; however, the difference is reversed by a modest increase in the number of points chosen for random testing. Roughly, by taking 20% more points in a random test, any advantage a partition test might have enjoyed is wiped out  [Richard Hamlet. "Random Testing". In: Encyclopedia of Software Engineering. Wiley, 1994, pp. 970–978.].

### Don't test to close to the code

You should use public entry points to execute logic. Do not break encapsulation to test a specific method. Tests should not break when you refactor your code.

## System Test

<font size="+2"><span style="color:green"> ![system logo][system_logo] **I want to show the system works.**</span></font>

The system test is intended to show that te parts of the software works together. Execute as little as possible to test the system.

You should have tests of different granularity laying on different places on the testing pyramid.

When you want to show that an API endpoint responds with the correct error when an invalid parameter is passed to it you don't need to instantiate a database (lower on the testing pyramid). When you want to show that the endpoint returns the correct value for a specific input value you probably want to instantiate the database and retrieve the value from the database (higher on the pyramid).

## Documentation Test

<font size="+2"><span style="color:green"> ![documentation logo][documentation_logo] **I want to show how to use this.**</span></font>

The test is intended to be executable documentation. This test should be accompanied by allot of comments explaining what the test is doing. It could help using visual studio extensions that allow for more elaborate comments, ([Rich Comments](https://docs.devexpress.com/CodeRushForRoslyn/120417/visualization-tools/rich-comments)).

This can be a way of keeping documentation aligned with the code.

Don't hide setup in methods for reusability. The purpose of these tests are not to create good code, but to explain what a user should do when using our code.

## Acceptance Test

<font size="+2"><span style="color:green"> ![acceptance logo][acceptance_logo] **I want to show this completes the user story.**</span></font>

This test is meant to show that the user story is implemented. The test can be less general.
The tests can be associated with the story and used as regression.

## All together now

One test can be used as a system test, documentation test, and acceptance test. System tests, Acceptance tests, and Documentation tests can be as complex as you need. Logic proof tests must be kept as simple as possible.

![Test Suit Pyramid](image/TestSuitPyramid.svg "Test Suit Pyramid")

![Test Ven diagram](image/Testing_vendigram.svg "Test Ven diagram")

### Logic proof test

There are two methods of generating input:

1. We can generate all possible inputs using xUnit Theory with MemberData:

```csharp
[Theory]
[MemberData(nameof(GeneratePackageTestSpace))]
public async Task PackagesController_GetPackage_Prove_Logic(
    GetPackage_request request,
    GetPackage_environment environment)
{
    var repositoryFactory = new MockRepositoryFactory()
    {
        PackageFileRepository = new MockPackageFileRepository()
        {
            // We want to keep the mock logic as simple as possible.
            // When the GetPackageFile method is called this function
            // is executed.
            GetPackageFileAction = (fileName, storeId)
                => environment.Contains_package
                    ? new MemoryStream()
                    : null
            // We don't populate the stream with a package because
            // the GetPackage method does not interact with the package.
        },
        //...
    };

    //... Setup code

    // Execute the method
    var result = await controller.GetPackage(
        storeId: s_package.Store_id,
        name: s_package.Name,
        packageVersion: s_package.Version);

    // Specification
    if (request.Accept == "application/zip" && !environment.Contains_package)
    {
        Assert.IsType<BadRequestObjectResult>(result);
    }
    else if(request.Accept == "application/zip" && environment.Contains_package)
    {
        Assert.IsType<FileStreamResult>(result);
    }
    else if(request.Accept == "application/json" && !environment.Contains_package)
    {
        Assert.IsType<BadRequestObjectResult>(result);  
    }
    else if (request.Accept == "application/json" && environment.Contains_package)
    {
        Assert.IsType<OkObjectResult>(result);
    }
    else
    {
        // If the result does not fall into one these categories
        // we also want the test to fail.
        throw new Exception("not specified");
    }
}
```

We generate the inputs:

```csharp
public static IEnumerable<object[]> GeneratePackageTestSpace()
{
    var requests =
        (
            from media_type in new[] { "application/json", "application/zip" }
            select new GetPackage_request(accept: media_type)
        );

    var environments =
        (
            from contains_package in new bool[] { true, false }
            select new GetPackage_environment(contains_package)
        );

    // We combine the inputs and return an enumerable of lists on objects
    var space =
        from request in requests
        from environment in environments
        select new object[]
        {
            request,
            environment
        };

    return space;
}
```

2. You can generate random inputs using FsCheck with xUnit.

```csharp
[Property(Arbitrary = new[] { typeof(Invalid_name) }, MaxTest = 300)]
public void Invalid_names(Name invalid)
{
    var validator = new RequirePackageNameAttribute();
    var result = validator.IsValid((string)invalid);

    Assert.False(result);
}
```

```csharp
// The critical part of using FsCheck is generating the random inputs
public static class Invalid_name
{
    public static Arbitrary<Name> Invalid_name_generator()
    {
        return
            Arb
            .Generate<string>()
            .Select(str => (Name)str)
            .ToArbitrary()
            .Filter(name => // Here we filter out valid names.
                string.IsNullOrWhiteSpace((string)name)
                || !Regex.IsMatch((string)name, @"^[a-zA-Z0-9_]+$"));
    }
}
```

### System, Documentation & Acceptance Test

When creating a System, Documentation, and Acceptance tests readability is more impotent. We add a description/explanation, in a comment, as a preamble to the test

We reduce the amount of mock code in the tests by replacing it with read code as we build the codebase.

From ***V1*** to ***V2***:

***V1***: This is the first version and we don't yet have a database so we have to mock the ```PackageFileRepository``` and ```PackageRepositor```.

```csharp
// To get the package information and not the package zip you must set the "Accept" header
// to "application/json".
[Fact]
public async Task When_I_get_an_existing_package_with_the_correct_input()
{
    /// ARRANGE
    (string name, string version, string definition) package =
        (
            name: "app1",
            version: "1.1.1",
            definition:
@"{
""$schema"": ""https://k2central.com/schemas/1.0.0/package"",
""name"": ""app1"",
""version"" : ""1.1.1"",
""status"": 0,
""items"": { }
}"      );

    var factory = new CustomWebApplicationFactory<Startup>();

    // We mock the dependencies.
    var packageFileRepository = new MockPackageFileRepository();
    packageFileRepository.Files.Add(
        (TestingEnvironment.StoreId, $"{package.name}-{package.version}"),
        CreatePackageZip(package.definition, new string[] { })
    );
    factory.RepositoryFactory.PackageFileRepository = packageFileRepository;

    var packageRepository = new MockPackageRepository();
    packageRepository.Packages.Add(
        (
            TestingEnvironment.StoreId,
            new PackageDTO(package.name, package.version, false)
        )
    );
    factory.RepositoryFactory.PackageRepository = packageRepository;

    var client = factory.CreateHttpClient(CertificateScope.Platform, CertificatePermisson.Contributor);

    /// ACT
    var request = new HttpRequestMessage(
        HttpMethod.Get,
        // The get package url: /api/v1/stores/{store id}/packages/{App name}/versions/{App version}
        $"/api/v1/stores/{TestingEnvironment.StoreId}/packages/{package.name}/versions/{package.version}");

    // return the package information as a JSON string
    request.Headers.Add("Accept", "application/json");

    var response = await
        client
        .SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead,
            default);

    /// VERIFY
    // If the app exists a 200 status should be returned.
    Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);

    /// ...
}
```

***V2***: This is a later version and don't have to mock the dependencies. We do have to populate the database with test data.

```csharp
// To get the package information and not the package zip you must set the "Accept" header
// to "application/json".
[Fact]
public async Task When_I_get_an_existing_package_using_the_correct_input()
{
    /// ARRANGE
    (Guid tenantId, Guid storeId, string name, string version, string definition) app =
        (
            tenantId: Guid.Parse("3AA93FB0-BFC7-40D2-9436-F5102EB4D6F8"),
            storeId: Guid.Parse("D68B3E18-EA5C-40D0-A153-1AFD4940C225"),
            name: "app1",
            version: "1.1.1",
            definition:
@"{
""$schema"": ""https://k2central.com/schemas/1.0.0/package"",
""name"": ""app1"",
""version"" : ""1.1.1"",
""status"": 0,
""items"": { }
}");

    var factory = new CustomWebApplicationFactory<Startup>();

    // We don't have a PackageFileRepository so we sill have to mock it. 
    var packageFileRepository = new MockPackageFileRepository();
    packageFileRepository.Files.Add(
        (TestingEnvironment.StoreId, $"{app.name}-{app.version}"),
        CreatePackageZip(app.definition, new string[] { })
    );
    factory.RepositoryFactory.PackageFileRepository = packageFileRepository;

    // We do have a database and we instantiate it in memory.
    // We remove the mock and replace it with an instance of PackageRepository.
    var context =
        new StoreContext(
            new DbContextOptionsBuilder<StoreContext>()
                .UseInMemoryDatabase(
                    databaseName: $"TestDBPackage {Guid.NewGuid()}")
                .Options);

    var packageRepository = new PackageRepository(context, Create_mapper());
    factory.RepositoryFactory.PackageRepository = packageRepository;

    context.Stores.Add(
        new SourceCode.AppStore.Repository.Store(
            "MyStore",
            app.tenantId,
            app.storeId));
    context.Repositories.Add(
        new Repository(
            app.name,
            Guid.NewGuid(),
            DateTime.Parse("2020-01-20 10:20:15"),
            DateTime.Parse("2020-01-20 10:20:15"),
            app.storeId));
    context.SaveChanges();

    var repoId =
        context
        .Repositories
        .Where(rep => rep.Name == app.name && rep.StoreID == app.storeId)
        .First()
        .Id;

    context.Packages.Add(
        new Package(
            app.version,
            Guid.NewGuid(),
            DateTime.Parse("2020-01-20 10:20:15"),
            DateTime.Parse("2020-01-20 10:20:15"),
            repoId));
    context.SaveChanges();

    var client =
        factory
        .CreateHttpClient(
            CertificateScope.Platform,
            CertificatePermisson.Contributor);

    /// ACT
    var request = new HttpRequestMessage(
        HttpMethod.Get,
        // The get package url: /api/v1/stores/{store id}/packages/{App name}/versions/{App version}
        $"/api/v1/stores/{app.storeId}/packages/{app.name}/versions/{app.version}");

    // return the package information as a JSON string.
    request.Headers.Add("Accept", "application/json");

    var response = await
        client
        .SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead,
            default);

    /// VERIFY
    // If the app exists a 200 status should be returned.
    Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);

    /// ...
}
```

No change from ***V1*** to ***V2***:

Sometimes we don't have to update tests as we build out the codebase.
This test only check the validation code and never uses any dependencies.
We don't have to change this unit tests from ***V1*** to ***V2***.

```csharp
[Fact]
public async Task When_I_get_a_package_using_an_empty_package_name()
{
    /// ARRANGE
    (string name, string version) package =
        (name: "app1", version: "1.1.1");

    var factory = new CustomWebApplicationFactory<Startup>();

    /// ACT
    var client = factory.CreateHttpClient(CertificateScope.Platform, CertificatePermisson.Contributor);
    var request = new HttpRequestMessage(HttpMethod.Get, $"/api/v1/stores/{TestingEnvironment.StoreId}/packages/{"  "}/versions/{package.version}");
    request.Headers.Add("Accept", "application/json");

    var response = await
        client
        .SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead,
            default);

    Assert.Equal(System.Net.HttpStatusCode.BadRequest, response.StatusCode);

    /// VERIFY
    var bad_request_object_result =
        JsonConvert.DeserializeObject<Bad_request_object_result_struct>(
            await response.Content.ReadAsStringAsync(),
            new JsonSerializerSettings());

    Assert.Equal(
        new[] {
            "The name field is required.",
            "The package name is required." },
        bad_request_object_result.errors.name);
}
```

# Test Driven Design

<font size="+2"><span style="color:green"> ![tdd logo][tdd_logo] **I want help developing this.**</span></font>

TDD

# To read

- https://youtu.be/-nWhH-4wWBU?t=3379
