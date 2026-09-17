%dw 2.0
output application/json
---
{
  status: "ERROR",
  correlationId: correlationId,
  message: vars.errorMessage default (error.description default "Unable to complete the external API call"),
  failureType: vars.failureType default "UNKNOWN",
  requestedUserId: vars.requestedUserId default null
}
