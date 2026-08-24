import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/core/theme/app_colors.dart';
import 'package:shelf_book_tracker/data/books/book_mapper.dart';
import 'package:shelf_book_tracker/data/goals/reading_goal_mapper.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';

void main() {
  test('BookMapper converts domain books to SQLite rows and back', () {
    final now = DateTime.utc(2026, 8, 24, 12);
    final book = Book(
      id: 7,
      title: 'Mapped Book',
      author: 'Reader',
      status: BookStatus.finished,
      currentPage: 120,
      totalPages: 160,
      genre: 'Fiction',
      rating: 4.5,
      review: 'Useful',
      startedAt: DateTime.utc(2026, 8, 20),
      finishedAt: DateTime.utc(2026, 8, 24),
      coverUri: 'C:\\covers\\mapped-book.jpg',
      coverColor: AppColors.coverTeal,
      coverAccent: AppColors.coverTealAccent,
      coverIcon: Icons.gamepad_rounded,
    );

    final row = BookMapper.toInsertRow(book, now: now);

    expect(row['title'], 'Mapped Book');
    expect(row['status'], 'finished');
    expect(row['cover_uri'], 'C:\\covers\\mapped-book.jpg');
    expect(row['cover_color'], '#426B70');
    expect(row['cover_icon'], 'gamepad');
    expect(row['created_at'], '2026-08-24T12:00:00.000Z');

    final mapped = BookMapper.fromRow({
      'id': 7,
      ...row,
    });

    expect(mapped.id, 7);
    expect(mapped.status, BookStatus.finished);
    expect(mapped.currentPage, 120);
    expect(mapped.coverUri, 'C:\\covers\\mapped-book.jpg');
    expect(mapped.coverColor, AppColors.coverTeal);
    expect(mapped.coverIcon, Icons.gamepad_rounded);
  });

  test('ReadingGoalMapper converts rows to domain goals', () {
    final row = ReadingGoalMapper.toUpsertRow(
      year: 2026,
      targetBooks: 36,
      now: DateTime.utc(2026, 8, 24, 12),
    );

    expect(row['year'], 2026);
    expect(row['target_books'], 36);

    final goal = ReadingGoalMapper.fromRow({
      'id': 1,
      ...row,
    });

    expect(goal.id, 1);
    expect(goal.year, 2026);
    expect(goal.targetBooks, 36);
  });
}
