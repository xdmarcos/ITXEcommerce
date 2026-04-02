# ITXEcommerce

**Author:** Marcos A. González Piñeiro

A modern iOS ecommerce application built with the latest Apple frameworks and Swift tooling.

---

## Architecture Overview

The app follows **MVVM (Model-View-ViewModel)** with a Repository pattern as the data layer, structured around Clean Architecture and SOLID principles.

### Pattern choice and reasoning

MVVM was chosen because it maps naturally onto SwiftUI's reactive model: Views observe `@Observable` ViewModels and re-render on state changes with no manual binding boilerplate. Business logic and side-effects live exclusively in ViewModels, keeping Views declarative and easy to reason about.

The Repository layer provides the abstraction boundary between persistence and presentation — every ViewModel receives a protocol, never a concrete type, enabling trivial mocking in tests and clean layer separation.

### Code organisation

```
ITXEcommerce/
├── App/                        # Entry point, DI wiring, xcconfig environments
│   └── Configuration/          # EnvironmentManager (staging / production)
├── Model/                      # SwiftData @Model classes (Product, CartItem) + DTOs
├── Repositories/               # Protocol-backed data layer + SwiftData persistence
│   ├── ProductRepositoryProtocol / ProductRepository
│   ├── CartRepositoryProtocol  / CartRepository
│   ├── RemoteDataSourceProtocol                # Network boundary protocol
│   ├── ProductUpsertActor                      # Background @ModelActor for SwiftData writes
│   ├── CacheManageable                         # Narrow ISP protocol for cache clearing
│   ├── ClearAllDataService                     # SRP composition: clears product + cart caches
│   ├── NullProductRepository                   # Null-object default for environment key
│   ├── NullCartRepository                      # Null-object default for environment key
│   └── NullCacheManageable                     # Null-object default for environment key
├── Services/                   # Concrete remote data source + endpoint definitions
│   ├── DummyJsonRemoteDataSource
│   └── ServiceProvider (DummyJsonEndpointProvider)
├── Scenes/
│   ├── Root/                   # Tab navigation (RootView + RootViewModel)
│   ├── Catalog/                # Product grid with pagination, sort, category filter, search
│   ├── ProductDetail/          # Full product detail + image gallery + add to cart
│   ├── Cart/                   # Cart list, quantity controls, checkout
│   ├── Settings/               # Theme, language, cache management
│   ├── QuickStart/             # In-app README renderer (MarkdownView)
│   └── Common/                 # Shared UI components + ProductCategory+Color extension
└── CoreNetwork/                # Local Swift Package — generic HTTP client
```

```
ITXEcommerceTests/
├── Mocks/
│   ├── MockProductRepository
│   ├── MockCartRepository
│   ├── MockCacheManager
│   └── MockRemoteDataSource
├── CatalogViewModelTests
├── CartViewModelTests
├── ProductDetailViewModelTests
├── SettingsViewModelTests
├── ProductRepositoryTests
├── CartRepositoryTests
└── ProductUpsertActorTests
```

### Main components / layers

| Layer | Technology | Responsibility |
|-------|-----------|---------------|
| View | SwiftUI | Declarative UI, zero business logic |
| ViewModel | `@Observable` | State, user intent, async coordination |
| Repository | Protocol + SwiftData | Data fetching, local persistence, cache |
| Persistence actor | `@ModelActor` | Background SwiftData upserts off the main thread |
| Composition service | `ClearAllDataService` | Orchestrates multi-repository clearing at the app level |
| Network | CoreNetwork SPM | Generic async/await HTTP client |

### Alternatives considered and discarded

- **TCA (The Composable Architecture)** — powerful but heavyweight for a self-contained assessment; the added boilerplate would have slowed feature delivery without a proportional benefit at this scale.
- **Combine** — superseded by `@Observable` + async/await in Swift 5.9+; mixing both would have added noise.
- **`@StateObject` / `ObservableObject`** — the older SwiftUI observation model; replaced entirely by `@Observable` which avoids property-level `@Published` declarations and reduces unnecessary re-renders.

---

## Technical Decisions

### UI Framework — SwiftUI

SwiftUI was chosen for its tight integration with `@Observable`, SwiftData, and the iOS 18/26 APIs (new `TabView` with typed selection, `ContentUnavailableView`, `.symbolEffect`). UIKit would have required manual data binding and offered no advantage here.

### State management — `@Observable`

Swift's `@Observable` macro (Swift 5.9+) is used throughout all ViewModels. It provides fine-grained dependency tracking at the property level — only the view body paths that actually read a changed property re-render. This is more efficient than `ObservableObject`, which invalidates the entire view on any `@Published` change.

### Navigation — NavigationStack + TabView

