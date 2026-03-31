# ITXEcommerce

**Author:** Marcos A. González Piñeiro

A modern iOS ecommerce application built with the latest Apple frameworks and Swift tooling, following clean architecture principles.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Modules](#modules)
  - [Main App](#main-app)
  - [CoreNetwork](#corenetwork)
- [Scenes](#scenes)
- [Networking Layer](#networking-layer)
- [Configuration & Environments](#configuration--environments)
- [Testing](#testing)
- [Code Quality](#code-quality)

---

## Overview

ITXEcommerce is a SwiftUI-based iOS application structured around the **MVVM** architectural pattern. It provides a tab-driven UI with dedicated scenes for browsing a product catalog, managing favorites, and accessing settings. The app is backed by **SwiftData** for local persistence and a custom **CoreNetwork** Swift Package for all remote communication.

---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 26.2+ |
| iOS Deployment Target | 18.0+ |
| Swift Tools | 6.2 |
| macCatalyst | 18.0+ |

---

## Architecture

The project follows **MVVM (Model-View-ViewModel)** with a clear separation of concerns:

- **View** — SwiftUI views, purely declarative, free of business logic.
- **ViewModel** — Holds state and business logic; observed by the View.
- **Model** — SwiftData `@Model` classes for persistent data.
- **CoreNetwork** — Independent SPM package providing the networking infrastructure.

### Key Design Principles

- **Protocol-oriented design** — All major abstractions (`ApiClientProtocol`, `EndpointProvider`, `Session`, `RequestInterceptor`) are protocol-backed, enabling easy testing and substitution.
- **Swift 6 concurrency** — Full `Sendable` conformance throughout, async/await for all network calls.
- **Modularity** — Networking is fully decoupled from the app layer via a local Swift Package.
- **Multi-environment support** — Build configurations for Stage and Production via `.xcconfig` files.

---

## Project Structure

```
ITXEcommerce/
├── ITXEcommerce/                     # Main app target
│   ├── App/
│   │   ├── ITXEcommerceApp.swift     # @main entry point, SwiftData container setup
│   │   ├── Configuration/
│   │   │   ├── itxecommerce-shared.xcconfig
│   │   │   ├── itxecommerce-stage.xcconfig
│   │   │   └── itxecommerce-prod.xcconfig
│   │   └── Supporting Files/
│   │       ├── Localizable.xcstrings # String catalog for localization
│   │       ├── Info-Stage.plist
│   │       ├── Info-Prod.plist
│   │       ├── ITXEcommerce.entitlements
│   │       └── Assets.xcassets/     # App icons (stage/prod variants), accent colors
│   ├── Model/
│   │   └── Item.swift               # SwiftData @Model
│   └── Scenes/
│       ├── Root/
│       │   ├── RootView.swift
│       │   └── RootViewModel.swift  # AppTab enum
│       ├── Catalog/
│       │   ├── CatalogView.swift
│       │   └── CatalogViewModel.swift
│       ├── Cart/
│       │   ├── CartView.swift
│       │   └── CartViewModel.swift
│       ├── Favorites/
│       │   ├── FavoritesView.swift
│       │   └── FavoritesViewModel.swift
│       └── Settings/
│           ├── SettingsView.swift
│           └── SettingsViewModel.swift
│
├── CoreNetwork/                      # Local SPM package
│   ├── Package.swift
│   └── Sources/CoreNetwork/
│       ├── CoreNetwork.swift         # Public typealiases
│       ├── Client/
│       │   ├── ApiClient.swift
│       │   ├── ApiClientProtocol.swift
│       │   └── APIError.swift
│       └── Core/
│           ├── CoreHTTP.swift        # HTTP enums (methods, headers, MIME types, auth)
│           ├── EndpointProvider.swift
│           ├── EndpointProvider+Default.swift
│           ├── Session.swift
│           ├── RequestInterceptor.swift
│           ├── RequestOptions.swift
│           ├── ResponseOptions.swift
│           ├── KnownError.swift
│           └── Multipart.swift
│
├── ITXEcommerceTests/               # Unit tests (Swift Testing)
├── ITXEcommerceUITests/             # UI & launch tests
└── .swiftlint.yml                   # SwiftLint configuration
```

---

## Modules

### Main App

The app entry point (`ITXEcommerceApp`) sets up a `WindowGroup` with `RootView` and attaches a SwiftData `ModelContainer` for `Item`.

```swift
@main
struct ITXEcommerceApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: [Item.self])
    }
}
```

#### Model

`Item` is a SwiftData `@Model` with a `timestamp` property, used as the foundation for persistent data in the app.

---

### CoreNetwork

A fully self-contained **Swift Package** (targets iOS 18+ / macCatalyst 18+) providing a generic, protocol-driven HTTP client.

**Key components:**

| File | Responsibility |
|------|---------------|
| `ApiClient` | Concrete `ApiClientProtocol` implementation with retry logic |
| `ApiClientProtocol` | Generic `async throws` request interface |
| `APIError` | Typed error model wrapping HTTP and decoding failures |
| `EndpointProvider` | Protocol defining a full API endpoint (scheme, base URL, path, method, headers, body, query items, auth, multipart, mock file) |
| `EndpointProvider+Default` | Sensible default implementations for optional endpoint properties |
| `CoreHTTP` | `@frozen` enum namespace for HTTP schemes, methods, header keys, MIME types, authorization methods, and status code ranges |
| `Session` / `SessionImpl` | Abstraction over `URLSession` for testability |
| `RequestInterceptor` | Protocol for adapting requests and handling retries |
| `RequestOptions` | Configuration for outgoing request behaviour (MIME type, etc.) |
| `ResponseOptions` | Configuration for response validation (status code range, allowed MIME types) |
| `KnownError` | Typed HTTP error status codes (401, 403, etc.) |
| `Multipart` | Multipart form-data request body builder |

---

## Scenes

Navigation is managed by `RootView` using an `AppTab`-driven `TabView`. The app supports both the iOS 26+ `Tab` API (typed selection) and a backwards-compatible fallback for iOS 18–25.

```
AppTab
├── .catalog
├── .favorites
└── .settings
```

| Scene | View | ViewModel | Status |
|-------|------|-----------|--------|
| Root | `RootView` | `RootViewModel` (AppTab enum) | Complete |
| Catalog | `CatalogView` | `CatalogViewModel` | Placeholder |
| Cart | `CartView` | `CartViewModel` | Placeholder |
| Favorites | `FavoritesView` | `FavoritesViewModel` | Placeholder |
| Settings | `SettingsView` | `SettingsViewModel` | Placeholder |

---

## Networking Layer

`ApiClient` implements a request pipeline with:

1. **URL construction** — via `EndpointProvider.asURLRequest()`
2. **Request adaptation** — optional `RequestInterceptor.adapt(_:for:)` hook
3. **Request logging** — method, URL, headers, body printed in debug builds
4. **URLSession execution** — via the injected `Session` abstraction
5. **Response validation** — HTTP status code range and MIME type allowlist checks
6. **JSON decoding** — generic `Decodable` via `JSONDecoder`
7. **Response logging** — status code, MIME type, raw body
8. **Retry logic** — driven by `RequestInterceptor.retry(_:for:dueTo:)`, supporting:
   - `.retry` — immediate retry
   - `.retryWithDelay(seconds)` — back-off retry using `Task.sleep`
   - `.doNotRetry` — propagate the error
   - `.doNotRetryWithError(Error)` — propagate an overridden error

### Supported Authorization Methods

| Type | Header value format |
|------|-------------------|
| Basic | `Basic <token>` |
| Bearer | `Bearer <token>` |
| Digest | `Digest <token>` |
| AWS | `AWS4-HMAC-SHA256 <token>` |

---

## Configuration & Environments

The project uses `.xcconfig` files for multi-environment configuration, with separate `Info.plist` files and app icon sets per environment:

| Config | Purpose |
|--------|---------|
| `itxecommerce-shared.xcconfig` | Shared settings (product name, team disambiguator) |
| `itxecommerce-stage.xcconfig` | Stage environment overrides |
| `itxecommerce-prod.xcconfig` | Production environment overrides |

Each environment has its own `Info-Stage.plist` / `Info-Prod.plist` and distinct app icons in `Assets.xcassets`, making it easy to distinguish builds on a device.

---

## Testing

Tests use the **Swift Testing** framework (not XCTest) throughout.

| Target | Framework | Coverage |
|--------|-----------|---------|
| `ITXEcommerceTests` | Swift Testing | App-level unit tests (scaffold) |
| `ITXEcommerceUITests` | XCTest | UI interaction & launch performance |
| `CoreNetworkTests` | Swift Testing | API client, endpoint provider, retry logic, error handling |

`CoreNetworkTests` includes:
- `ApiClientTests` — tagged with `.networking`, `.errorHandling`
- `EndpointProviderTests` — endpoint URL construction
- `RetryLogicTests` — retry/back-off behaviour
- `CoreNetworkTests` — additional integration scenarios
- `Mocks` — mock `Session` and `EndpointProvider` implementations

---

## Code Quality

SwiftLint is integrated as an **SPM build tool plugin** and runs automatically at compile time.

Notable rules configured in `.swiftlint.yml`:

| Rule | Warning | Error |
|------|---------|-------|
| Line length | 200 chars | 250 chars |
| Identifier naming | custom min/max lengths | — |
