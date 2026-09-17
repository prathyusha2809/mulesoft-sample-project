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
