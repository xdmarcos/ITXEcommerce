# ITXEcommerce

**Author:** Marcos A. González Piñeiro

A modern iOS ecommerce application built with the latest Apple frameworks and Swift tooling.

---

## Architecture Overview

The app follows **MVVM (Model-View-ViewModel)** with a Repository pattern as the data layer.

### Pattern choice and reasoning

MVVM was chosen because it maps naturally onto SwiftUI's reactive model: Views observe `@Observable` ViewModels and re-render on state changes with no manual binding boilerplate. Business logic and side-effects live exclusively in ViewModels, keeping Views declarative and easy to reason about.

### Code organisation

```
ITXEcommerce/
├── App/                        # Entry point, DI wiring, xcconfig environments
├── Model/                      # SwiftData @Model classes (Product, CartItem)
├── Repositories/               # Protocol-backed data layer + SwiftData persistence
│   ├── ProductRepositoryProtocol / ProductRepository
│   ├── CartRepositoryProtocol  / CartRepository
│   ├── ProductUpsertActor      # Background @ModelActor for SwiftData writes
│   └── Mocks/                  # MockProductRepository, MockCartRepository
├── Scenes/
│   ├── Root/                   # Tab navigation (RootView + RootViewModel)
│   ├── Catalog/                # Product grid with pagination, sort, category filter
│   ├── ProductDetail/          # Full product detail + image gallery + add to cart
│   ├── Cart/                   # Cart list, quantity controls, checkout
│   ├── Settings/               # Theme, language, cache management
│   └── Common/                 # Shared UI components
└── CoreNetwork/                # Local Swift Package — generic HTTP client
```

### Main components / layers

| Layer | Technology | Responsibility |
|-------|-----------|---------------|
| View | SwiftUI | Declarative UI, zero business logic |
| ViewModel | `@Observable` | State, user intent, async coordination |
| Repository | Protocol + SwiftData | Data fetching, local persistence, cache |
| Persistence actor | `@ModelActor` | Background SwiftData upserts off the main thread |
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

### Image caching — `NSCache`

`AsyncImage` was replaced with a custom `CachedAsyncImage` backed by `NSCache<NSURL, UIImage>`. `NSCache` was chosen over a Swift actor-based dictionary for three reasons:

1. **Automatic memory eviction** — the OS reclaims memory under pressure without any manual management.
2. **Synchronous access** — no `await` needed on the hot path; cache hits are instant.
3. **Cost-based eviction** — each image is stored with a byte-accurate cost (`width × height × scale² × 4`), allowing a global 50 MB memory budget (`CachedAsyncImageConfiguration.setMemoryCostLimit`).

`NSCache` is wrapped in a `@unchecked Sendable` class to satisfy Swift 6 concurrency rules; thread safety is guaranteed by `NSCache` internally.

### Pagination — infinite scroll

The catalog fetches pages of 20 products. A zero-height sentinel `Color.clear` at the bottom of the `LazyVGrid` triggers `loadNextPage()` on `onAppear`. The sentinel is only rendered after `firstLoadCompleted` to prevent a race between the initial load and the first scroll event.

A double-guard pattern (`guard !isLoadingMore, hasMore`) in both `loadNextPage()` and `fetchNextPage()` ensures at most one in-flight request at any time.

### Dependency injection — environment values

`ProductRepositoryProtocol` is injected via a custom SwiftUI `EnvironmentKey`. `CartViewModel` and `SettingsViewModel` are injected via `.environment(_:)` at the `WindowGroup` level. This avoids singletons and makes every ViewModel trivially testable with mock repositories.

### Dependency management — SPM only

No CocoaPods or Carthage. `CoreNetwork` is a local package (`./CoreNetwork`). SwiftLint is integrated as an SPM build tool plugin — no separate install step required.

---

## Trade-offs and Compromises

### What trade-offs were made

