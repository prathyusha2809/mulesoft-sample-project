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
