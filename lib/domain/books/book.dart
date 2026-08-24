import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'book_rules.dart';
import 'book_status.dart';

class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    int currentPage = 0,
    this.totalPages,
    this.genre = 'Uncategorized',
    this.rating,
    this.review,
    this.startedAt,
    this.finishedAt,
    this.coverUri,
    this.coverColor = AppColors.defaultCover,
    this.coverAccent = AppColors.defaultCoverAccent,
    this.coverIcon = Icons.auto_stories_rounded,
  }) : currentPage = BookRules.clampProgressPage(
          currentPage,
          totalPages: totalPages,
        );

  final int id;
  String title;
  String author;
  BookStatus status;
  int currentPage;
  int? totalPages;
  String genre;
  double? rating;
  String? review;
  DateTime? startedAt;
  DateTime? finishedAt;
  String? coverUri;
  Color coverColor;
  Color coverAccent;
  IconData coverIcon;

  double? get progress {
    return BookRules.progressRatio(
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }

  Book copyWith({
    BookStatus? status,
    int? currentPage,
    int? totalPages,
    double? rating,
    String? review,
    DateTime? finishedAt,
    String? coverUri,
  }) {
    final nextTotalPages = totalPages ?? this.totalPages;
    return Book(
      id: id,
      title: title,
      author: author,
      status: status ?? this.status,
      currentPage: BookRules.clampProgressPage(
        currentPage ?? this.currentPage,
        totalPages: nextTotalPages,
      ),
      totalPages: nextTotalPages,
      genre: genre,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      coverUri: coverUri ?? this.coverUri,
      coverColor: coverColor,
      coverAccent: coverAccent,
      coverIcon: coverIcon,
    );
  }
}
