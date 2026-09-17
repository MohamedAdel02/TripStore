# TripStore — E-Commerce iOS Application

An iOS e-commerce app built with SwiftUI that lets users browse products, search with real-time filtering, save favorites, and place local orders with automatic tax and fee calculations. Built using Clean Architecture and the DummyJSON API, it features full offline support, local Realm storage, and complete VoiceOver accessibility.

---

## 📹 Video Walkthrough

> **Watch the full application walkthrough:**

* **App Walkthrough:** 

---

## 📱 Visual Showcase

| Catalogue & Home | Search & Filters | Product Details | Order Confirmation |
| :---: | :---: | :---: | :---: |
| <img src="https://via.placeholder.com/300x600.png?text=Catalogue+Screen" width="220" alt="Catalogue Screen"/> | <img src="https://via.placeholder.com/300x600.png?text=Search+Screen" width="220" alt="Search Screen"/> | <img src="https://via.placeholder.com/300x600.png?text=Product+Details" width="220" alt="Product Details"/> | <img src="https://via.placeholder.com/300x600.png?text=Order+Flow" width="220" alt="Order Flow"/> |

---

## 📁 Repository Structure

```text
TripStore/
├── Core/
│   └── TripStoreApp.swift
├── Helper/
│   ├── Enums/
│   │   ├── AppRoute.swift
│   │   ├── AppTab.swift
│   │   └── ViewState.swift
│   ├── Extension/
│   │   ├── View+Extension.swift
│   │   └── View+Navigation.swift
│   └── ReusableView/
│       ├── AppBackground.swift
│       ├── CategoryChip.swift
│       ├── ChipLabel.swift
│       └── ToastView.swift
├── Models/
│   ├── Category.swift
│   ├── FavoriteObject.swift
│   ├── Order.swift
│   ├── OrderObject.swift
│   └── Product.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Colors.xcassets
├── Screens/
│   ├── AppTabView/
│   │   ├── View/
│   │   │   └── AppTabView.swift
│   │   └── ViewModel/
│   │       └── AppTabViewModel.swift
│   ├── Favorites/
│   │   ├── Repository/
│   │   │   └── FavoritesRepository.swift
│   │   ├── View/
│   │   │   └── FavoritesView.swift
│   │   └── ViewModel/
│   │       └── FavoritesViewModel.swift
│   ├── Home/
│   │   ├── Repository/
│   │   │   └── HomeRepository.swift
│   │   ├── UseCase/
│   │   │   └── HomeUseCase.swift
│   │   ├── View/
│   │   │   ├── HomeView.swift
│   │   │   └── ProductCardView.swift
│   │   └── ViewModel/
│   │       └── HomeViewModel.swift
│   ├── OrderConfirmation/
│   │   ├── View/
│   │   │   └── OrderConfirmationView.swift
│   │   └── ViewModel/
│   │       └── OrderConfirmationViewModel.swift
│   ├── OrderHistory/
│   │   ├── Repository/
│   │   │   └── OrderHistoryRepository.swift
│   │   ├── View/
│   │   │   └── OrderHistoryView.swift
│   │   └── ViewModel/
│   │       └── OrderHistoryViewModel.swift
│   ├── ProductDetails/
│   │   ├── View/
│   │   │   └── ProductDetailsView.swift
│   │   └── ViewModel/
│   │       └── ProductDetailsViewModel.swift
│   ├── Profile/
│   │   ├── View/
│   │   │   └── ProfileView.swift
│   │   └── ViewModel/
│   │       └── ProfileViewModel.swift
│   └── Search/
│       ├── Repository/
│       │   └── SearchRepository.swift
│       ├── UseCase/
│       │   └── SearchUseCase.swift
│       ├── View/
│       │   └── SearchView.swift
│       └── ViewModel/
│           ├── SearchCriteria.swift
│           └── SearchViewModel.swift
├── Services/
│   ├── ErrorHandling/
│   │   └── NetworkError.swift
│   ├── Network/
│   │   ├── NetworkHelper.swift
│   │   └── NetworkManager.swift
│   └── Persistence/
│       └── RealmStore.swift
├── TripStore.xcodeproj
└── TripStoreTests/
    └── TripStoreTests.swift
```

