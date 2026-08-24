import '../../domain/books/book.dart';

enum LibrarySort { recentlyAdded, title, rating, finishedDate }

extension LibrarySortCopy on LibrarySort {
  String get label {
    switch (this) {
      case LibrarySort.recentlyAdded:
        return 'Recently Added';
      case LibrarySort.title:
        return 'Title';
      case LibrarySort.rating:
        return 'Rating';
      case LibrarySort.finishedDate:
        return 'Finished Date';
    }
  }
}

List<Book> sortLibraryBooks(List<Book> books, LibrarySort sort) {
  final sorted = [...books];
  switch (sort) {
    case LibrarySort.recentlyAdded:
      return sorted;
    case LibrarySort.title:
      sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return sorted;
    case LibrarySort.rating:
      sorted.sort((a, b) => (b.rating ?? -1).compareTo(a.rating ?? -1));
      return sorted;
    case LibrarySort.finishedDate:
      sorted.sort((a, b) {
        final aDate = a.finishedAt;
        final bDate = b.finishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return sorted;
  }
}
