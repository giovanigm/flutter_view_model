import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:view_model/view_model.dart';

import 'counter_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CounterViewModel>()])
void main() {
  group("Mock ViewModel", () {
    setUp(() {});

    testWidgets("", (widgetTester) async {
      final CounterViewModel viewModel = MockCounterViewModel();

      when(viewModel.state).thenReturn(2);

      await widgetTester.pumpWidget(MaterialApp(
          home: ViewModelProvider(
        create: (context) => viewModel,
        child: const CounterPage(),
      )));

      expect(find.text('2'), findsOneWidget);
    });
  });

  group("Real ViewModel", () {
    late CounterViewModel viewModel;

    setUp(() {
      viewModel = CounterViewModel();
    });

    tearDown(() {
      viewModel.close();
    });

    testWidgets("", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ViewModelProvider(
        create: (context) => viewModel,
        child: const CounterPage(),
      )));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Odd'), findsOneWidget);

      // Wait for SnackBar to dismiss
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Even'), findsOneWidget);
    });
  });
}