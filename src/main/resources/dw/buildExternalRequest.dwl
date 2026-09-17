%dw 2.0
output application/json
---
{
  requestContext: {
    correlationId: correlationId,
    requestedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ssXXX"}
  },
  queryParams: {
    userId: vars.requestedUserId
  },
  headers: {
    "client-id": p("external.api.clientId"),
    "client-secret": p("external.api.clientSecret")
  }
}
