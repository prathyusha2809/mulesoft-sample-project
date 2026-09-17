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
│           │   └── dev.yaml
│           └── dw
│               ├── buildExternalRequest.dwl
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
2. Update `/home/runner/work/mulesoft-sample-project/mulesoft-sample-project/src/main/resources/config/common.yaml` with the external API host, path, and any credential values required for your target system.
3. Add more environment files such as `qa.yaml` or `prod.yaml` when you need different runtime settings.
4. Import the project into Anypoint Studio as an existing Maven project if you want to run it from the IDE.

## How to run the project

### From Maven

```bash
mvn clean package -Dmule.env=dev
```

### From Anypoint Studio

1. Import the project.
2. Open `src/main/mule/sample-integration.xml`.
3. Run the Mule application.

By default, the app listens on `http://0.0.0.0:8081`.

## API endpoints

### `GET /api/v1/customer-profile`

Accepts an optional query parameter:

- `userId` - numeric identifier forwarded to the sample upstream API. Defaults to `1`.

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
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "sourceSystem": "jsonplaceholder.typicode.com",
    "requestedUserId": 1
  }
}
```

Example error response:

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
  filters: {
    userId: vars.requestedUserId
  }
}
```

### Response normalization

`src/main/resources/dw/formatIntegrationResponse.dwl`

```dw
%dw 2.0
output application/json
var firstRecord = (payload default [])[0] default {}
---
{
  status: "SUCCESS",
  correlationId: correlationId,
  data: {
    id: firstRecord.id default null,
    title: firstRecord.title default "Unavailable",
    sourceSystem: p("external.api.host"),
    requestedUserId: vars.requestedUserId
  }
}
```

## Interview talking points

For an 8-years-experience discussion, be ready to explain:

- why properties are externalized by environment
- when to choose synchronous HTTP orchestration vs. async patterns
- how to add retries, circuit breakers, and API-led layers in production
- how you would secure credentials with secure properties or a secrets manager
- how you would cover the flow with MUnit tests and mock the external endpoint
