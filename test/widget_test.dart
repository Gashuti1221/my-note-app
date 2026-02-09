import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/main.dart';
import 'package:note_app/services/database_service.dart';
import 'package:mockito/mockito.dart';

// Create a mock DatabaseService
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  testWidgets('NotesListScreen shows FAB, search bar, and empty state', (WidgetTester tester) async {
    final mockDbService = MockDatabaseService();

    // Mock getNotes() to return an empty list
    when(mockDbService.getNotes()).thenAnswer((_) async => []);

    // Build our app with the mock service
    await tester.pumpWidget(MyApp(dbService: mockDbService));

    // Wait for async operations (like fetching notes)
    await tester.pumpAndSettle();

    // Verify the FAB exists
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify search bar exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify empty state message
    expect(find.text("Until now there is no notes/documents"), findsOneWidget);
  });
}
