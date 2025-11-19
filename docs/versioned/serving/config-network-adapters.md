---
audience: administrator
components:
  - serving
function: how-to
---

# Configuring network adapters

| Adapter | Description | Pros | Cons | Case usage |
| --- | --- | --- | --- | --- |
| Kourier | - Knative recommended default.<br>- Designed for Knative Serving.<br>- Envoy-based.<br>- Lightweight. | - Simple setup.<br>- Resource efficient. | No Ingress API support.<br>- Limited Features.<br>- No Service Mesh. | Default choice for most users.<br>For developers who want a Knative-focused ingress without full service mesh complexity. |