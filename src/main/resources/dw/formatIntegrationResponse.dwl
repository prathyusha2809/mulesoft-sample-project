%dw 2.0
output application/json
var firstRecord = payload[0]
---
{
  status: "SUCCESS",
  correlationId: correlationId,
  data: {
    id: firstRecord.id,
    name: firstRecord.name default "Unknown",
    username: firstRecord.username default null,
    email: firstRecord.email default null,
    company: firstRecord.company.name default null,
    city: firstRecord.address.city default null,
    sourceSystem: p("external.api.host"),
    requestedUserId: vars.requestedUserId
  }
}
