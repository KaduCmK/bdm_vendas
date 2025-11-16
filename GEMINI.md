# GEMINI.md - Project Overview and Guidelines

This file provides a comprehensive overview of the `bdm_vendas` project, its architecture, and development conventions to be used as instructional context for future interactions.

## Project Overview

`bdm_vendas` is a Flutter application designed for managing sales and orders, likely for a bar or restaurant, as suggested by the name ("vendas" is Portuguese for sales) and the data models (Nota, Cardapio, Cliente).

The application is built with a client-server architecture, using **Firebase** for its backend services, including:
- **Firestore:** As the main database for storing data like notes (`notas`), products (`produtos`), clients (`clientes`), and menu items (`cardapio`).
- **Firebase Authentication:** For user authentication, including anonymous sign-in.
- **Cloud Functions:** The project has a `functions` directory, suggesting the use of serverless functions for backend logic.

The app supports both **Web** and **Android** platforms.

### Architecture and Conventions

The project follows a clean architecture pattern, separating concerns into different layers:

- **State Management:** The app uses the **BLoC (Business Logic Component)** pattern for state management, with `flutter_bloc` and `bloc` packages. There are dedicated BLoCs for each feature domain:
    - `NotaBloc`: Manages the state of notes.
    - `ClienteBloc`: Manages the state of clients.
    - `CardapioBloc`: Manages the state of the menu.
    - `CategoriaBloc`: Manages the state of categories.

- **Data Layer:** The **Repository Pattern** is used to abstract the data sources. For each domain, there is a `repository` interface and its implementation (`repository_impl`), which communicates with Firestore.

- **Navigation:** Navigation is handled by the `go_router` package, providing a declarative routing solution. The routes are defined in `lib/app_router.dart`.

- **Dependency Injection:** The `get_it` package is used as a service locator to provide dependencies, such as repositories, to the BLoCs. The setup is in `lib/service_locator.dart`.

- **Data Models:** The data models are defined in the `lib/models` directory. They use the `equatable` package to allow for value-based comparison.

## Building and Running

This is a standard Flutter project. Use the following commands to run and build the application.

### Running the app (Web)
```bash
flutter run -d chrome
```

### Running the app (Android)
```bash
flutter run -d <your_device_id>
```

### Building the app for production (Web)
```bash
flutter build web
```

### Building the app for production (Android)
```bash
flutter build apk
```
or
```bash
flutter build appbundle
```

### Testing
The project includes a `test` directory, but no specific testing conventions are evident from the file structure alone. To run the existing tests, use:
```bash
flutter test
```

## Development Conventions

- **State Management:** When adding new features, follow the BLoC pattern. Create new events, states, and update the BLoC accordingly.
- **Data Access:** Use the Repository pattern for any new data access requirements. Create a repository interface and its implementation.
- **Navigation:** Use `GoRouter` for navigation. Add new routes to `lib/app_router.dart`.
- **Dependencies:** Use the `get_it` service locator to provide dependencies.
- **Firebase:** The project is heavily reliant on Firebase. Ensure that any new feature that requires backend interaction is implemented with Firebase services in mind. Firestore rules are defined in `firestore.rules` and indexes in `firestore.indexes.json`.
- **Code Style:** The project uses `flutter_lints` for code analysis. Run `flutter analyze` to check for any style issues.
