import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/books/book.dart';

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
            book.coverColor,
            Color.lerp(book.coverColor, Colors.black, .34)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: book.coverColor.withValues(alpha: .22),
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
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: book.coverAccent.withValues(alpha: .22),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            right: 12,
            child: Icon(
              book.coverIcon,
              color: book.coverAccent.withValues(alpha: .74),
              size: 27,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHELF',
                  style: TextStyle(
                    color: book.coverAccent.withValues(alpha: .8),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  book.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 70 ? 10 : 15,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: book.coverAccent.withValues(alpha: .86),
                    fontSize: width < 70 ? 7 : 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
