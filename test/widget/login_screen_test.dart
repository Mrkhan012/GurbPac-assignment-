import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/core/network/simulation_manager.dart';
import 'package:gurbpac/data/datasources/mock_data_source_impl.dart';
import 'package:gurbpac/data/repositories/auth_repository_impl.dart';
import 'package:gurbpac/domain/usecases/auth_usecases.dart';
import 'package:gurbpac/presentation/cubits/auth/auth_cubit.dart';
import 'package:gurbpac/presentation/screens/auth/login_screen.dart';
import '../unit/auth_test.dart';

void main() {
  testWidgets('LoginScreen shows form validation errors when fields are empty', (tester) async {
    final fakeStorage = FakeStorageService();
    final simManager = SimulationManager()..delayMilliseconds = 0;
    final dataSource = MockDataSourceImpl(simulationManager: simManager, storageService: fakeStorage);
    final repo = AuthRepositoryImpl(dataSource: dataSource, storageService: fakeStorage);
    final useCases = AuthUseCases(repo);
    final authCubit = AuthCubit(authUseCases: useCases, storageService: fakeStorage);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to TaskFlow'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('LoginScreen accepts typed email and password', (tester) async {
    final fakeStorage = FakeStorageService();
    final simManager = SimulationManager()..delayMilliseconds = 0;
    final dataSource = MockDataSourceImpl(simulationManager: simManager, storageService: fakeStorage);
    final repo = AuthRepositoryImpl(dataSource: dataSource, storageService: fakeStorage);
    final useCases = AuthUseCases(repo);
    final authCubit = AuthCubit(authUseCases: useCases, storageService: fakeStorage);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'ava.admin@nimbusdigital.test');
    await tester.enterText(find.byType(TextFormField).last, 'Password123!');
    await tester.pumpAndSettle();

    expect(find.text('ava.admin@nimbusdigital.test'), findsOneWidget);
    expect(find.text('Password123!'), findsOneWidget);
  });
}
