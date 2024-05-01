import 'package:flutter_test/flutter_test.dart';
import 'package:notes/models/noteModel.dart';
import 'package:flutter/material.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:notes/screens/signIn.dart';
import 'package:provider/provider.dart';

void main() async {
  test('Validate email & password', () {
    // Test case 1: Valid email and password
    expect(
      () => validateEmailAndPassword(
          email: 'example@example.com', password: 'password123'),
      returnsNormally,
    );

    // Test case 2: Empty email
    expect(
      () => validateEmailAndPassword(email: '', password: 'password123'),
      throwsA('Email cannot be empty'),
    );

    // Test case 3: Invalid email format
    expect(
      () => validateEmailAndPassword(
        email: 'invalidemail',
        password: 'password123',
      ),
      throwsA('Invalid email format'),
    );

    // Test case 4: Empty password
    expect(
      () =>
          validateEmailAndPassword(email: 'example@example.com', password: ''),
      throwsA('Password cannot be empty'),
    );

    // Test case 5: Password less than 6 characters
    expect(
      () => validateEmailAndPassword(
          email: 'example@example.com', password: '123'),
      throwsA('Password must be at least 6 characters'),
    );
  });

  testWidgets('Test Cloud Provider State Change', (WidgetTester tester) async {
    // Arrange
    // Provide CloudProvider to the Placeholder widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: CloudProvider(),
          child: const Material(
            child: Placeholder(),
          ),
        ),
      ),
    );

    // Ensure the widget is built
    await tester.pump();

    // Get the context within the widget tree
    final BuildContext context = tester.element(find.byType(Placeholder));
    final cloudProvider = Provider.of<CloudProvider>(context, listen: false);

    expect(cloudProvider.isSync, false);

    cloudProvider.setIsSync(true);

    expect(cloudProvider.isSync, true);
  });

  test('Test toMap method', () {
    // Arrange
    final note = Note(
      id: 1,
      title: 'Test Note',
      note: 'This is a test note',
      email: 'test@example.com',
      filePath: '/path/to/file',
      reminderDateTime: DateTime(2024, 5, 1, 10, 0),
      createAt: DateTime(2024, 4, 30, 18, 0),
      editAt: DateTime(2024, 5, 1, 8, 0),
    );

    // Act
    final map = note.toMap();

    // Assert
    expect(map['id'], 1);
    expect(map['title'], 'Test Note');
    expect(map['note'], 'This is a test note');
    expect(map['email'], 'test@example.com');
    expect(map['filePath'], '/path/to/file');
    expect(map['reminderDateTime'], '2024-05-01T10:00:00.000');
    expect(map['createAt'], '2024-04-30T18:00:00.000');
    expect(map['editAt'], '2024-05-01T08:00:00.000');
  });
}
