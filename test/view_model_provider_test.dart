import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model/view_model.dart';

class TestViewModel extends ViewModel<int, int> {
  VoidCallback? onClose;
  TestViewModel({this.onClose}) : super(initialState: 0);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  late TestViewModel viewModel;

  setUp(() {
    viewModel = TestViewModel();
  });

  tearDown(() {
    viewModel.close();
  });

  group("ViewModelProvider", () {
    testWidgets("lazily loads ViewModels by default", (tester) async {
      bool isCreated = false;
      await tester.pumpWidget(
        ViewModelProvider(
          create: (_) {
            isCreated = true;
            return viewModel;
          },
          child: const SizedBox(),
        ),
      );
      expect(isCreated, isFalse);
    });

    testWidgets("can override lazy loading", (tester) async {
      bool isCreated = false;
      await tester.pumpWidget(
        ViewModelProvider(
          lazy: false,
          create: (_) {
            isCreated = true;
            return viewModel;
          },
          child: const SizedBox(),
        ),
      );
      expect(isCreated, isTrue);
    });

    testWidgets("provides ViewModel to children", (tester) async {
      const buttonKey = Key("button");
      int? state;
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider(
            lazy: false,
            create: (_) => viewModel,
            child: Builder(builder: (context) {
              return ElevatedButton(
                key: buttonKey,
                onPressed: () {
                  state = ViewModelProvider.of<TestViewModel>(context).state;
                },
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.byKey(buttonKey));
      expect(state, 0);
    });

    testWidgets(
        "should throw FlutterError if ViewModelProvider is not found in current context",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ViewModelProvider.of<TestViewModel>(context);
              return const SizedBox();
            },
          ),
        ),
      );
      final dynamic exception = tester.takeException();
      const expectedMessage = '''
        ViewModelProvider.of() called with a context that does not contain a TestViewModel.
        No ancestor could be found starting from the context that was passed to ViewModelProvider.of<TestViewModel>().

        This can happen if the context you used comes from a widget above the ViewModelProvider.

        The context used was: Builder(dirty)
''';
      expect((exception as FlutterError).message, expectedMessage);
    });

    testWidgets("does not close ViewModel if it was not loaded",
        (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final viewModel = TestViewModel(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider(
            create: (_) => viewModel,
            child: Builder(builder: (context) {
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, false);
      viewModel.close();
    });

    testWidgets("closes ViewModel automatically when invoked", (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final viewModel = TestViewModel(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider(
            create: (_) => viewModel,
            child: Builder(builder: (context) {
              ViewModelProvider.of<TestViewModel>(context);
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, true);
      viewModel.close();
    });

    testWidgets("does not close when created using value", (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final viewModel = TestViewModel(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider.value(
            value: viewModel,
            child: Builder(builder: (context) {
              ViewModelProvider.of<TestViewModel>(context);
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, false);
      viewModel.close();
    });
  });
}
