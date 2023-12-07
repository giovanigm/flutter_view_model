import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

class _TestViewModel extends ViewModel<void, int> {
  _TestViewModel() : super(initialState: null);

  void increment() {
    emitEffect((lastEffect ?? 0) + 1);
  }
}

const _newViewModelKey = Key("new_view_model");
const _sameViewModelKey = Key("same_view_model");
const _incrementKey = Key("increment");

class _TestWidget extends StatefulWidget {
  final VoidCallback? onBuild;
  final void Function(int? previous, int current)? onReactToEffectWhenCalled;

  const _TestWidget({this.onBuild, this.onReactToEffectWhenCalled});

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
          listener: (context, effect) {},
          listenWhen: (previous, current) {
            widget.onReactToEffectWhenCalled?.call(previous, current);
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
          listener: (context, effect) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets("should call listener for every effect", (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
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
        "should call listenWhen with correct previous effect and correct current effect",
        (tester) async {
      int? previousEffect;
      late int currentEffect;

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        listenWhen: (previous, current) {
          previousEffect = previous;
          currentEffect = current;
          return true;
        },
        listener: (context, effect) {},
        child: const Placeholder(),
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

    testWidgets("should call listener if listenWhen returns true",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        listenWhen: (previous, current) => true,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
      ));

      viewModel.emitEffect(1);
      await tester.pump();

      expect(effects, [1]);

      viewModel.emitEffect(2);
      await tester.pump();

      expect(effects, [1, 2]);
    });

    testWidgets("should not call listener if listenWhen returns false",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(ViewModelListener<_TestViewModel, int>(
        viewModel: viewModel,
        listenWhen: (previous, current) => false,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
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
      final List<int> effects = [];

      await tester.pumpWidget(
        ViewModelProvider(
          create: (context) => viewModel,
          child: ViewModelListener<_TestViewModel, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      viewModel.increment();
      await tester.pump();

      expect(effects, [1]);

      viewModel.increment();
      await tester.pump();

      expect(effects, [1, 2]);
    });

    testWidgets(
        "should keep subscription if ViewModel is changed at runtime to the same ViewModel",
        (tester) async {
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_sameViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets(
        "should change subscription if ViewModel is changed at runtime to a different ViewModel",
        (tester) async {
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_newViewModelKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

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
          child: ViewModelListener<_TestViewModel, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      firstViewModel.increment();

      await tester.pumpWidget(
        ViewModelProvider.value(
          value: secondViewModel,
          child: ViewModelListener<_TestViewModel, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      secondViewModel.increment();
      await tester.pump();
      firstViewModel.increment();
      await tester.pump();

      expect(effects, [1, 1]);

      firstViewModel.close();
      secondViewModel.close();
    });
  });
}
