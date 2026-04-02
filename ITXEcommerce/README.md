# ITXEcommerce

**Author:** Marcos A. González Piñeiro

A modern iOS ecommerce application built with Swift 6, SwiftUI, and SwiftData. It demonstrates a production-grade architecture applied at assessment scale — clean layer separation, SOLID principles, full Swift 6 strict-concurrency compliance, and a comprehensive test suite.

---

## Architecture Overview

The app follows **MVVM with a Repository pattern** as the data layer, structured around Clean Architecture principles. Every layer depends only on protocols, never on concrete implementations below it.

### Dependency flow

```
CoreNetwork (SPM)          ← isolated local package, no app imports
    └─ ApiClientProtocol
         └─ DummyJsonRemoteDataSource : RemoteDataSourceProtocol
              └─ ProductRepository : ProductRepositoryProtocol, CacheManageable
              └─ CartRepository   : CartRepositoryProtocol
                   └─ CatalogViewModel / CartViewModel / SettingsViewModel
                        └─ SwiftUI Views
```

The composition root (`ITXEcommerceApp`) is the only place concrete types are assembled. Everything downstream works exclusively against protocols.

### Pattern choice and reasoning

**MVVM** maps naturally onto SwiftUI's reactive model: Views observe `@Observable` ViewModels and re-render on state changes. Business logic and side-effects live exclusively in ViewModels; Views are declarative and logic-free.

**Repository pattern** provides the testability boundary between presentation and persistence. ViewModels receive a protocol; the SwiftData implementation is invisible to them.

### Code organisation

```
ITXEcommerce/
├── App/                            # Entry point, DI wiring, build configuration
│   └── Configuration/              # EnvironmentManager (staging / production)
├── Model/                          # SwiftData @Model classes + network DTOs
│   ├── Product.swift               # @Model, #Unique constraint on productId
│   ├── CartItem.swift              # @Model, optional Product relationship
│   ├── ProductsDTO.swift           # Network response shapes (Codable)
│   └── ProductSortOption.swift
├── Repositories/                   # Protocol-backed data layer
│   ├── ProductRepositoryProtocol   # fetch variants
│   ├── CartRepositoryProtocol      # CRUD + clear
│   ├── CacheManageable             # Narrow ISP protocol: clearCache() only
│   ├── ProductRepository           # SwiftData + background upsert
│   ├── CartRepository              # SwiftData main-context CRUD
│   ├── ProductUpsertActor          # @ModelActor for background writes
│   ├── RemoteDataSourceProtocol    # Network boundary
│   ├── ClearAllDataService         # SRP composition: product + cart clear
│   ├── NullProductRepository       # Null Object — env key default
│   ├── NullCartRepository          # Null Object — env key default
│   └── NullCacheManageable         # Null Object — env key default
├── Services/                       # Concrete remote data source + endpoints
│   ├── DummyJsonRemoteDataSource
│   └── ServiceProvider             # DummyJsonEndpointProvider
├── Scenes/
│   ├── Root/                       # Tab navigation + launch screen
│   ├── Catalog/                    # Product grid, pagination, sort, search
│   ├── ProductDetail/              # Gallery, info, metadata, add-to-cart
│   ├── Cart/                       # Cart list, quantity controls, checkout
│   ├── Settings/                   # Theme, language, cache management
│   ├── QuickStart/                 # In-app README renderer
│   └── Common/                     # Shared components + extensions
└── Tools/                          # View extensions (errorAlert)

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

### Layer responsibilities

| Layer | Technology | Responsibility |
|-------|-----------|---------------|
| View | SwiftUI | Declarative UI, zero business logic |
| ViewModel | `@Observable` | UI state, user intent, async coordination |
| Repository | Protocol + SwiftData | Data access, local persistence, cache |
| Persistence actor | `@ModelActor` | Background SwiftData upserts off main thread |
| Composition service | `ClearAllDataService` | Multi-repository orchestration at app level |
| Remote data source | `RemoteDataSourceProtocol` | Network boundary; `CoreNetwork` imports stop here |
| Network | CoreNetwork SPM | Generic async/await HTTP client |

### Alternatives considered and discarded

- **TCA (The Composable Architecture)** — Powerful but heavyweight at this scale; boilerplate cost outweighs benefit for a focused assessment app.
- **Combine** — Superseded by `@Observable` + async/await in Swift 5.9+. Mixing both would add noise.
- **`@StateObject` / `ObservableObject`** — Replaced entirely by `@Observable`, which provides fine-grained property-level change tracking and avoids `@Published` declarations.
- **UIKit** — No UIKit in the app target. SwiftData, `@Observable`, and the iOS 26 `Tab` API all integrate natively with SwiftUI.

---

## Technical Decisions

### Swift 6 and strict concurrency

The project is configured at the maximum available safety level:

| Setting | Value |
|---|---|
| Swift Language Version | 6.0 |
| Strict Concurrency | `complete` |
| Default Actor Isolation | `MainActor` |
| Upcoming Features | `MemberImportVisibility`, `InferIsolatedConformances`, `NonisolatedNonsendingByDefault` |

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` means all app-target types are MainActor-isolated by default, which matches the SwiftUI/SwiftData usage pattern throughout. The project builds with zero concurrency warnings under this configuration.

