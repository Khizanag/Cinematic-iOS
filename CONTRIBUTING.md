# Contributing to Cinematic

Thanks for your interest. Cinematic is a teaching reference, so contributions are judged on one extra axis beyond "does it work": does it make the example clearer for someone reading the code to learn MVI and Clean Architecture?

## Ways to help

- **Report a bug** or **request a feature** through the issue templates.
- **Improve the docs** — a confusing paragraph in `docs/` is a real bug here.
- **Send a pull request** for a fix or a focused improvement.

## Before you open a pull request

Read [`docs/ADDING-A-FEATURE.md`](docs/ADDING-A-FEATURE.md) for the inward-out workflow, and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the rules the codebase holds itself to. The short version:

- The dependency rule is enforced by the package manifests — never add an inward-pointing import (for example, `CinematicData` into the presentation layer).
- State changes only inside a reducer; asynchronous work is an `Effect` and results come back as intents.
- Every visual value comes from a `DesignSystem.*` token; user-facing strings live in a String Catalog.
- Tests use Swift Testing; `XCTest` appears only in the UI-test target.

## Quality gates

A change is ready when all of these pass:

```bash
swiftlint lint --strict

cd Package/MVIKit && swift test
cd Package/CinematicDomain && swift test
cd Package/CinematicData && swift test

xcodebuild test -scheme CinematicPresentation -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -project Cinematic.xcodeproj -scheme Cinematic -destination 'platform=iOS Simulator,name=iPhone 17'
```

CI runs the same matrix on every pull request. The build must have zero warnings.

## Commit and branch conventions

- Branch off `main`; never commit to `main` directly.
- Commit subjects are imperative and under 72 characters, with a type prefix: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `ci:`.
- Keep the *why* in the body when it is not obvious from the diff.
- Pull request bodies have two sections: a **Summary** and a **Test plan**.

## Code of conduct

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).
