# AI prediction and assistant design

## Outage prediction

The prediction service is an asynchronous pipeline, not part of the request
path for outage reporting.

1. Export historical outage and complaint events to BigQuery.
2. Join weather, asset age, load, vegetation, feeder trip, transformer
   temperature, and maintenance features.
3. Train time-bounded models with geographic holdout sets to avoid leakage.
4. Evaluate recall, calibration, lead time, provider drift, and false-alert
   cost before registering a versioned model.
5. Run scheduled inference per area and write expiring `riskPredictions`.
6. Alert provider staff only after policy and data-freshness checks.

Every prediction includes `modelVersion`, `riskScore`, `drivers`, confidence,
data freshness, and validity dates. A prediction is advisory and cannot
dispatch technicians or change outage state.

## AI assistant

The assistant retrieves only approved provider notices, outage records,
complaint timelines, emergency guidance, and public maintenance schedules.

- It receives only records the authenticated user may access.
- It never exposes technician location or another consumer's information.
- Restoration estimates distinguish provider estimates from model guidance.
- Emergency prompts use deterministic, reviewed instructions first.
- Mutations require confirmation and pass through the normal command API.
- Prompts, tool calls, model versions, safety outcomes, and feedback are logged
  with PII minimization.

Do not expose predictions to consumers until each provider model has monitored
calibration, drift detection, rollback, and human escalation.