### State management — `@Observable`

`@Observable` (Swift 5.9+) is used throughout all ViewModels. It provides fine-grained dependency tracking at the property level — only the view body paths that actually read a changed property re-render. No `@Published`, no `@StateObject`, no Combine publishers.

### Navigation — NavigationSplitView + NavigationStack + TabView

- **Catalog**: `NavigationSplitView` with `.balanced` style — primary column shows the product grid; detail column shows `WelcomeView` on iPad and navigated product detail on both platforms. `navigationDestination(for: Product.self)` handles type-safe, value-driven navigation.
- **Cart**: Presented as a `sheet` from the catalog toolbar, with its own `NavigationStack` for the close button. This keeps catalog navigation stacks clean.
- **Tabs**: iOS 26 typed `Tab` API with `AppTabConfig` enum selection, gated by `#available(iOS 26.0, *)`. A structured `tabItem` fallback covers iOS 18.

### Data persistence — SwiftData

Two `@Model` classes are persisted: `Product` (catalog cache) and `CartItem` (shopping cart). `Product` uses `#Unique<Product>([\.productId])` to enforce upsert semantics at the database level.

#### Background persistence with `@ModelActor`

Network responses are written to SwiftData on a dedicated background actor to avoid blocking the main thread during pagination:

```
Network response
    → [ProductSnapshot] (Sendable value type — bridges actor boundary)
        → ProductUpsertActor (@ModelActor, background context)
            → batch fetch existing → upsert or insert → save
                → main context fetchByProductIds (targeted IN predicate)
```

`ProductSnapshot` is a plain `Sendable` struct that carries data across the actor boundary, since `@Model` objects are not `Sendable`. The upsert builds a `[String: Product]` dictionary from a single batch fetch before iterating — O(1) lookup per product rather than N individual queries.

**SwiftData `@Model` types are the domain model.** Introducing a mapping layer to plain domain structs was evaluated and rejected (see Trade-offs). The repository layer provides the testability boundary.

### Networking — CoreNetwork SPM package

All HTTP communication is handled by a local Swift Package (`./CoreNetwork`), decoupling the networking layer from the app at the module level. The package exposes:

- `ApiClientProtocol` — generic `async throws` request interface
- `EndpointProvider` — scheme, host, path, method, headers, body, auth, retry
- `RequestInterceptor` — `.retry`, `.retryWithDelay`, `.doNotRetry` decisions
- `Session` abstraction over `URLSession`

`ProductRepository` depends on `RemoteDataSourceProtocol`, not `CoreNetwork` directly. Only `DummyJsonRemoteDataSource` imports `CoreNetwork`. The app target has no compile-time dependency on HTTP internals.

### Image caching — `NSCache` with injectable loader

`CachedAsyncImage` replaces `AsyncImage` with an `NSCache<NSURL, UIImage>` backing store. Reasons for `NSCache` over a custom actor-based dictionary:

1. **Automatic memory pressure eviction** — OS reclaims memory without manual management.
2. **Synchronous hot-path access** — cache hits require no `await`.
3. **Cost-based eviction** — each image is stored with an accurate byte cost (`width × height × scale² × 4`), allowing a 50 MB global budget set in the composition root.

The image download is an injectable `(URL) async throws -> Data` closure (defaulting to `URLSession.shared`), decoupling the view from the concrete transport layer and making it fully testable.

### Pagination — infinite scroll

The catalog loads pages of 20 products. A zero-height `Color.clear` sentinel at the bottom of `LazyVGrid` triggers `loadNextPage()` on `onAppear`. The sentinel only renders after `firstLoadCompleted` to prevent a race between initial load and the first scroll event.

A double-guard pattern in both `loadNextPage()` (the public entry point) and `fetchNextPage()` (the execution site) ensures at most one in-flight request regardless of how many concurrent scroll events arrive.

### Dependency injection — environment values + composition root

- `ProductRepositoryProtocol` is injected via a custom `@Entry` `EnvironmentKey`.
- `CartViewModel` and `SettingsViewModel` are injected via `.environment(_:)` at `WindowGroup` level.
- Environment key defaults use **Null Object** implementations — safe no-ops compiled into the app target. Mock implementations live exclusively in the test target.

### Cache clearing — `ClearAllDataService`

Clearing the cache clears both product and cart data. `ClearAllDataService` is a thin composition struct that sequences both operations; neither repository is aware of the other. It is injected into `SettingsViewModel` as `any CacheManageable`.