---

## 🏗 Architecture & Separation

The project strictly follows the **Clean MVVM** pattern organized across distinct presentation, domain, and data layers:

* **Models & Persistence Entities:** Domain structures like `Product`, `Category`, and `Order` represent decoupled core models, while `FavoriteObject` and `OrderObject` serve local persistence requirements via **Realm**.
* **Presentation Layer (ViewModels & Views):** ViewModels are constrained to `@MainActor` to guarantee thread-safe state mutations. Views leverage `AppTabView`, `ToastView`, `CategoryChip`, and standard navigation helpers.
* **Services & Repositories:** Network operations are managed through `NetworkManager` and `NetworkHelper` with typed handling via `NetworkError`. Local database interactions are centralized in `RealmStore`.
* **Dependency Injection:** Screen logic is structured around feature repositories (`HomeRepository`, `SearchRepository`, `FavoritesRepository`, `OrderHistoryRepository`) and dedicated use cases (`HomeUseCase`, `SearchUseCase`).

---

## ⚡ Concurrency & Obsolete Search Prevention

* **Debounced Search Input:** Search requests are debounced to avoid unnecessary API queries during continuous user typing.
* **Search Criteria & Race Condition Guards:** `SearchViewModel` manages `SearchCriteria` state to ensure obsolete responses from earlier network calls cannot overwrite fresher search results.
* **MainActor Thread Safety:** UI state updates and screen routing triggers execute exclusively on `@MainActor`.

---

## 💾 Offline Policy & Caching Strategy

* **Realm Persistence:** User favorites (`FavoriteObject`) and order history (`OrderObject`) are persisted using **Realm** via `RealmStore`.
* **Offline Access:** Saved favorites and past orders remain accessible offline regardless of network connection status.

---

## 🛍️ Product Details & Ordering Logic

* **Live Price Calculation:** Order totals calculate live subtotal, service fee, and final total using the following rules:
  $$	ext{Subtotal} = 	ext{Product Price} 	imes 	ext{Quantity}$$
  $$	ext{Service Fee} = 	ext{Subtotal} 	imes 0.05$$
  $$	ext{Final Total} = 	ext{Subtotal} + 	ext{Service Fee}$$
* **Rounding & Stock Protection:** All subtotal and fee totals are rounded precisely to two decimal places. Products with 0 stock cannot be ordered, and user quantity selectors are capped at available stock.
* **Double-Submission Prevention:** Order submit triggers are locked during processing to ensure only one local order record is committed per checkout action.

---

## ♿ Accessibility & Design Parity

* **Dynamic Type Support:** Typography utilizes system styles (`.caption`, `.footnote`, `.subheadline`, `.body`, `.headline`, `.title2`) to scale seamlessly with user settings.
* **VoiceOver Support:** Meaningful accessibility labels and hints are integrated across controls, search fields, category chips, and checkout actions.
* **Feedback Banners (Toasts):** Custom `ToastView` feedback for order updates, favorite toggles, and state changes.

---

## 🧪 Automated Unit Tests

The test suite in `TripStoreTests` covers critical business logic, network mocking, search concurrency, and state management.

### Running Tests
Run tests inside Xcode via **Product > Test** (`Cmd + U`), or via command line:
```bash
xcodebuild test   -project "TripStore.xcodeproj"   -scheme "TripStore"   -destination "platform=iOS Simulator,name=iPhone 17"
```

---

## 🚀 Requirements & Setup

### Requirements
* iOS 16.0+
* Xcode 15.0+
* Swift 5.9+

 ---

### Quick Start
```bash
git clone https://github.com/MohamedAdel02/TripStore.git
cd TripStore
open "TripStore.xcodeproj"
```
Select the **TripStore** scheme, choose an iOS 16+ Simulator, and press `Cmd + R` to run.

---


