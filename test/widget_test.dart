import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/domain/entities/project.dart';
import 'package:gurbpac/presentation/widgets/project_card.dart';

void main() {
  testWidgets('ProjectCard widget test', (WidgetTester tester) async {
    final project = Project(
      id: 'proj_01',
      orgId: 'org_01',
      name: 'Mobile App Project',
      description: 'Second major release',
      taskCount: 5,
      status: 'active',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCard(
            project: project,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Mobile App Project'), findsOneWidget);
    expect(find.text('Second major release'), findsOneWidget);
    expect(find.text('5 Tasks'), findsOneWidget);
  });
}
