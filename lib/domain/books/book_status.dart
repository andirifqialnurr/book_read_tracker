import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum BookStatus { wantToRead, reading, finished, dropped }

extension BookStatusCopy on BookStatus {
  String get label {
    switch (this) {
      case BookStatus.wantToRead:
        return 'Want to read';
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.finished:
        return 'Finished';
      case BookStatus.dropped:
        return 'Dropped';
    }
  }

  Color color(Brightness brightness) {
    switch (this) {
      case BookStatus.wantToRead:
        return brightness == Brightness.light
            ? AppColors.wantToReadLight
            : AppColors.wantToReadDark;
      case BookStatus.reading:
        return brightness == Brightness.light
            ? AppColors.readingLight
            : AppColors.readingDark;
      case BookStatus.finished:
        return brightness == Brightness.light
            ? AppColors.finishedLight
            : AppColors.finishedDark;
      case BookStatus.dropped:
        return brightness == Brightness.light
            ? AppColors.droppedLight
            : AppColors.droppedDark;
    }
  }
}
