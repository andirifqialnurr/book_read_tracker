import '../../core/database/app_database.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_repository.dart';
import '../progress/progress_history_dao.dart';
import 'book_dao.dart';
import 'book_mapper.dart';

class SqfliteBookRepository extends BookRepository {
  SqfliteBookRepository(this._appDatabase) : super(const []);

  final AppDatabase _appDatabase;

  @override
  Future<void> load() async {
    final db = await _appDatabase.instance;
    final rows = await BookDao(db).getAllBooks();
    state = rows.map(BookMapper.fromRow).toList();
  }

  @override
  Future<void> addBook(Book book) async {
    final db = await _appDatabase.instance;
    await BookDao(db).insertBook(BookMapper.toInsertRow(book));
    await load();
  }

  @override
  Future<void> updateBook(Book book) async {
    final db = await _appDatabase.instance;
    await db.transaction((txn) async {
      final dao = BookDao(txn);
      final existingRow = await dao.getBookById(book.id);
      final existing = existingRow == null ? null : BookMapper.fromRow(existingRow);
      await dao.updateBook(book.id, BookMapper.toUpdateRow(book));
      if (existing != null && existing.currentPage != book.currentPage) {
        await ProgressHistoryDao(txn).insertProgress(
          bookId: book.id,
          page: book.currentPage,
          recordedAt: DateTime.now(),
        );
      }
    });
    await load();
  }

  @override
  Future<void> deleteBook(int id) async {
    final db = await _appDatabase.instance;
    await BookDao(db).deleteBook(id);
    await load();
  }
}
