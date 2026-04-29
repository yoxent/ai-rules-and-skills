---
name: networking
description: "Use when task requires On multiplayer scripts. Enforce NGO NetworkVariable permissions, ServerRpc validation, ClientRpc usage, and spawn lifecycle."
---

# Networking

name:networking|pri:M|deps:[code-standards,architecture-patterns]|flags:[]|rules:[DA-1,DA-7,MF-5,PC-5]
SCOPE: On multiplayer scripts. Enforce NGO NetworkVariable permissions, ServerRpc validation, ClientRpc usage, and spawn lifecycle.
ENFORCE: NetworkVariable with explicit read/write permissions (NetworkVariableReadPermission+NetworkVariableWritePermission); server-side guard conditions in all ServerRpc before state mutation; ClientRpc called from server context only, for notifications not state sync; OnNetworkSpawn for network-dependent init, OnNetworkDespawn for cleanup; IsOwner/IsServer checks prohibited in Awake/Start.
PROHIBIT: NetworkVariable without explicit permissions; unvalidated ServerRpc input applied to state; ClientRpc called from client code; network initialization logic in Awake or Start; client-authoritative state modification.
ON_VIOLATION: missing_permissions→BLOCK→explicit_params. unvalidated_rpc→BLOCK→guard_conditions. client_clientrpc→BLOCK→server_context. lifecycle_in_awake→warn→migrate_to_spawn.

## Reference
- See [reference.md](reference.md) for distilled source details.
