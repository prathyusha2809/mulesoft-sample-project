# MuleSoft Sample Integration Project

This repository contains a sample Mule 4 integration project that demonstrates a clean interview-ready pattern for exposing an HTTP API, transforming data with DataWeave, invoking an external REST service, and returning a normalized response.

## Project overview

The sample flow is intentionally small but follows practices that are useful to discuss in a senior MuleSoft interview:

- environment-specific property files
- dedicated HTTP listener and outbound request configurations
- reusable DataWeave transformations kept outside the flow XML
- structured logging with correlation identifiers
- basic error handling with mapped HTTP status codes

## Project structure

```text
.
├── mule-artifact.json
├── pom.xml
├── src
│   └── main
│       ├── mule
│       │   └── sample-integration.xml
│       └── resources
│           ├── config
│           │   ├── common.yaml
│           │   ├── dev.yaml
│           │   └── secure-dev.yaml
│           └── dw
│               ├── buildExternalRequest.dwl
│               ├── formatErrorResponse.dwl
│               └── formatIntegrationResponse.dwl
└── .gitignore
```

## Prerequisites

- Java 17
- Maven 3.9+
- Anypoint Studio 7.x or Mule Maven Plugin compatible tooling
- Network access to `https://jsonplaceholder.typicode.com`

## Setup instructions

1. Clone the repository.
2. Update `src/main/resources/config/common.yaml` with the external API protocol, host, port, and path required for your target system.
3. Replace the sample encrypted values in `src/main/resources/config/secure-dev.yaml` with encrypted client credentials for your target API.
4. Export the secure properties key before running the application:

   ```bash
   export SECURE_PROPERTIES_KEY=your-secure-properties-key
   ```

5. Add more environment files such as `qa.yaml`, `prod.yaml`, and matching secure property files when you need different runtime settings.
6. Keep `external.api.clientId` and `external.api.clientSecret` populated in the secure config even if your target API ignores them, or remove the headers from the sample flow.
7. Import the project into Anypoint Studio as an existing Maven project if you want to run it from the IDE.

## How to run the project

### From Maven

```bash
mvn clean package -Dmule.env=dev
mvn mule:run -Dmule.env=dev
```

### From Anypoint Studio

1. Import the project.
2. Open `src/main/mule/sample-integration.xml`.
3. Run the Mule application.

By default, the app listens on `http://0.0.0.0:8081`.

## API endpoints

### `GET /api/v1/customer-profile`

Accepts an optional query parameter:

- `userId` - numeric identifier forwarded to the sample upstream API as `id`. Defaults to `1`.

Example request:

```bash
curl "http://localhost:8081/api/v1/customer-profile?userId=1"
```

Example success response:

```json
{
  "status": "SUCCESS",
  "correlationId": "f4d0e4b8-95f6-11ef-bdd4-0242ac120002",
  "data": {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "companyName": "Romaguera-Crona",
    "city": "Gwenborough",
    "sourceSystem": "jsonplaceholder.typicode.com",
    "requestedUserId": 1
  }
}
```

Expected error statuses:

- `400` for invalid `userId` input
- `404` when no matching profile is returned by the upstream service
- `502`/`503`/`504` for upstream dependency issues
- `500` for unexpected application failures

Example `404 Not Found` response:

```json
{
  "status": "ERROR",
  "correlationId": "f4d0e4b8-95f6-11ef-bdd4-0242ac120002",
  "message": "No customer profile found for the requested userId",
  "failureType": "NOT_FOUND",
  "requestedUserId": 999
}
```

Example `502 Bad Gateway` response:

```json
{
  "status": "ERROR",
  "correlationId": "f4d0e4b8-95f6-11ef-bdd4-0242ac120002",
  "message": "Unable to complete the external API call",
  "failureType": "CONNECTIVITY",
  "requestedUserId": 1
}
```

## Sample transformations

### Outbound request enrichment

`src/main/resources/dw/buildExternalRequest.dwl`

```dw
%dw 2.0
output application/json
---
{
  requestContext: {
    correlationId: correlationId,
    requestedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ssXXX"}
  },
  queryParams: {
    id: vars.requestedUserId
  }
}
```

### Response normalization

`src/main/resources/dw/formatIntegrationResponse.dwl`

```dw
%dw 2.0
output application/json
var records = payload as Array
var firstRecord = records[0]
---
{
  status: "SUCCESS",
  correlationId: correlationId,
  data: {
    id: firstRecord.id,
    name: firstRecord.name default "Unknown",
    username: firstRecord.username default null,
    email: firstRecord.email default null,
    companyName: (firstRecord.company default {}).name default null,
    city: (firstRecord.address default {}).city default null,
    sourceSystem: vars.externalApiHost,
    requestedUserId: vars.requestedUserId
  }
}
```

## Interview talking points

For a senior-level MuleSoft discussion, be ready to explain:

- why properties are externalized by environment
- when to choose synchronous HTTP orchestration vs. async patterns
- how to add retries, circuit breakers, and API-led layers in production
- how you would secure credentials with secure properties or a secrets manager
- how you would cover the flow with MUnit tests and mock the external endpoint
