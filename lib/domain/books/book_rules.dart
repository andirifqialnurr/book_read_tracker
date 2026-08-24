class BookRules {
  const BookRules._();

  static int clampProgressPage(int page, {int? totalPages}) {
    final maxPage = totalPages == null ? 999999 : totalPages.clamp(0, 999999);
    return page.clamp(0, maxPage).toInt();
  }

  static double? progressRatio({required int currentPage, int? totalPages}) {
    if (totalPages == null || totalPages == 0) return null;
    return (currentPage / totalPages).clamp(0, 1).toDouble();
  }
}