- `TabView` with typed `Tab` values (iOS 26+) with a backwards-compatible fallback for iOS 18–25.
- `NavigationStack` with `NavigationLink(value:)` inside each tab for type-safe, value-driven navigation.
- Cart is presented modally (`sheet`) from the catalog toolbar, keeping navigation stacks clean.

### Data persistence — SwiftData

SwiftData was chosen over CoreData for its Swift-native API and direct integration with SwiftUI. Two `@Model` classes are persisted: `Product` (catalog cache) and `CartItem` (shopping cart).

#### Background persistence with `@ModelActor`

Network responses are written to SwiftData on a dedicated background actor (`ProductUpsertActor`) to avoid blocking the main thread during pagination. A `Sendable` value type (`ProductSnapshot`) bridges data across the actor boundary since `@Model` objects are not `Sendable`.

```
Network response → [ProductSnapshot] (Sendable) → ProductUpsertActor (background)
                                                          ↓ upsert + save
Main context ← fetchByProductIds (targeted IN predicate) ←
```

The main context only performs targeted reads — inserts and saves are entirely off the main thread.

### Networking — CoreNetwork SPM package

All HTTP communication is handled by a local Swift Package (`CoreNetwork`) so the networking layer is fully decoupled from the app. The package provides:

- `ApiClientProtocol` — generic `async throws` interface
- `EndpointProvider` — protocol defining scheme, path, method, headers, body, auth, retry
- `RequestInterceptor` — adapt requests and handle retries (`.retry`, `.retryWithDelay`, `.doNotRetry`)
- `Session` abstraction over `URLSession` for testability

`ProductRepository` depends on `RemoteDataSourceProtocol`, not on `CoreNetwork` directly — the concrete `DummyJsonRemoteDataSource` is the only file that imports `CoreNetwork`, honouring the dependency rule.

### Image caching — `NSCache`

`AsyncImage` was replaced with a custom `CachedAsyncImage` backed by `NSCache<NSURL, UIImage>`. `NSCache` was chosen over a Swift actor-based dictionary for three reasons:

1. **Automatic memory eviction** — the OS reclaims memory under pressure without any manual management.
2. **Synchronous access** — no `await` needed on the hot path; cache hits are instant.
3. **Cost-based eviction** — each image is stored with a byte-accurate cost (`width × height × scale² × 4`), allowing a global 50 MB memory budget (`CachedAsyncImageConfiguration.setMemoryCostLimit`).

`NSCache` is wrapped in a `@unchecked Sendable` class to satisfy Swift 6 concurrency rules; thread safety is guaranteed by `NSCache` internally.

The image download is injectable via an `imageLoader: (URL) async throws -> Data` closure (defaults to `URLSession.shared`), making `CachedAsyncImage` fully testable without network access and decoupled from `URLSession` as a concrete type (DIP).

### Pagination — infinite scroll

The catalog fetches pages of 20 products. A zero-height sentinel `Color.clear` at the bottom of the `LazyVGrid` triggers `loadNextPage()` on `onAppear`. The sentinel is only rendered after `firstLoadCompleted` to prevent a race between the initial load and the first scroll event.

A double-guard pattern (`guard !isLoadingMore, hasMore`) in both `loadNextPage()` and `fetchNextPage()` ensures at most one in-flight request at any time.

### Dependency injection — environment values + protocol injection

`ProductRepositoryProtocol` is injected via a custom SwiftUI `EnvironmentKey`. `CartViewModel` and `SettingsViewModel` are injected via `.environment(_:)` at the `WindowGroup` level. This avoids singletons and makes every ViewModel trivially testable with mock repositories.

Environment key defaults use **Null Object** implementations (`NullProductRepository`, `NullCartRepository`) rather than mocks, keeping production-safe no-op behaviour in the app target. Mocks live exclusively in the test target.

`SettingsViewModel` depends on `any CacheManageable` (a single-method protocol), not the full `ProductRepositoryProtocol` — this is an **ISP** fix that narrows the dependency to exactly what the consumer needs.

### Cache clearing — `ClearAllDataService`

Clearing the cache requires deleting both product and cart data. Previously, `ProductRepository.clearCache()` deleted `CartItem` rows directly — a **SRP** violation (a product repository should not know about cart state).

`ClearAllDataService` is a thin composition struct that holds references to `any CacheManageable` (product side) and `any CartRepositoryProtocol` (cart side), and calls both in sequence. It is wired at the composition root (`ITXEcommerceApp`) and injected into `SettingsViewModel` as `any CacheManageable`. Neither repository is aware of the other.

### Dependency management — SPM only

No CocoaPods or Carthage. `CoreNetwork` is a local package (`./CoreNetwork`). SwiftLint is integrated as an SPM build tool plugin — no separate install step required.

---

## SOLID & Clean Architecture Decisions

A targeted refactor was applied after the initial implementation to resolve concrete SOLID violations. The key changes and their rationale:

