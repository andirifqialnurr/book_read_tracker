import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';

class BookMapper {
  const BookMapper._();

  static Book fromRow(Map<String, Object?> row) {
    return Book(
      id: row['id'] as int,
      title: row['title'] as String,
      author: row['author'] as String? ?? 'Unknown author',
      status: _statusFromDb(row['status'] as String?),
      currentPage: row['current_page'] as int? ?? 0,
      totalPages: row['total_pages'] as int?,
      genre: row['genre'] as String? ?? 'Uncategorized',
      rating: (row['rating'] as num?)?.toDouble(),
      review: row['review'] as String?,
      startedAt: _dateFromDb(row['started_at'] as String?),
      finishedAt: _dateFromDb(row['finished_at'] as String?),
      coverUri: row['cover_uri'] as String?,
      coverColor: _colorFromDb(
        row['cover_color'] as String?,
        fallback: AppColors.defaultCover,
      ),
      coverAccent: _colorFromDb(
        row['cover_accent'] as String?,
        fallback: AppColors.defaultCoverAccent,
      ),
      coverIcon: _iconFromDb(row['cover_icon'] as String?),
    );
  }

  static Map<String, Object?> toInsertRow(Book book, {DateTime? now}) {
    final timestamp = _dateToDb(now ?? DateTime.now());
    return {
      'title': book.title,
      'author': book.author,
      'cover_uri': book.coverUri,
      'cover_color': _colorToDb(book.coverColor),
      'cover_accent': _colorToDb(book.coverAccent),
      'cover_icon': _iconToDb(book.coverIcon),
      'total_pages': book.totalPages,
      'current_page': book.currentPage,
      'status': book.status.name,
      'genre': book.genre,
      'publication_year': null,
      'started_at': _dateToDbOrNull(book.startedAt),
      'finished_at': _dateToDbOrNull(book.finishedAt),
      'rating': book.rating,
      'review': book.review,
      'created_at': timestamp,
      'updated_at': timestamp,
    };
  }

  static Map<String, Object?> toUpdateRow(Book book, {DateTime? now}) {
    return {
      'title': book.title,
      'author': book.author,
      'cover_uri': book.coverUri,
      'cover_color': _colorToDb(book.coverColor),
      'cover_accent': _colorToDb(book.coverAccent),
      'cover_icon': _iconToDb(book.coverIcon),
      'total_pages': book.totalPages,
      'current_page': book.currentPage,
      'status': book.status.name,
      'genre': book.genre,
      'started_at': _dateToDbOrNull(book.startedAt),
      'finished_at': _dateToDbOrNull(book.finishedAt),
      'rating': book.rating,
      'review': book.review,
      'updated_at': _dateToDb(now ?? DateTime.now()),
    };
  }

  static DateTime? _dateFromDb(String? value) {
    if (value == null) return null;
    return DateTime.parse(value).toLocal();
  }

  static String? _dateToDbOrNull(DateTime? value) {
    if (value == null) return null;
    return _dateToDb(value);
  }

  static String _dateToDb(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  static BookStatus _statusFromDb(String? value) {
    return BookStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BookStatus.wantToRead,
    );
  }

  static Color _colorFromDb(String? value, {required Color fallback}) {
    if (value == null || value.isEmpty) return fallback;
    final normalized = value.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return fallback;
    return Color(0xff000000 | parsed);
  }

  static String _colorToDb(Color color) {
    final rgb = color.toARGB32() & 0x00ffffff;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static IconData _iconFromDb(String? value) {
    return switch (value) {
      'auto_awesome' => Icons.auto_awesome_rounded,
      'gamepad' => Icons.gamepad_rounded,
      'nightlight' => Icons.nightlight_round,
      'center_focus_strong' => Icons.center_focus_strong_rounded,
      'spa' => Icons.spa_rounded,
      _ => Icons.auto_stories_rounded,
    };
  }

  static String _iconToDb(IconData icon) {
    if (icon == Icons.auto_awesome_rounded) return 'auto_awesome';
    if (icon == Icons.gamepad_rounded) return 'gamepad';
    if (icon == Icons.nightlight_round) return 'nightlight';
    if (icon == Icons.center_focus_strong_rounded) {
      return 'center_focus_strong';
    }
    if (icon == Icons.spa_rounded) return 'spa';
    return 'auto_stories';
  }
}
