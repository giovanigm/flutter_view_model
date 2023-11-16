import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

class _TestViewModel extends ViewModel<void, int> {
  _TestViewModel() : super(initialState: null);

  void increment() {
    emitEvent((lastEvent ?? 0) + 1);
  }
}

const _newViewModelKey = Key("new_view_model");
const _sameViewModelKey = Key("same_view_model");
const _incrementKey = Key("increment");

class _TestWidget extends StatefulWidget {
  final VoidCallback? onBuild;
  final void Function(int? previous, int current)? onReactToEventWhenCalled;

  const _TestWidget({this.onBuild, this.onReactToEventWhenCalled});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  late _TestViewModel viewModel;

  @override
  void initState() {
    viewModel = _TestViewModel();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild?.call();
    return MaterialApp(
      home: Scaffold(
        body: ViewModelListener<_TestViewModel, int>(
          viewModel: viewModel,
          onEvent: (context, event) {},
          reactToEventWhen: (previous, current) {
            widget.onReactToEventWhenCalled?.call(previous, current);
            return true;
          },
          child: Column(
            children: [
              ElevatedButton(
                key: _newViewModelKey,
                onPressed: () {
                  setState(() {
                    viewModel = _TestViewModel();
                  });
                },
                child: const SizedBox(),
              ),
              ElevatedButton(
                key: _sameViewModelKey,
                onPressed: () {
                  setState(() => viewModel = viewModel);
                },
                child: const SizedBox(),
              ),
              ElevatedButton(
                key: _incrementKey,
                onPressed: () {
                  viewModel.increment();
                },
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  late _TestViewModel viewModel;

  setUp(() {
    viewModel = _TestViewModel();
  });

  tearDown(() {
    viewModel.close();
  });

  group("ViewModelListener", () {
    testWidgets("should render child", (tester) async {
      const targetKey = Key('key');
      await tester.pumpWidget(
        ViewModelListener<_TestViewModel, int>(
          viewModel: viewModel,
          onEvent: (context, event) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets("should call onEvent for every event", (tester) async {
      final List<int> events = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        onEvent: (context, event) {
          events.add(event);
        },
        child: const Placeholder(),
      ));

      viewModel.emitEvent(1);
      await tester.pump();

      expect(events, [1]);

      viewModel.emitEvent(2);
      await tester.pump();

      expect(events, [1, 2]);
    });

    testWidgets(
        "should call reactToEventWhen with correct previous event and correct current event",
        (tester) async {
      int? previousEvent;
      late int currentEvent;

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        reactToEventWhen: (previous, current) {
          previousEvent = previous;
          currentEvent = current;
          return true;
        },
        onEvent: (context, event) {},
        child: const Placeholder(),
      ));

      viewModel.emitEvent(1);
      await tester.pump();

      expect(previousEvent, null);
      expect(currentEvent, 1);

      viewModel.emitEvent(2);
      await tester.pump();

      expect(previousEvent, 1);
      expect(currentEvent, 2);
    });

    testWidgets("should call onEvent if reactToEventWhen returns true",
        (tester) async {
      final List<int> events = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        reactToEventWhen: (previous, current) => true,
        onEvent: (context, event) {
          events.add(event);
        },
        child: const Placeholder(),
      ));

      viewModel.emitEvent(1);
      await tester.pump();

      expect(events, [1]);

      viewModel.emitEvent(2);
      await tester.pump();

      expect(events, [1, 2]);
    });

    testWidgets("should not call onEvent if reactToEventWhen returns false",
        (tester) async {
      final List<int> events = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        reactToEventWhen: (previous, current) => false,
        onEvent: (context, event) {
          events.add(event);
        },
        child: const Placeholder(),
      ));

      viewModel.emitEvent(1);
      await tester.pump();

      expect(events, []);

      viewModel.emitEvent(2);
      await tester.pump();

      expect(events, []);
    });

    testWidgets("should not trigger builds on events received", (tester) async {
      int builds = 0;
      await tester.pumpWidget(ViewModelProvider(
        create: (context) => viewModel,
        child: _TestWidget(
          onBuild: () {
            builds++;
          },
        ),
      ));

      viewModel.emitEvent(1);
      await tester.pump();

      viewModel.emitEvent(2);
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets(
        "should retrieve the ViewModel from the context if it is not provided",
        (tester) async {
      final List<int> events = [];

      await tester.pumpWidget(
        ViewModelProvider(
          create: (context) => viewModel,
          child: ViewModelListener<_TestViewModel, int>(
            onEvent: (context, event) => events.add(event),
            child: const SizedBox(),
          ),
        ),
      );

      viewModel.increment();
      await tester.pump();

      expect(events, [1]);

      viewModel.increment();
      await tester.pump();

      expect(events, [1, 2]);
    });

    testWidgets(
        "should keep subscription if ViewModel is changed at runtime to the same ViewModel",
        (tester) async {
      int? lastEvent;
      late int currentEvent;
      await tester.pumpWidget(_TestWidget(
        onReactToEventWhenCalled: (previous, current) {
          lastEvent = previous;
          currentEvent = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEvent, null);
      expect(currentEvent, 1);

      await tester.tap(find.byKey(_sameViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEvent, 1);
      expect(currentEvent, 2);
    });

    testWidgets(
        "should change subscription if ViewModel is changed at runtime to a different ViewModel",
        (tester) async {
      int? lastEvent;
      late int currentEvent;
      await tester.pumpWidget(_TestWidget(
        onReactToEventWhenCalled: (previous, current) {
          lastEvent = previous;
          currentEvent = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEvent, null);
      expect(currentEvent, 1);

      await tester.tap(find.byKey(_newViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEvent, null);
      expect(currentEvent, 1);
    });

    testWidgets("should update subscription when provided ViewModel is changed",
        (tester) async {
      final firstViewModel = _TestViewModel();
      final secondViewModel = _TestViewModel();

      final List<int> events = [];

      await tester.pumpWidget(
        ViewModelProvider.value(
          value: firstViewModel,
          child: ViewModelListener<_TestViewModel, int>(
            onEvent: (context, event) => events.add(event),
            child: const SizedBox(),
          ),
        ),
      );

      firstViewModel.increment();

      await tester.pumpWidget(
        ViewModelProvider.value(
          value: secondViewModel,
          child: ViewModelListener<_TestViewModel, int>(
            onEvent: (context, event) => events.add(event),
            child: const SizedBox(),
          ),
        ),
      );

      secondViewModel.increment();
      await tester.pump();
      firstViewModel.increment();
      await tester.pump();

      expect(events, [1, 1]);

      firstViewModel.close();
      secondViewModel.close();
    });
  });
}
