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
  },
  headers: {
    "client-id": p("secure::external.api.clientId"),
    "client-secret": p("secure::external.api.clientSecret")
  }
}
