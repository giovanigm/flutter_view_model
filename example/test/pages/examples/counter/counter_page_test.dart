import 'package:example/pages/examples/counter/counter_page.dart';
import 'package:example/pages/examples/counter/counter_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:view_model/view_model.dart';

import 'counter_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CounterPageViewModel>()])
void main() {
  group("Counter Page", () {
    setUp(() {});

    testWidgets("Mock ViewModel", (widgetTester) async {
      final viewModel = MockCounterPageViewModel();

      when(viewModel.state).thenReturn(2);

      await widgetTester.pumpWidget(MaterialApp(
          home: ViewModelProvider<CounterPageViewModel>(
        create: (context) => viewModel,
        child: const CounterPage(),
      )));

      expect(find.text('2'), findsOneWidget);
    });
  });

  group("Counter Page", () {
    late CounterPageViewModel viewModel;

    setUp(() {
      viewModel = CounterPageViewModel();
    });

    tearDown(() {
      viewModel.close();
    });

    testWidgets("Real ViewModel", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ViewModelProvider(
        create: (context) => viewModel,
        child: const CounterPage(),
      )));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });
  });
}
