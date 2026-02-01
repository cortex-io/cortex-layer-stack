# Cortex Layer Stack

A Helm chart for deploying self-contained, burst-capable AI service stacks that can evolve into specialized models.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Cortex Layer Stack                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ MoE Router  │  │   Qdrant    │  │    MCP Server       │  │
│  │ (routing)   │──│  (vectors)  │──│ (tool execution)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│         │                │                    │              │
│         └────────────────┴────────────────────┘              │
│                          │                                   │
│                    Telemetry Collection                      │
│                          │                                   │
│                  ┌───────▼───────┐                          │
│                  │  Distillation │                          │
│                  │   Pipeline    │                          │
│                  └───────────────┘                          │
│                          │                                   │
│                  Specialized Model                           │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Install KEDA first (for scale-to-zero)
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda -n keda --create-namespace

# Deploy an infrastructure layer
helm install infra-layer ./cortex-layer-stack \
  -f examples/infrastructure-layer.yaml \
  -n cortex-infrastructure \
  --create-namespace
```

## Features

### Scale-to-Zero
All components scale to zero when idle, using KEDA ScaledObjects:
- MoE Router: Scales based on HTTP requests
- Qdrant: Scales with longer stabilization (stateful)
- MCP Server: Scales based on requests or message queue depth

### Telemetry for Distillation
Each component captures operational data:
- **MoE Router**: Routing decisions, expert selection, confidence scores
- **Qdrant**: Query patterns, result relevance, vector clusters
- **MCP Server**: Tool invocations, success/failure rates, execution times

### Automated Distillation Pipeline
When enough quality data accumulates:
1. CronJob collects training data from Qdrant
2. Applies quality filters (min confidence, success rate)
3. Fine-tunes a LoRA adapter (or full model)
4. Publishes to model registry

## Configuration

### Layer Definition
```yaml
layer:
  name: infrastructure       # Unique layer identifier
  description: "K8s ops"     # Human description
  domain: "infra.cortex.ai"  # Optional DNS domain
```

### Autoscaling
```yaml
autoscaling:
  enabled: true
  idleTimeout: 300      # Seconds before scale-to-zero
  minReplicas: 0        # 0 enables scale-to-zero
  maxReplicas: 3        # Burst capacity
```

### Distillation
```yaml
distillation:
  enabled: true
  collection:
    minSamples: 10000        # Minimum before eligible
    qualityThreshold: 0.8    # Quality gate
  output:
    type: "lora"             # lora, full, or gguf
    baseModel: "codellama/CodeLlama-7b"
    loraRank: 16
```

## Examples

See `examples/` for pre-configured layers:
- `infrastructure-layer.yaml` - K8s, Proxmox, cloud ops
- `security-layer.yaml` - Security scanning, compliance
- `networking-layer.yaml` - UniFi, DNS, network troubleshooting

## The Vision

This chart implements "Infrastructure as Training Data":

1. **Deploy** a generalist layer stack
2. **Operate** - let it handle real tasks, collecting telemetry
3. **Accumulate** domain expertise in vectors and routing patterns
4. **Distill** operational knowledge into a specialized model
5. **Graduate** - replace the orchestration with a single specialist

The layer essentially teaches itself through operation.
