using System.ComponentModel.DataAnnotations;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Store time entries
var timeEntries = new List<TimeEntry>();
var nextId = 1;

// POST /time-entries 
app.MapPost("/time-entries", (TimeEntryRequest request) =>
{
    // Error string
    var errors = new List<string>();

    // Check date 
    if (string.IsNullOrWhiteSpace(request.Date))
    {
        errors.Add("date is required");
    }
    else if (!DateOnly.TryParse(request.Date, out _))
    {
        errors.Add("date must be a valid ISO 8601 date (e.g., 2025-10-07)");
    }
    // Validate durationMinutes (must be positive)
    if (request.DurationMinutes <= 0)
    {
        errors.Add("durationMinutes must be greater than 0");
    }
    // Validate project (not be empty)
    if (string.IsNullOrWhiteSpace(request.Project))
    {
        errors.Add("project is required and cannot be empty");
    }
    // Return 400 if there are validation errors
    if (errors.Count > 0)
    {
        return Results.BadRequest(new { errors });
    }

    // Create the time entry
    var entry = new TimeEntry(
        Id: nextId++,
        Date: request.Date!,
        DurationMinutes: request.DurationMinutes,
        Project: request.Project!
    );

    timeEntries.Add(entry);

    return Results.Created($"/time-entries/{entry.Id}", entry);
});

// GET /time-entries - List entries with optional date filtering
app.MapGet("/time-entries", (string? from, string? to) =>
{
    var result = timeEntries.AsEnumerable();

    // Filter by 'from' date if provided
    if (!string.IsNullOrWhiteSpace(from) && DateOnly.TryParse(from, out var fromDate))
    {
        result = result.Where(e => DateOnly.Parse(e.Date) >= fromDate);
    }

    // Filter by 'to' date if provided
    if (!string.IsNullOrWhiteSpace(to) && DateOnly.TryParse(to, out var toDate))
    {
        result = result.Where(e => DateOnly.Parse(e.Date) <= toDate);
    }

    return Results.Ok(result.ToList());
});

// GET /health - Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();

// Request model for creating time entry
public record TimeEntryRequest(string? Date, int DurationMinutes, string? Project);

// Time entry model stored
public record TimeEntry(int Id, string Date, int DurationMinutes, string Project);

// Expose Program class for integration testing
public partial class Program { }

