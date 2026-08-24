import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/books/book.dart';
import '../../../domain/books/book_status.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    required this.book,
    required this.width,
    required this.height,
    super.key,
  });

  final Book book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final coverUri = book.coverUri;
    if (coverUri != null && coverUri.isNotEmpty) {
      final file = File(coverUri);
      if (file.existsSync()) {
        return Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: book.coverColor.withValues(alpha: .18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _FallbackBookCover(
              book: book,
              width: width,
              height: height,
            ),
          ),
        );
      }
    }

    return _FallbackBookCover(book: book, width: width, height: height);
  }
}

class _FallbackBookCover extends StatelessWidget {
  const _FallbackBookCover({
    required this.book,
    required this.width,
    required this.height,
  });

  final Book book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = _fallbackPalette(book);
    final isCompact = width < 70 || height < 90;
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.color,
            Color.lerp(palette.color, Colors.black, .34)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.color.withValues(alpha: .22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -24,
            child: Container(
              width: isCompact ? 58 : 98,
              height: isCompact ? 58 : 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent.withValues(alpha: .22),
              ),
            ),
          ),
          Positioned(
            bottom: isCompact ? 8 : 14,
            right: isCompact ? 8 : 12,
            child: Icon(
              book.coverIcon,
              color: palette.accent.withValues(alpha: .74),
              size: isCompact ? 18 : 27,
            ),
          ),
          Padding(
            padding: isCompact
                ? const EdgeInsets.fromLTRB(8, 10, 8, 8)
                : const EdgeInsets.fromLTRB(12, 14, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCompact)
                  Text(
                    'SHELF',
                    style: TextStyle(
                      color: palette.accent.withValues(alpha: .8),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                const Spacer(),
                Text(
                  book.title,
                  maxLines: isCompact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 9.5 : 15,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 5),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.accent.withValues(alpha: .86),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CoverPalette _fallbackPalette(Book book) {
    switch (book.status) {
      case BookStatus.wantToRead:
        return const _CoverPalette(
          AppColors.coverTerracotta,
          AppColors.coverTerracottaAccent,
        );
      case BookStatus.reading:
        return const _CoverPalette(
          AppColors.coverIndigo,
          AppColors.coverIndigoAccent,
        );
      case BookStatus.finished:
        return const _CoverPalette(
          AppColors.coverGreen,
          AppColors.coverGreenAccent,
        );
      case BookStatus.dropped:
        return const _CoverPalette(
          AppColors.coverDeepBlue,
          AppColors.coverDeepBlueAccent,
        );
    }
  }
}

class _CoverPalette {
  const _CoverPalette(this.color, this.accent);

  final Color color;
  final Color accent;
}