```
SettingsViewModel → ClearAllDataService → ProductRepository.clearCache()
                                        → CartRepository.clear()
```

---

## SOLID & Clean Architecture Decisions

A targeted refactor applied these principles after the initial implementation.

### ISP — `CacheManageable`

`ProductRepositoryProtocol` originally included `clearCache()`. `SettingsViewModel` depended on the full protocol despite never calling any fetch method. Extracting `CacheManageable` (one method) narrows the dependency to exactly what the consumer needs, and makes the test mock a one-liner.

### SRP — `ClearAllDataService`

`ProductRepository.clearCache()` originally deleted both `Product` and `CartItem` rows. A product repository has no reason to know about cart state. Moving the coordination to `ClearAllDataService` gives each repository a single reason to change.

### DIP — `RemoteDataSourceProtocol`

`ProductRepository` was decoupled from `DummyJsonRemoteDataSource` by introducing a protocol at the network boundary. This enabled repository-level unit tests with `MockRemoteDataSource` injected at construction time — the repository is now tested without any network involvement.

### DIP — injectable `imageLoader` in `CachedAsyncImage`

`URLSession.shared` was previously hard-coded in the image loading path. The closure is now an init parameter with a sensible default, enabling tests and previews to inject a stub.

### Layer boundary — `ProductCategory+Color`

The `SwiftUI.Color` mapping extension for `ProductCategory` originally lived in `Model/`, adding a compile-time `SwiftUI` import to the domain layer. It was moved to `Scenes/Common/` where presentation-only code belongs.

### Null Objects as environment defaults

`MockProductRepository` and `MockCartRepository` were previously compiled into the app target as `EnvironmentKey` defaults. They were replaced with `NullProductRepository` and `NullCartRepository` — production-safe no-ops that return empty results.

---

## Trade-offs and Compromises

### Enpoint usage — intentionally deferred

Endpoint usage mainly depends on `GET /products?limit=20&skip=0` thank you to local cache is not necessary to make extra requests since all required information is already available. 

Implemented and used endpoints:

```
GET /products?limit=20&skip=0
```

Implemented and skipped (but ready to use) endpoints:

```
GET /products/{id}
GET /products/search?q={query}
GET /products/categories
GET /products/category/{category}
```

**Skipped logic:** 
To display product detailed information we would inject into `ProductDetailView` a `productId` instead of a `Product` object with all required data, and on view appear ` ProductDetailViewModel` will fetch product information using injected `ProductRepository` and its `fetchProduct(id: String)` functionallity.

### Use-case layer — intentionally deferred

Extracting dedicated use-case objects (`FilterProductsUseCase`, `FetchProductPageUseCase`, `CartUseCase`) was evaluated and skipped. The ViewModels are already well-tested and the business rules are straightforward enough that an extra indirection layer has no payoff today.

**Known SRP residue:**
- `CatalogViewModel` owns filter, sort, and pagination logic in addition to UI state.
- `CartViewModel` owns stock enforcement and checkout orchestration.

Extraction path is clear when rule complexity grows or when logic needs to be shared across multiple ViewModels.

### SwiftData `@Model` as the domain model — deliberate design choice

A textbook Clean Architecture would map `@Model` objects to plain domain value types inside repositories. This was evaluated and rejected:

- SwiftData is designed to flow `@Model` objects directly into SwiftUI views — `@Query` requires `@Model` types.
- `@Model` synthesises `@Observable`, making models first-class SwiftUI citizens.
- A mapping layer would be pure boilerplate with no behavioural difference.
- SwiftData is a first-party Apple framework with near-zero replacement risk.

**Position adopted:** SwiftData `@Model` types *are* the domain model. The repository layer provides the testability boundary. This is framework-aligned, not a compromise.

**Remaining theoretical violation:** `Product` and `CartItem` have a compile-time dependency on `SwiftData`.

### `CartRepositoryProtocol` is synchronous

All cart operations are `throws` but not `async`. This works today because all operations run on the main `ModelContext`. If cart operations ever need a background context (e.g., for CloudKit sync), every protocol method signature and every callsite would need to change. `async throws` at the protocol level would future-proof the interface at zero runtime cost.

### Dead endpoint cases in `ServiceProvider`

`DummyJsonEndpointProvider` contains `case getCategories` and `case getCategoriesByName(name:)`. These are not called by any production code path. They carry no runtime cost and can be removed in a cleanup pass. They are there for the sake of ilustrating functionality.

### What I would do differently with more time

