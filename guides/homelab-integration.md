# Homelab Integration Guide

I use homelab integration to let OpenClaw operate across real devices, not just the local machine.
This guide explains the node model, remote execution patterns, and safe operating habits.

## What Paired Nodes Are

A paired node is a device that trusts the OpenClaw gateway through a node key.
After pairing, the gateway can call approved capabilities on that device.

Typical nodes:

- Desktop hosts
- Laptops
- Phones
- Small servers in the rack

Pairing gives me a managed control plane for distributed actions.

## Pairing Model at a Glance

The flow is simple:

1. Gateway generates or validates node trust context
2. Node connects with key material
3. Gateway records node identity and capabilities
4. I call node actions by node id

I treat node keys like credentials.
I store and rotate them with the same care as tokens.

## What Nodes Can Do

In practical terms, paired nodes can expose useful remote actions.
Common ones include:

- `system.run` style command execution
- Screen capture and recording
- Camera snapshots and clips
- Location retrieval for mobile devices

This gives me a lightweight remote operations toolkit.

## Capability Examples

### Run Commands Remotely

I can run a command on a specific paired machine for diagnostics or automation.
Example intent:

- Check disk usage
- Restart a service
- Inspect logs

Pseudo call shape:

```json
{
  "action": "run",
  "node": "darth",
  "command": ["bash", "-lc", "uptime && df -h"]
}
```

### Capture a Screen Snapshot

Useful for remote troubleshooting and visual confirmation.

Pseudo call shape:

```json
{
  "action": "screen_record",
  "node": "maul",
  "durationMs": 5000,
  "fps": 5
}
```

For still images, use the screen snapshot variant when available in your stack.

### Take Camera Snaps

Good for physical checks like rack status LEDs or room context.

Pseudo call shape:

```json
{
  "action": "camera_snap",
  "node": "phone-node",
  "facing": "back",
  "quality": 85
}
```

### Retrieve Device Location

Useful for mobile automation and context aware reminders.

Pseudo call shape:

```json
{
  "action": "location_get",
  "node": "phone-node",
  "desiredAccuracy": "balanced"
}
```

## SSH via MCP Tools

For machines not directly paired as nodes, I use SSH through MCP tool integrations.
This keeps a unified automation interface.

Typical flow:

1. Select SSH target from MCP configured hosts
2. Run command through MCP invoke
3. Parse output and act

Example command intent:

```bash
ssh homelab-server 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

When MCP abstracts SSH, I still apply the same guardrails:

- Principle of least privilege
- Audit logs where possible
- No destructive commands without explicit confirmation

## Practical Workflow, Remote Server Task

Scenario: I need to update containers on a remote host.

Steps:

1. Confirm host health with `uptime`
2. Check free space with `df -h`
3. Pull updated images
4. Restart selected services
5. Verify with health endpoints

Example command sequence:

```bash
ssh prox4 'uptime'
ssh prox4 'df -h'
ssh prox4 'docker compose -f /opt/stacks/core.yml pull'
ssh prox4 'docker compose -f /opt/stacks/core.yml up -d'
ssh prox4 'curl -fsS http://localhost:8080/health'
```

I keep each step observable and reversible.

## Practical Workflow, Capture a Remote Screen

Scenario: GUI app on a remote desktop is failing.

Steps:

1. Trigger screen capture on target node
2. Review output for dialog errors
3. Run corrective command if needed
4. Capture again to validate fix

This is faster than asking for manual screenshots.

## Practical Workflow, Routine Homelab Automation

I schedule common checks and run remediations when safe.

Examples:

- Nightly service health checks
- Disk pressure alerts
- Backup job verification
- Camera snapshot after power events

A simple shell orchestration pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail
openclaw nodes run --node darth -- command bash -lc 'systemctl is-active tailscaled'
openclaw nodes run --node prox4 -- command bash -lc 'docker ps --format "{{.Names}} {{.Status}}"'
openclaw nodes run --node max -- command bash -lc 'pihole status'
```

I keep automated actions conservative.
I prefer alert then approve for high impact changes.

## Security Considerations

Homelab automation is powerful, so I design for blast radius control.

### Key Security Rules

- Rotate node keys periodically
- Scope permissions per node capability
- Separate admin nodes from daily use nodes
- Log remote command execution
- Protect camera and location access with strict policy

### Least Privilege in Practice

I do not give every node every capability.
A media server does not need location.
A phone node does not need privileged server automation by default.

### Secret Handling

I avoid plaintext secrets in scripts.
I use environment injection or secret manager retrieval.
I redact sensitive output in logs and reports.

### Network and Access Hardening

I limit ingress to trusted networks or VPN overlays.
I enforce TLS where supported.
I add host firewall rules so only required control traffic is open.

### Audit and Incident Response

I maintain logs for:

- Who triggered actions
- Which node executed actions
- Exact command payloads
- Timestamps and exit codes

If something goes wrong, I can reconstruct the timeline quickly.

## Failure Handling Patterns

When a node command fails, I do this:

1. Capture error output
2. Retry once for transient faults
3. Fall back to read only diagnostics
4. Escalate for manual review if still failing

I avoid repeated blind retries.

## Node Inventory Hygiene

I keep an inventory document with:

- Node id
- Physical device
- Capability set
- Owner and purpose
- Last key rotation date

This prevents forgotten high privilege nodes.

## Suggested Gateway Config Shape

A compact example:

```json
{
  "nodes": {
    "allowPairing": true,
    "requireNodeKey": true,
    "defaultTimeoutMs": 20000
  },
  "policies": {
    "camera": {
      "enabled": true,
      "approvedNodes": ["phone-node"]
    },
    "location": {
      "enabled": true,
      "approvedNodes": ["phone-node"]
    }
  }
}
```

I tune these defaults per environment, dev, lab, and production.

## Final Checklist

Before I rely on homelab integration in daily operations, I confirm:

- Nodes pair successfully with expected identities
- Remote command execution works on at least two nodes
- Screen or camera capture is tested once end to end
- Logs contain enough detail for audits
- Key rotation and revocation process is documented

With this setup, I get reliable remote automation while keeping security controls tight.
