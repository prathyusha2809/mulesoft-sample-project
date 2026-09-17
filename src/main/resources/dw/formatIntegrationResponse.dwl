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
