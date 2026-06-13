# Contributing

Thank you for your interest in contributing to EventFlow. We welcome contributions of all kinds: bug fixes, features, documentation improvements, and issue triage.

## Code of Conduct

This project adheres to the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you agree to uphold this code. Report unacceptable behavior to conduct@eventflow.io.

## How to contribute

### Reporting bugs

Open a [GitHub Issue](https://github.com/eventflow/eventflow/issues/new) with:

- A clear, descriptive title
- Steps to reproduce (including configuration and sample events)
- Expected vs actual behavior
- EventFlow version and environment details

### Feature requests

Open an issue with the `enhancement` label. Describe the problem you're solving and, if applicable, how you would implement it.

### Pull requests

1. Fork the repository.
2. Create a branch from `main`: `git checkout -b feat/my-feature`.
3. Make your changes.
4. Run tests and linting: `make test && make lint`.
5. Sign your commits (`git commit -s`).
6. Push and open a PR against `main`.

## Commit conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(ingestion): add batch event endpoint
fix(sinks): retry backoff overflow in kafka sink
docs(readme): update quickstart example
test(transforms): add js_script benchmark
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `perf`, `ci`.

## Documentation contributions

The `docs/` directory contains all project documentation. Improvements are welcome. Docs are written in Markdown and follow the existing structure and style.

## Review expectations

- All PRs require at least one maintainer review.
- CI must pass (lint, unit tests, integration tests).
- New features should include tests.
- API changes should update the OpenAPI spec.
- Documentation updates should accompany feature changes.

## Development setup

See [Local Setup](./local-setup.md) for instructions on setting up a development environment.

## Getting help

- GitHub Issues for bug reports and feature requests.
- Discord `#contributors` channel for questions.
