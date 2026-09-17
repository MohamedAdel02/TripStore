
An iOS e-commerce app built with SwiftUI that lets users browse products, search with real-time filtering, save favorites, and place local orders with automatic tax and fee calculations. Built using Clean Architecture and the DummyJSON API, it features full offline support, local Realm storage, and complete VoiceOver accessibility.

---

## 📹 Video Walkthrough

> Watch the application in action:

* **App Walkthrough (Part 1):**

https://github.com/user-attachments/assets/05a4b233-bf41-4472-8de5-733b14c421fd

* **App Walkthrough (Part 2):**

https://github.com/user-attachments/assets/0e298ec0-fc33-4ee9-85d1-5e237f6f1a3c

---


## 📱 Visual Showcase

| Catalogue & Home | Search & Filters | Product Details |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/4355fde9-0068-46d0-8266-7f2c4d90af79" width="200" alt="Catalogue & Home" loading="lazy" /> | <img src="https://github.com/user-attachments/assets/50c3398f-1c5e-41fa-91d4-928163051ca2" width="200" alt="Search & Filters" loading="lazy" /> | <img src="https://github.com/user-attachments/assets/b0a97be6-27c4-42ea-9479-c8fd3527f52f" width="200" alt="Product Details" loading="lazy" /> |

| Profile | Favorites | Order History |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/ab10f8bf-3ba9-4e25-abc5-247c41957fe4" width="200" alt="Profile" loading="lazy" /> | <img src="https://github.com/user-attachments/assets/8c3865d8-3fbc-47b3-8682-24dc6e0a6503" width="200" alt="Favorites" loading="lazy" /> | <img src="https://github.com/user-attachments/assets/395d799e-8762-4902-b0bf-0cd972c19dd3" width="200" alt="Order History" loading="lazy" /> |

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


