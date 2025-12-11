using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Api.Tests;

public class TimeEntryValidationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public TimeEntryValidationTests(WebApplicationFactory<Program> factory)
    {
        // Create a test HTTP client that talks to our API
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Post_WithZeroDuration_ReturnsBadRequest()
    {
        // Arrange: Create a request with invalid durationMinutes (0)
        var invalidEntry = new
        {
            date = "2025-10-07",
            durationMinutes = 0,  // Invalid: must be > 0
            project = "TestProject"
        };

        // Act: Send POST request to the API
        var response = await _client.PostAsJsonAsync("/time-entries", invalidEntry);

        // Assert: Should return 400 Bad Request
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Post_WithValidData_ReturnsCreated()
    {
        // Arrange: Create a valid request
        var validEntry = new
        {
            date = "2025-10-07",
            durationMinutes = 90,  // Valid: > 0
            project = "TestProject"
        };

        // Act: Send POST request to the API
        var response = await _client.PostAsJsonAsync("/time-entries", validEntry);

        // Assert: Should return 201 Created
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
}