### ISP — `CacheManageable` protocol

`ProductRepositoryProtocol` originally included `clearCache()`. `SettingsViewModel` only ever called that one method but was forced to depend on the entire repository interface (four fetch methods it never used). Extracting `CacheManageable` (a single-method protocol) narrows the dependency to exactly what is needed, and makes the test mock for `SettingsViewModelTests` trivial — one method instead of five.

### SRP — `ClearAllDataService`

`ProductRepository.clearCache()` previously deleted both `Product` and `CartItem` rows. A repository for products has no business reason to know about cart data. Moving the coordination into `ClearAllDataService` gives each repository a single reason to change.

### DIP — `RemoteDataSourceProtocol`

`ProductRepository` was decoupled from the concrete `DummyJsonRemoteDataSource` by introducing `RemoteDataSourceProtocol`. The repository now depends on an abstraction; `DummyJsonRemoteDataSource` is only instantiated in the composition root. This enabled repository-level unit tests (`ProductRepositoryTests`) with a `MockRemoteDataSource` injected at construction time.

### DIP — injectable `imageLoader` in `CachedAsyncImage`

`URLSession.shared` was hard-coded inside `CachedAsyncImage.load()`. The closure is now an init parameter with a sensible default, enabling tests and previews to inject a stub without real network calls.

### Layer boundary — `ProductCategory+Color`

The `SwiftUI.Color` mapping extension for `ProductCategory` was located in `Model/`, introducing a compile-time `SwiftUI` dependency in the domain layer. It was moved to `Scenes/Common/`, where presentation-only code belongs.

### Null Objects as environment defaults

`MockProductRepository` (and `MockCartRepository`) were previously compiled into the app target as the default `EnvironmentKey` values. Mock implementations belong in the test target. Null Objects replace them: safe, no-op, production-compiled defaults that return empty results without importing test infrastructure.

---

## Trade-offs and Compromises

### Deliberate trade-offs in the SOLID refactor

**Use-case layer (Phase 5 — deferred)**

Extracting dedicated use-case objects (`FilterProductsUseCase`, `FetchProductPageUseCase`, `CartUseCase`) was evaluated and intentionally skipped. The codebase is a single-module app of moderate size; the ViewModels are already well-tested and the business rules are straightforward. Adding a use-case layer at this stage would introduce indirection without immediate payoff. The known SRP residue is:

- `CatalogViewModel` still owns filter / sort / pagination logic in addition to UI state.
- `CartViewModel` still owns stock enforcement and checkout orchestration.

This can be extracted incrementally when the rules grow in complexity or need to be shared across multiple ViewModels.

**SwiftData `@Model` as the domain model (Phase 7 — deliberate design choice)**

A textbook Clean Architecture would introduce plain domain value types (`struct ProductItem`, `struct CartEntry`) and map to/from SwiftData `@Model` objects inside the repository. This was evaluated and intentionally skipped:

- SwiftData is designed by Apple to flow `@Model` objects directly into SwiftUI views — `@Query` requires `@Model` types and cannot operate on plain structs.
- `@Model` synthesises `@Observable`, making models first-class SwiftUI citizens by design.
- The "swap the persistence layer" argument does not apply: SwiftData is a first-party Apple framework with near-zero replacement risk.
- A mapping layer would be pure boilerplate with no behavioural difference.

**Architectural position adopted:** SwiftData `@Model` types *are* the domain model in this app. The repository layer provides the testability boundary. This is a defensible, framework-aligned position — not a compromise. The remaining theoretical violation is that `Product` and `CartItem` have a compile-time dependency on the SwiftData framework.

**Dead endpoint cases in `ServiceProvider`**

`DummyJsonEndpointProvider` still contains `case getCategories` and `case getCategoriesByName(name:)`. These cases are not called by any production code. Removing them was deprioritised in favour of higher-impact architectural changes. They carry no runtime cost and can be removed in a cleanup pass.

### Other trade-offs

- **UserDefaults for settings persistence.** Sufficient for the current settings (theme, language), but a production app with more complex settings would benefit from a dedicated settings repository abstraction.
- **No offline-first guarantee.** If the app is launched for the first time without network access and the SwiftData cache is empty, the catalog will be empty.

### What I would do differently with more time

- **Coordinator / Router pattern** — for a larger app, a dedicated routing layer would decouple navigation from ViewModels more cleanly.
- **Snapshot testing** — add `swift-snapshot-testing` to catch visual regressions on product cards and detail views.
- **Accessibility** — audit with VoiceOver and Dynamic Type; the current implementation lacks explicit accessibility labels on several custom components.
- **HTTP caching** — add `ETag` / `Cache-Control` support in `CoreNetwork` instead of manual SwiftData invalidation.

### What I would change for a production app

