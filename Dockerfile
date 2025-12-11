# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Api/Api.csproj Api/
COPY Api.Tests/Api.Tests.csproj Api.Tests/
COPY TimeEntries.sln .
RUN dotnet restore

COPY . .
RUN dotnet build -c Release --no-restore
RUN dotnet publish Api/Api.csproj -c Release -o /app/publish --no-build

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Api.dll"]
