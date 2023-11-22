import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

class _TestViewModel extends ViewModel<int, int> {
  _TestViewModel() : super(initialState: 0);

  void increment() {
    emitState(state + 1);
    emitEffect((lastEffect ?? 0) + 1);
  }
}

const _newViewModelKey = Key("new_view_model");
const _sameViewModelKey = Key("same_view_model");
const _incrementKey = Key("increment");

class _TestWidget extends StatefulWidget {
  final VoidCallback? onBuild;
  final void Function(int state)? builderCalled;
  final void Function(int previous, int current)? onBuildWhenCalled;
  final void Function(int? previous, int current)? onReactToEffectWhenCalled;

  const _TestWidget({
    this.onBuild,
    this.builderCalled,
    this.onBuildWhenCalled,
    this.onReactToEffectWhenCalled,
  });

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
        body: ViewModelConsumer<_TestViewModel, int, int>(
          viewModel: viewModel,
          onEffect: (context, effect) {},
          reactToEffectWhen: (previous, current) {
            widget.onReactToEffectWhenCalled?.call(previous, current);
            return true;
          },
          buildWhen: (previous, current) {
            widget.onBuildWhenCalled?.call(previous, current);
            return previous != current;
          },
          builder: (context, state) {
            widget.builderCalled?.call(state);
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

  group("ViewModelConsumer", () {
    testWidgets("should build widget returned from builder", (tester) async {
      const targetKey = Key('key');
      await tester.pumpWidget(
        ViewModelConsumer<_TestViewModel, int, int>(
          viewModel: viewModel,
          builder: (context, state) => const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets("should call builder for every state", (tester) async {
      final List<int> states = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        builder: (context, state) {
          states.add(state);
          return const Placeholder();
        },
      ));

      expect(states, [0]);

      viewModel.emitState(1);
      await tester.pump();
      await tester.pump();

      expect(states, [0, 1]);

      viewModel.emitState(2);
      await tester.pump();
      await tester.pump();

      expect(states, [0, 1, 2]);
    });

    testWidgets(
        "should call buildWhen with correct previous effect and correct current effect",
        (tester) async {
      int? previousEffect;
      late int currentEffect;

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        buildWhen: (previous, current) {
          previousEffect = previous;
          currentEffect = current;
          return true;
        },
        builder: (context, state) {
          return const Placeholder();
        },
      ));

      viewModel.emitState(1);
      await tester.pump();
      await tester.pump();

      expect(previousEffect, 0);
      expect(currentEffect, 1);

      viewModel.emitState(2);
      await tester.pump();
      await tester.pump();

      expect(previousEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets("should call builder if buildWhen returns true",
        (tester) async {
      final List<int> states = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        buildWhen: (previous, current) => true,
        builder: (context, state) {
          states.add(state);
          return const Placeholder();
        },
      ));

      expect(states, [0]);

      viewModel.emitState(1);
      await tester.pump();
      await tester.pump();

      expect(states, [0, 1]);

      viewModel.emitState(2);
      await tester.pump();
      await tester.pump();

      expect(states, [0, 1, 2]);
    });

    testWidgets("should not call builder if buildWhen returns false",
        (tester) async {
      final List<int> states = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        buildWhen: (previous, current) => false,
        builder: (context, state) {
          states.add(state);
          return const Placeholder();
        },
      ));

      expect(states, [0]);

      viewModel.emitState(1);
      await tester.pump();
      await tester.pump();

      expect(states, [0]);

      viewModel.emitState(2);
      await tester.pump();
      await tester.pump();

      expect(states, [0]);
    });

    testWidgets("should call onEffect for every effect", (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        onEffect: (context, effect) {
          effects.add(effect);
        },
        builder: (context, state) => const Placeholder(),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      expect(effects, [1]);

      viewModel.emitEffect(1);
      await tester.pump();

      viewModel.emitEffect(2);
      await tester.pump();

      expect(effects, [1, 1, 2]);
    });

    testWidgets(
        "should call reactToEffectWhen with correct previous effect and correct current effect",
        (tester) async {
      int? previousEffect;
      late int currentEffect;

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        reactToEffectWhen: (previous, current) {
          previousEffect = previous;
          currentEffect = current;
          return true;
        },
        onEffect: (context, effect) {},
        builder: (context, state) => const Placeholder(),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      expect(previousEffect, null);
      expect(currentEffect, 1);

      viewModel.emitEffect(2);
      await tester.pump();

      expect(previousEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets("should call onEffect if reactToEffectWhen returns true",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        reactToEffectWhen: (previous, current) => true,
        onEffect: (context, effect) {
          effects.add(effect);
        },
        builder: (context, state) => const Placeholder(),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      expect(effects, [1]);

      viewModel.emitEffect(2);
      await tester.pump();

      expect(effects, [1, 2]);
    });

    testWidgets("should not call onEffect if reactToEffectWhen returns false",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelConsumer<_TestViewModel, int, int>(
        viewModel: viewModel,
        reactToEffectWhen: (previous, current) => false,
        onEffect: (context, effect) {
          effects.add(effect);
        },
        builder: (context, state) => const Placeholder(),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      expect(effects, []);

      viewModel.emitEffect(2);
      await tester.pump();

      expect(effects, []);
    });

    testWidgets("should not trigger builds on effects received",
        (tester) async {
      int builds = 0;
      await tester.pumpWidget(ViewModelProvider(
        create: (context) => viewModel,
        child: _TestWidget(
          onBuild: () {
            builds++;
          },
        ),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      viewModel.emitEffect(2);
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets(
        "should retrieve the ViewModel from the context if it is not provided",
        (tester) async {
      final List<int> states = [];
      final List<int> effects = [];

      await tester.pumpWidget(
        ViewModelProvider(
          create: (context) => viewModel,
          child: ViewModelConsumer<_TestViewModel, int, int>(
            onEffect: (context, effect) => effects.add(effect),
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

      expect(effects, [1]);
      expect(states, [0, 1]);

      viewModel.increment();
      await tester.pump();
      await tester.pump();

      expect(effects, [1, 2]);
      expect(states, [0, 1, 2]);
    });

    testWidgets(
        "should keep subscription if ViewModel is changed at runtime to the same ViewModel",
        (tester) async {
      int? lastState;
      late int currentState;
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        builderCalled: (state) {},
        onBuildWhenCalled: (previous, current) {
          lastState = previous;
          currentState = current;
        },
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastState, 0);
      expect(currentState, 1);
      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_sameViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastState, 1);
      expect(currentState, 2);
      expect(lastEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets(
        "should change subscription if ViewModel is changed at runtime to a different ViewModel",
        (tester) async {
      int? lastState;
      late int currentState;
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        onBuildWhenCalled: (previous, current) {
          lastState = previous;
          currentState = current;
        },
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastState, 0);
      expect(currentState, 1);
      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_newViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastState, 0);
      expect(currentState, 1);
      expect(lastEffect, null);
      expect(currentEffect, 1);
    });

    testWidgets("should update subscription when provided ViewModel is changed",
        (tester) async {
      final firstViewModel = _TestViewModel();
      final secondViewModel = _TestViewModel();

      final List<int> effects = [];

      await tester.pumpWidget(
        ViewModelProvider.value(
          value: firstViewModel,
          child: ViewModelConsumer<_TestViewModel, int, int>(
            onEffect: (context, effect) => effects.add(effect),
            builder: (context, state) => const SizedBox(),
          ),
        ),
      );

      firstViewModel.increment();
      await tester.pump();
      await tester.pump();

      await tester.pumpWidget(
        ViewModelProvider.value(
          value: secondViewModel,
          child: ViewModelConsumer<_TestViewModel, int, int>(
            onEffect: (context, effect) => effects.add(effect),
            builder: (context, state) => const SizedBox(),
          ),
        ),
      );

      secondViewModel.increment();
      await tester.pump();
      await tester.pump();

      firstViewModel.increment();
      await tester.pump();
      await tester.pump();

      expect(effects, [1, 1]);

      firstViewModel.close();
      secondViewModel.close();
    });
  });
}
