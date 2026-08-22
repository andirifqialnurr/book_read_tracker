# Shelf — Book Read Tracker

Flutter UI prototype based on `02-book-read-tracker-flutter-PRD(1).md`.

## Run

After extracting the archive, generate the platform folders once (the current
workspace only contains the design source):

```bash
flutter create .
flutter pub get
flutter run
```

The prototype is dependency-free beyond Flutter. It demonstrates the main mobile
flows with in-memory sample data:

- Home with currently reading, yearly goal, and recently finished books
- Library search, filters, sorting, and cover fallback states
- Add book form
- Book detail, progress update, and finish/review sheet
- Local reading statistics
- Light/dark mode toggle

The `Book` model and callbacks are intentionally kept separate from the widgets
so the in-memory repository can later be replaced with SQLite/sqflite without
changing the visual layer.
