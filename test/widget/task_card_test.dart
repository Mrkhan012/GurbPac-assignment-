import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/domain/entities/task.dart';
import 'package:gurbpac/domain/entities/user.dart';
import 'package:gurbpac/presentation/widgets/priority_badge.dart';
import 'package:gurbpac/presentation/widgets/status_badge.dart';
import 'package:gurbpac/presentation/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard renders title, status badge, priority badge, and assignee', (tester) async {
    const task = TaskItem(
      id: 'task_001',
      projectId: 'proj_1001',
      title: 'Build navigation bar',
      description: 'Implement responsive header navigation',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      assigneeId: 'user_002',
    );

    const assignee = User(
      id: 'user_002',
      name: 'Marcus Lee',
      email: 'marcus@test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            assignee: assignee,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Build navigation bar'), findsOneWidget);
    expect(find.text('Implement responsive header navigation'), findsOneWidget);
    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.byType(PriorityBadge), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