- **`ProductRepository.fetchPage` falls back to mock data on network failure.** This was intentional for demo reliability, but a production app would surface the error to the user instead of silently degrading.
- **`clearCache` only deletes `Product` rows.** Cart items and user preferences are untouched. A production "clear all data" action would be more comprehensive.
- **No search.** The catalog supports category filter and sort but no full-text search. This would be the next natural feature.
- **UserDefaults for settings persistence.** Sufficient for the current settings (theme, language), but a production app with more complex settings would benefit from a dedicated settings repository abstraction.

### What I would do differently with more time

- **Proper error handling in the repository** — remove the mock fallback, propagate errors, and let the UI handle retry gracefully.
- **Coordinator / Router pattern** — for a larger app, a dedicated routing layer would decouple navigation from ViewModels more cleanly.
- **Snapshot testing** — add `swift-snapshot-testing` to catch visual regressions on product cards and detail views.
- **Accessibility** — audit with VoiceOver and Dynamic Type; the current implementation lacks explicit accessibility labels on several custom components.

### What I would change for a production app

- Replace the `@MainActor` protocol constraint on `ProductRepositoryProtocol` with a fully actor-agnostic interface, enabling repository use from any context.
- Add a proper caching layer with HTTP `ETag` / `Cache-Control` support in `CoreNetwork` instead of manual SwiftData invalidation.
- Instrument with OSLog and MetricKit for performance and crash observability.
- Add CI (GitHub Actions) running SwiftLint, unit tests, and snapshot tests on every PR.

### What was prioritised and why

Core product browsing, cart, and persistence were prioritised because they form the primary user journey. Polish (animations, empty states, image caching, infinite scroll) was added incrementally as the foundation was stable.

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
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Testing Strategy

### What was tested and why

Unit tests focus on ViewModels because that is where all business logic lives. Views are declarative and have no logic to test independently; the Repository layer is tested indirectly through ViewModel tests using mock repositories.

| Test suite | What it covers |
|-----------|----------------|
| `CatalogViewModelTests` | Pagination state machine, load guards, category filter, sort, error handling |
| `CartViewModelTests` | Add/remove/quantity, stock limits, total price calculation, checkout flow, error states |
| `ProductDetailViewModelTests` | Initial state, image index, cart interaction flags |
| `SettingsViewModelTests` | UserDefaults persistence, clear cache success/failure, dismiss handlers, enum computed properties |

### Testing approach

- **Swift Testing** framework throughout (no XCTest in unit tests).
- Each test file is `@MainActor` to match the `@MainActor`-bound ViewModels.
- `@discardableResult Task` return values on async ViewModel methods allow tests to `await task.value` for deterministic completion without `sleep`.
- Mock repositories (`MockProductRepository`, `MockCartRepository`) are injected via protocol; failing variants (`FailingCartRepository`, `FailingProductRepository`, `FailingClearCacheRepository`) are defined inline in each test file.
- `SettingsViewModelTests.init()` removes the relevant `UserDefaults` keys before each test to prevent state pollution between runs.

### What would be tested additionally in production

- **Snapshot tests** — product card, cart row, and empty state views across light/dark/dynamic-type configurations.
- **Integration tests** — real `ProductRepository` against a local mock server (e.g., `Mockolo` or a local HTTP stub) to validate SwiftData persistence end-to-end.
- **UI tests** — happy-path journeys (browse → add to cart → checkout) using `XCUITest`.
- **Performance tests** — scroll performance under large catalogs using `XCTMetric`.

---

## Known Limitations

- **Network fallback to mock data** — when the API is unreachable, `ProductRepository` silently returns static mock products instead of propagating the error. This masks connectivity issues.
- **Language change requires app restart** — `.environment(\.locale, ...)` propagates at the SwiftUI environment level but does not update system-rendered strings (e.g., date formatters). A full restart ensures consistency.
- **No offline-first guarantee** — if the app is launched for the first time without network access and the SwiftData cache is empty, the catalog will be empty.
- **Cart is not persisted across sessions fully tested** — `CartRepository` persists via SwiftData, but error recovery on corrupt state has not been hardened.
- **iOS 26 only features** — the typed `Tab` API in `RootView` is gated behind `#available(iOS 26.0, *)`. The fallback `TabView` on iOS 18–25 works correctly but does not support programmatic tab selection via `RootViewModel`.
