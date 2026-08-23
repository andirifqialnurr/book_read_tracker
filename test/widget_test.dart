import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/app/shelf_app.dart';

void main() {
  testWidgets('Shelf app renders the home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShelfApp()));

    expect(find.text('Currently reading'), findsOneWidget);
    expect(find.text('2026 reading goal'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
