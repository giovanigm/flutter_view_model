import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model/view_model.dart';

class _TestViewModel extends ViewModel<int, void> {
  _TestViewModel() : super(initialState: 0);

  void increment() {
    emitState(state + 1);
  }
}

const _newViewModelKey = Key("new_view_model");
const _sameViewModelKey = Key("same_view_model");
const _incrementKey = Key("increment");

class _TestWidget extends StatefulWidget {
  final void Function(int state)? onBuild;
  final void Function(int previous, int current)? onBuildWhenCalled;

  const _TestWidget({this.onBuild, this.onBuildWhenCalled});

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
    return MaterialApp(
      home: Scaffold(
        body: ViewModelBuilder<_TestViewModel, int>(
          viewModel: viewModel,
          buildWhen: (previous, current) {
            widget.onBuildWhenCalled?.call(previous, current);
            return previous != current;
          },
          builder: (context, state) {
            widget.onBuild?.call(state);
            return Column(
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
            );
          },
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

  testWidgets(
      "should retrieve the ViewModel from the context if it is not provided",
      (tester) async {
    final List<int> states = [];

    await tester.pumpWidget(
      ViewModelProvider.value(
        value: viewModel,
        child: ViewModelBuilder<_TestViewModel, int>(
          builder: (context, state) {
            states.add(state);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(states, [0]);

    viewModel.increment();
    await tester.pump();
    await tester.pump();

    expect(states, [0, 1]);
  });

  testWidgets(
      "should keep subscription if ViewModel is changed at runtime to the same ViewModel",
      (tester) async {
    int? lastState;
    late int currentState;
    await tester.pumpWidget(_TestWidget(
      onBuild: (state) {},
      onBuildWhenCalled: (previous, current) {
        lastState = previous;
        currentState = current;
      },
    ));

    await tester.tap(find.byKey(_incrementKey));
    await tester.pump();

    expect(lastState, 0);
    expect(currentState, 1);

    await tester.tap(find.byKey(_sameViewModelKey));

    await tester.tap(find.byKey(_incrementKey));
    await tester.pump();

    expect(lastState, 1);
    expect(currentState, 2);
  });

  testWidgets(
      "should change subscription if ViewModel is changed at runtime to a different ViewModel",
      (tester) async {
    int? lastState;
    late int currentState;
    await tester.pumpWidget(_TestWidget(
      onBuildWhenCalled: (previous, current) {
        lastState = previous;
        currentState = current;
      },
    ));

    await tester.tap(find.byKey(_incrementKey));
    await tester.pump();

    expect(lastState, 0);
    expect(currentState, 1);

    await tester.tap(find.byKey(_newViewModelKey));

    await tester.tap(find.byKey(_incrementKey));
    await tester.pump();

    expect(lastState, 0);
    expect(currentState, 1);
  });

  testWidgets("should update subscription when provided ViewModel is changed",
      (tester) async {
    final firstViewModel = _TestViewModel();
    final secondViewModel = _TestViewModel();

    final List<int> states = [];

    await tester.pumpWidget(
      ViewModelProvider.value(
        value: firstViewModel,
        child: ViewModelBuilder<_TestViewModel, int>(
          builder: (context, state) {
            states.add(state);
            return const SizedBox();
          },
        ),
      ),
    );

    firstViewModel.increment();
    await tester.pump();
    await tester.pump();

    await tester.pumpWidget(
      ViewModelProvider.value(
        value: secondViewModel,
        child: ViewModelBuilder<_TestViewModel, int>(
          builder: (context, state) {
            states.add(state);
            return const SizedBox();
          },
        ),
      ),
    );

    secondViewModel.increment();
    await tester.pump();
    await tester.pump();

    firstViewModel.increment();
    await tester.pump();
    await tester.pump();

    expect(states, [0, 1, 0, 1]);

    firstViewModel.close();
    secondViewModel.close();
  });
}
