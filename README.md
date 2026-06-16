# One Piece TCG Deck Builder

A cross-platform Flutter app for building and managing decks for the **One Piece Trading Card Game (OPTCG)**. Search cards, construct decks, validate them against official rules, and keep track of your collection — all in one place.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

## Features

- **Card Search** — Browse and filter cards by name, color, type, cost, or effect
- **Deck Builder** — Add cards to decks with a tap and stay within the official card limits
- **Deck Validation** — Automatically checks your deck follows One Piece TCG rules (card counts, Don!! requirements, leader restrictions)
- **Card Previews** — View full-sized card art and detailed card info
- **Save & Export** — Save decks locally and export or share them via deck codes

## Screenshots

> _Add screenshots here_

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Platforms:** Android, iOS, Web, Windows, macOS, Linux
- **Card Data:** [Add your data source here — e.g. official API, custom scraper]

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or newer)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- Android Studio or VS Code with the Flutter extension

### Installation

```bash
# Clone the repository
git clone https://github.com/JasonMarquez56/optcg-deck-builder.git
cd optcg-deck-builder

# Install dependencies
flutter pub get

# Run the app
flutter run
```

To run on a specific platform:

```bash
flutter run -d android   # Android
flutter run -d ios       # iOS (requires macOS)
flutter run -d chrome    # Web
flutter run -d windows   # Windows
```

## Project Structure

```
lib/           # Main Dart source code
assets/        # Images, fonts, card data
android/       # Android-specific config
ios/           # iOS-specific config
web/           # Web-specific config
windows/       # Windows-specific config
macos/         # macOS-specific config
linux/         # Linux-specific config
test/          # Unit and widget tests
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

> One Piece TCG and all related card images are property of Bandai. This project is unofficial and not affiliated with Bandai.
