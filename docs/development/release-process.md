# Release Process

## Versioning

EventFlow follows [Semantic Versioning](https://semver.org/): `v<major>.<minor>.<patch>`.

- **Major**: breaking changes to the API, configuration, or data format
- **Minor**: new features, backward-compatible additions
- **Patch**: bug fixes and performance improvements

## Release cadence

- **Minor releases**: every 6 weeks
- **Patch releases**: as needed for bug fixes and security patches

## Release steps

### 1. Update CHANGELOG

We maintain a changelog following [Keep a Changelog](https://keepachangelog.com/) format.

```markdown
# Changelog

## [v1.2.0] - 2026-06-01

### Added
- Batch event ingestion endpoint (`POST /v1/events/batch`)
- S3 sink with gzip compression
- CLI `eventflow transform test` command

### Fixed
- Rate limiter overflow when window resets under load
- Webhook sink hanging on TLS handshake timeout

### Changed
- Upgraded QuickJS engine to 2024 release
- Default rate limit increased from 500 to 1000 rpm
```

### 2. Create a release PR

Open a pull request that:

- Updates `CHANGELOG.md`
- Updates version constants in `internal/version/version.go`
- Ensures all tests pass

### 3. Tag the release

Once the PR is merged, tag the commit:

```bash
git checkout main
git pull
git tag -s v1.2.0 -m "v1.2.0"
git push origin v1.2.0
```

Signed tags are required.

### 4. Build and publish

GitHub Actions handles the release automatically on tag push:

- Builds binaries for `linux/amd64`, `linux/arm64`, `darwin/amd64`, `darwin/arm64`, `windows/amd64`
- Builds and pushes Docker image to `eventflow/eventflow:<tag>` and `eventflow/eventflow:latest`
- Runs integration test suite

### 5. Draft the GitHub Release

The workflow creates a draft release. Edit it to:

- Add release notes summarizing changes
- Link to the full changelog
- Highlight upgrade instructions if any breaking changes exist
- Publish the release

### 6. Post-release

- Announce the release on Discord `#announcements`
- Update any downstream projects or Helm chart versions
- Deploy to the staging environment for verification

## Hotfix process

For critical bugs in a released version:

1. Branch from the release tag: `git checkout -b hotfix/v1.2.1 v1.2.0`
2. Apply the fix.
3. Bump the patch version.
4. Open a PR targeting `main` and the release branch.
5. Tag and release following the same process.

## Support policy

- The current minor version receives patch releases.
- Previous minor version receives critical security patches for 3 months after the next minor release.
