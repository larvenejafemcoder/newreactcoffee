# Installation

## Prerequisites

- **Binary install**: a 64-bit Linux, macOS, or Windows system
- **Docker install**: Docker Engine 24.0+ and Docker Compose v2
- **Source build**: Go 1.21+, `make`, `git`

## Install from binary

Download the latest release for your platform from the [releases page](https://github.com/eventflow/eventflow/releases).

```bash
# Linux amd64
curl -LO https://github.com/eventflow/eventflow/releases/download/v1.2.0/eventflow_1.2.0_linux_amd64.tar.gz
tar -xzf eventflow_1.2.0_linux_amd64.tar.gz
sudo mv eventflow /usr/local/bin/
```

```bash
# macOS arm64
curl -LO https://github.com/eventflow/eventflow/releases/download/v1.2.0/eventflow_1.2.0_darwin_arm64.tar.gz
tar -xzf eventflow_1.2.0_darwin_arm64.tar.gz
sudo mv eventflow /usr/local/bin/
```

## Install via Docker

```bash
docker pull eventflow/eventflow:latest
```

Quick test:

```bash
docker run --rm eventflow/eventflow:latest version
```

Production Docker Compose setups are covered in the [Quickstart](./quickstart.md).

## Build from source

```bash
git clone https://github.com/eventflow/eventflow.git
cd eventflow
make build
```

The binary is produced at `bin/eventflow`. Optionally install it system-wide:

```bash
sudo make install
```

## Verify the installation

```bash
eventflow version
```

Expected output:

```
EventFlow v1.2.0 (commit a1b2c3d4, built 2026-06-01T10:00:00Z)
```

## Next steps

Proceed to the [Quickstart](./quickstart.md) to send your first event.