- **`CartRepositoryProtocol` async** — make all cart operations `async throws` to future-proof the persistence layer.
- **Coordinator / Router** — for a larger app, a dedicated routing layer would decouple navigation from ViewModels more cleanly. Or `NavigationPath` for harcoded navigation or deeplinks.
- **Snapshot testing** — add `swift-snapshot-testing` to catch visual regressions on product cards and detail views across light/dark/Dynamic-Type configurations.
- **Improved accessibility** - App fully ready for VoiceOver, Dynamic Type and Color Contrast.
- **CI (GitHub Actions)** — SwiftLint, unit tests, and snapshot tests on every PR.

---

## Setup Instructions

### Requirements

| Tool | Version |
|------|---------|
| Xcode | 26.2 beta+ |
| iOS Deployment Target | 18.0+ |
| Swift | 6.0 |

### How to run

1. Clone the repository.
2. Open `ITXEcommerce.xcodeproj` in Xcode.
3. Select the **ITXEcommerce-STAGE** or **ITXEcommerce-PROD** scheme. (STAGE and PROD behave slightly different)
4. Choose a simulator or device running iOS 18+.
5. Press **Run** (⌘R).

No additional configuration is required. The app fetches data from the public `dummyjson.com` API — no API key needed. The staging scheme starts on the Catalog tab; the production scheme starts on the Quick Start tab.

### Schemes and environments

| Scheme | Starting Tab | `EnvironmentManager.environment` |
|--------|-------------|----------------------------------|
| `ITXEcommerce-STAGE` | Catalog | `.staging` |
| `ITXEcommerce-PROD` | Quick Start | `.production` |

`EnvironmentManager.isStaging` is used in `CartViewModel` error messages to append debug information in staging builds only.

### How to run tests

```
⌘U  — run all tests in Xcode
```

Or from the terminal:

```bash
xcodebuild test \
  -project ITXEcommerce.xcodeproj \
  -scheme ITXEcommerce-STAGE \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Testing Strategy

### Coverage philosophy

Unit tests focus on ViewModels (all business logic), the repository layer (data flow, persistence correctness, cache behaviour), and the background upsert actor. Views are declarative with no logic to test independently.

### Test suites

| Suite | What it covers |
|-------|----------------|
| `CatalogViewModelTests` | Pagination state machine, double-guard, category filter, title search, sort, error handling, column toggle |
| `CartViewModelTests` | Add, remove, quantity increase/decrease, stock limits, total price calculation, checkout, `onDelete`, error states |
| `ProductDetailViewModelTests` | Initial state, image index tracking, cart interaction flags |
| `SettingsViewModelTests` | UserDefaults persistence, clear-cache success/failure, dismiss handlers, enum computed properties |
| `ProductRepositoryTests` | Remote fetch, SwiftData persistence, skip/limit forwarding, category filtering, `clearCache` scope isolation |
| `CartRepositoryTests` | Add/update/remove/clear, quantity enforcement, persistence round-trip |
| `ProductUpsertActorTests` | Background upsert correctness, deduplication, field update on re-fetch |

### Approach

- **Swift Testing** throughout — `@Suite`, `@Test`, `#expect`, `#require`. No XCTest in unit tests.
- Each test struct is `@MainActor` to match ViewModel isolation.
- `@discardableResult Task` on async ViewModel methods allows tests to `await task.value` for deterministic completion without `sleep` or XCTest expectations.
- `ProductRepositoryTests` uses an **in-memory `ModelContainer`** and `MockRemoteDataSource` — the repository is tested end-to-end through real SwiftData without touching the network.
- Mock implementations (`MockProductRepository`, `MockCartRepository`, `MockCacheManager`, `MockRemoteDataSource`) live exclusively in the test target. The app target never compiles test doubles.
- `SettingsViewModelTests` resets relevant `UserDefaults` keys before each test to prevent cross-test state pollution.
- Failing variants (`FailingClearCacheRepository`, `FailingCartRepository`) are defined inline in each test file to keep failures local and readable.

### What would be added for production

- **Snapshot tests** — product card, cart row, and empty state views across light/dark/Dynamic Type.
- **Integration tests** — real `ProductRepository` against a local HTTP stub to validate end-to-end persistence under real network shapes.
- **UI tests** — primary user journey (browse → add to cart → checkout) with `XCUITest`.
- **Performance tests** — scroll performance under large catalogs via `XCTMetric`.

---

## Known Limitations

| Limitation | Detail |
|---|---|
| **No offline-first guarantee** | First launch without network + empty cache = empty catalog |
| **Language change requires restart** | `.environment(\.locale, ...)` does not update system-rendered strings (date formatters etc.) |
| **iOS 26 tab selection** | Programmatic tab selection via `RootViewModel` only works on iOS 26+; iOS 18 fallback is included |
| **Currency hardcoded** | Price display is hardcoded to EUR throughout |
| **Dead endpoint cases** | `DummyJsonEndpointProvider.getCategories` and `.getCategoriesByName` are defined but never called |
| **`@Model` in domain layer** | `Product` and `CartItem` import SwiftData — deliberate design choice (see Trade-offs) |
