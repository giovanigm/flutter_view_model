import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

/// A widget that uses both `States` and `Effects` emitted by the [ViewModel] to
/// construct new widgets and react to effects.
///
/// If you need to react only either to `States` or `Effects`, see
/// [ViewModelBuilder] and [ViewModelListener].
///
/// ```dart
/// ViewModelConsumer<MyViewModel, MyState, MyEffect>() {
///   listener: (context, effect) {
///     // do something
///   },
///   builder: (context, state) {
///     return MyWidget();
///   },
/// }
/// ```
///
/// If [viewModel] is not provided, [ViewModelConsumer] will look up the widget
/// tree using [ViewModelProvider] and the current `BuildContext` for a
/// compatible ViewModel.
///
class ViewModelConsumer<VM extends ViewModel<STATE, EFFECT>, STATE, EFFECT>
    extends StatefulWidget {
  const ViewModelConsumer({
    Key? key,
    required this.builder,
    this.viewModel,
    this.listener,
    this.buildWhen,
    this.listenWhen,
  }) : super(key: key);

  /// The [ViewModel] that [ViewModelConsumer] will react to.
  ///
  /// If [viewModel] is not provided, [ViewModelConsumer] will look up the
  /// widget tree using [ViewModelProvider] and the current `BuildContext` for a
  /// compatible ViewModel.
  final VM? viewModel;

  /// Builds a new widget every time the [viewModel] emits a new [state],
  /// and the [buildWhen] function returns true.
  final Widget Function(BuildContext context, STATE state) builder;

  /// Is invoked every time the [viewModel] emits a new [effect],
  /// and the [listenWhen] function returns true.
  final void Function(BuildContext context, EFFECT effect)? listener;

  /// Controls when [builder] should be called by using the [previous] state and
  /// the [current] state.
  ///
  /// The default behavior is to always call [builder] when receiving a new
  /// state from [viewModel].
  final bool Function(STATE previous, STATE current)? buildWhen;

  /// Controls when [listener] should be called by using the [previous] effect
  /// and the [current] state.
  ///
  /// The default behavior is to always call [listener] when receiving a new
  /// effect from [viewModel].
  final bool Function(EFFECT? previous, EFFECT current)? listenWhen;

  @override
  State<ViewModelConsumer<VM, STATE, EFFECT>> createState() =>
      _ViewModelConsumerState<VM, STATE, EFFECT>();
}

class _ViewModelConsumerState<VM extends ViewModel<STATE, EFFECT>, STATE,
    EFFECT> extends State<ViewModelConsumer<VM, STATE, EFFECT>> {
  late VM _viewModel;
  StreamSubscription<EFFECT>? _effectSubscription;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;
  EFFECT? _effect;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _effect = _viewModel.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelConsumer<VM, STATE, EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_stateSubscription != null && _effectSubscription != null) {
        _viewModel = currentViewModel;
        _state = _viewModel.state;
        _effect = _viewModel.lastEffect;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = widget.viewModel ?? context.read<VM>();
    if (_viewModel != viewModel) {
      if (_stateSubscription != null && _effectSubscription != null) {
        _viewModel = viewModel;
        _state = _viewModel.state;
        _effect = _viewModel.lastEffect;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel == null) {
      context.select<VM, bool>((viewModel) => identical(_viewModel, viewModel));
    }

    return widget.builder(context, _state);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _stateSubscription = _viewModel.stateStream.listen((state) {
      if (widget.buildWhen?.call(_state, state) ?? true) {
        setState(() {});
      }
      _state = state;
    });

    final listener = widget.listener;
    if (listener != null) {
      _effectSubscription = _viewModel.effectStream.listen((effect) {
        if (widget.listenWhen?.call(_effect, effect) ?? true) {
          listener(context, effect);
        }
        _effect = effect;
      });
    }
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