- Instrument with OSLog and MetricKit for performance and crash observability.
- Add CI (GitHub Actions) running SwiftLint, unit tests, and snapshot tests on every PR.
- Add a proper caching layer with HTTP `ETag` / `Cache-Control` support in `CoreNetwork`.
- Harden `CartRepository` error recovery for corrupt SwiftData state.

### What was prioritised and why

Core product browsing, cart, and persistence were prioritised because they form the primary user journey. Polish (animations, empty states, image caching, infinite scroll) was added incrementally as the foundation was stable. The SOLID refactor was applied last, once the feature set was stable enough to refactor safely.

---

## Setup Instructions

### Requirements

| Tool | Version |
|------|---------|
| Xcode | 26.2 beta+ |
| iOS Deployment Target | 18.0+ |
| Swift | 6.2 |

### How to run

1. Clone the repository.
2. Open `ITXEcommerce.xcodeproj` in Xcode.
3. Select the **ITXEcommerce-Stage** or **ITXEcommerce-Prod** scheme.
4. Choose a simulator or device running iOS 18+.
5. Press **Run** (⌘R).

No additional configuration is required. The app fetches data from the public `dummyjson.com` API; no API key is needed.

### How to run tests

```
⌘U  — run all tests in Xcode
```

Or from the terminal:

```bash
xcodebuild test \
  -project ITXEcommerce.xcodeproj \
  -scheme ITXEcommerce-Stage \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Testing Strategy

### What was tested and why

Unit tests cover ViewModels (all business logic), repositories (data flow and persistence), and the background upsert actor. Views are declarative and have no logic to test independently.

| Test suite | What it covers |
|-----------|----------------|
| `CatalogViewModelTests` | Pagination state machine, load guards, category filter, search by title, sort, error handling |
| `CartViewModelTests` | Add/remove/quantity, stock limits, total price calculation, checkout flow, error states |
| `ProductDetailViewModelTests` | Initial state, image index, cart interaction flags |
| `SettingsViewModelTests` | UserDefaults persistence, clear cache success/failure, dismiss handlers, enum computed properties |
| `ProductRepositoryTests` | Remote fetch, SwiftData persistence, skip/limit forwarding, category filtering, `clearCache` scope |
| `CartRepositoryTests` | Add, remove, quantity update, clear, persistence |
| `ProductUpsertActorTests` | Background upsert correctness, deduplication, field updates |

### Testing approach

- **Swift Testing** framework throughout (no XCTest in unit tests).
- Each test file is `@MainActor` to match the `@MainActor`-bound ViewModels and repositories.
- `@discardableResult Task` return values on async ViewModel methods allow tests to `await task.value` for deterministic completion without `sleep`.
- Mock repositories (`MockProductRepository`, `MockCartRepository`, `MockCacheManager`, `MockRemoteDataSource`) live exclusively in the test target and are injected via protocol.
- Failing variants (`FailingCartRepository`, `FailingClearCacheRepository`) are defined inline in each test file.
- `ProductRepositoryTests` uses an in-memory `ModelContainer` and a `MockRemoteDataSource` — repository behaviour is tested end-to-end through SwiftData without touching the network.
- `SettingsViewModelTests.init()` removes the relevant `UserDefaults` keys before each test to prevent state pollution between runs.
- `SettingsViewModelTests` injects `MockCacheManager` (a single-method `CacheManageable` conformance) — the narrow ISP protocol means the mock is a one-liner with no stub overhead.

### What would be tested additionally in production

- **Snapshot tests** — product card, cart row, and empty state views across light/dark/dynamic-type configurations.
- **Integration tests** — real `ProductRepository` against a local HTTP stub to validate end-to-end SwiftData persistence under real network shapes.
- **UI tests** — happy-path journeys (browse → add to cart → checkout) using `XCUITest`.
- **Performance tests** — scroll performance under large catalogs using `XCTMetric`.

---

## Known Limitations

- **Language change requires app restart** — `.environment(\.locale, ...)` propagates at the SwiftUI environment level but does not update system-rendered strings (e.g., date formatters). A full restart ensures consistency.
- **No offline-first guarantee** — if the app is launched for the first time without network access and the SwiftData cache is empty, the catalog will be empty with no cached data to fall back on.
- **iOS 26 only features** — the typed `Tab` API in `RootView` is gated behind `#available(iOS 26.0, *)`. The fallback `TabView` on iOS 18–25 works correctly but does not support programmatic tab selection via `RootViewModel`.
- **Dead endpoint cases** — `DummyJsonEndpointProvider` contains `case getCategories` and `case getCategoriesByName(name:)` which are not used by any production code path.
- **SwiftData `@Model` in domain layer** — `Product` and `CartItem` import SwiftData, so the domain has a compile-time dependency on the persistence framework. This is a deliberate design decision (see Trade-offs above) aligned with SwiftData's SwiftUI-first philosophy.
