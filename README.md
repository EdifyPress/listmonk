# listmonk (Multi-Tenant Fork)

[![listmonk-logo](https://user-images.githubusercontent.com/547147/231084896-835dba66-2dfe-497c-ba0f-787564c0819e.png)](https://listmonk.app)

**This is a fork of [listmonk](https://github.com/knadh/listmonk) with multi-tenant and white-labeling enhancements.**

listmonk is a standalone, self-hosted, newsletter and mailing list manager. It is fast, feature-rich, and packed into a single binary. It uses a PostgreSQL database as its data store.

[![listmonk-dashboard](https://github.com/user-attachments/assets/689b5fbb-dd25-4956-a36f-e3226a65f9c4)](https://listmonk.app)

Visit [listmonk.app](https://listmonk.app) for upstream documentation.

---

## Enhancements in This Fork

This fork adds the following features for multi-tenant deployments:

### 1. Alternative Email Provider APIs
Support for REST API-based email delivery as an alternative to SMTP:
- **Postal**: Send via [Postal](https://github.com/postalserver/postal) REST API
- **SendGrid**: Send via SendGrid API
- **Mailgun**: Send via Mailgun API
- Webhook support for delivery tracking (opens, clicks, bounces)
- HMAC signature verification for webhook security

**Why AGPL?** This modifies ListMonk's internal campaign sending pipeline (`internal/manager/`) and replaces built-in SMTP functionality → derivative work under AGPL-3.0.

**Documentation**: [docs/postal-integration.md](docs/postal-integration.md)

### 2. Enhanced White-Labeling
Per-tenant branding for multi-tenant deployments:
- Custom logos, colors, and CSS per organization
- Dynamic branding in Vue UI and email templates
- API endpoints for managing branding settings
- Template variables: `{{ .Branding.LogoURL }}`, `{{ .Branding.PrimaryColor }}`

**Why AGPL?** This modifies ListMonk's Vue frontend and Go template rendering → derivative work under AGPL-3.0.

**Documentation**: [docs/white-labeling.md](docs/white-labeling.md)

### 3. Row-Level Security (RLS) Support
Additional privacy support via PostgreSQL RLS:
- Adds `rls_marker UUID` column to all data tables
- Enables database-level isolation via RLS policies
- Session variable: `app.current_marker` filters all queries

**Why AGPL?** This modifies ListMonk's database schema (`schema.sql`) → derivative work under AGPL-3.0.

**Documentation**: [docs/rls-setup.md](docs/rls-setup.md)

---

## Architecture: AGPL Compliance

Per AGPL-3.0 and industry precedent (GitLab, Odoo, Open edX), external services using standard interfaces are **separate works**, not derivative works, and may remain proprietary.

**Reference**: This architecture follows the "Separate Works Doctrine" as analyzed in *Neo4j v. PureThink* (Ninth Circuit, 2024).

---

## Installation

### Docker

The latest image is available on GitHub Container Registry at [`ghcr.io/edifypress/listmonk:latest`](https://github.com/edifypress/listmonk/pkgs/container/listmonk).

```shell
docker pull ghcr.io/edifypress/listmonk:latest
docker run -d \
  -p 9000:9000 \
  -e LISTMONK_database__host=postgres \
  -e LISTMONK_database__dbname=listmonk \
  -e POSTAL_API_URL=https://smtp.example.com \
  -e POSTAL_API_KEY=your-api-key \
  ghcr.io/edifypress/listmonk:latest
```

**Configuration**:
- `POSTAL_API_URL` - Postal server URL (default: use SMTP)
- `POSTAL_API_KEY` - Postal API key for authentication
- `POSTAL_WEBHOOK_SECRET` - Secret for HMAC webhook verification

See [docs/installation.md](docs/installation.md) for complete setup guide.

### Docker Compose

Download the sample [docker-compose.yml](https://github.com/edifypress/listmonk/blob/master/docker-compose.yml):

```shell
curl -LO https://github.com/edifypress/listmonk/raw/master/docker-compose.yml
docker compose up -d
```

Visit `http://localhost:9000`

### Binary

- Download the [latest release](https://github.com/edifypress/listmonk/releases)
- `./listmonk --new-config` to generate config.toml. Edit it.
- `./listmonk --install` to setup the Postgres DB
- Run `./listmonk` and visit `http://localhost:9000`

---

## Upstream Synchronization

We regularly sync with upstream ListMonk to receive bug fixes and features:

```bash
git remote add upstream https://github.com/knadh/listmonk.git
git fetch upstream
git merge upstream/master
```

**Sync Frequency**: Every 2-4 weeks for minor releases, within 1 week for security patches.

**Upstream Contributions**: We contribute generically useful features back to upstream when possible (e.g., pluggable messenger interface, white-labeling framework).

---

## Development

### Prerequisites

- Go 1.23+
- Node.js 20+
- PostgreSQL 16+

### Setup

```bash
# Clone the repository
git clone https://github.com/edifypress/listmonk.git
cd listmonk

# Install dependencies
go mod download
cd frontend && npm install && cd ..

# Create config file
cp config.toml.sample config.toml
# Edit config.toml with your database and email provider settings

# Setup database
make install

# Run backend
make run

# In another terminal, run frontend dev server
cd frontend && npm run dev
```

Visit `http://localhost:8080` (frontend dev server proxies to backend at :9000)

### Testing

```bash
# Run all tests
make test

# Run specific test package
go test ./internal/messenger/...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Building

```bash
# Build binary for current platform
make build

# Build Docker image
docker build -t listmonk-multitenant:dev .

# Build for multiple platforms
make release
```

---

## Contributing

We welcome contributions to this fork! Please:

1. Check [existing issues](https://github.com/edifypress/listmonk/issues) or create a new one
2. Fork the repository and create a feature branch
3. Make your changes with tests
4. Submit a pull request

**For upstream features**: Consider submitting to [knadh/listmonk](https://github.com/knadh/listmonk) first, then we'll sync.

**Code of Conduct**: Be respectful and constructive. This is an open-source project.

---

## License

listmonk (including this fork) is licensed under the **AGPL v3 license**.

**What this means**:
- ✅ You can use, modify, and distribute this software
- ✅ You can use it for commercial purposes
- ⚠️ If you modify this code and deploy it as a network service, you **must** publish your modifications under AGPL-3.0
- ⚠️ If you create a derivative work, it must also be AGPL-3.0

**What is NOT covered by AGPL**:
- ✅ External services that communicate via standard interfaces (HTTP, SQL) are **not** derivative works
- ✅ Configuration files, deployment scripts, and infrastructure code are **not** derivative works
- ✅ Applications that use ListMonk's API without modifying ListMonk code are **not** derivative works

**Questions about licensing?** See [LICENSE](LICENSE) or consult a lawyer. The above is a summary, not legal advice.

---

## Upstream Project

This is a fork of [listmonk](https://github.com/knadh/listmonk) by [@knadh](https://github.com/knadh) and maintained by [Zerodha](https://zerodha.tech).

- **Upstream Repository**: https://github.com/knadh/listmonk
- **Upstream Documentation**: https://listmonk.app
- **Upstream License**: AGPL-3.0

We are grateful to the upstream maintainers and contributors for building an excellent open-source email marketing platform.

---

## Links

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/edifypress/listmonk/issues)
- **Discussions**: [GitHub Discussions](https://github.com/edifypress/listmonk/discussions)
- **Container Registry**: https://github.com/edifypress/listmonk/pkgs/container/listmonk
