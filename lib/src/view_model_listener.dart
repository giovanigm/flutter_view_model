import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

/// A Widget that reacts to `Effects` emitted by [ViewModel] and invokes
/// [listener] callback.
///
/// It should be used when you only need to deal with side effects such as
/// navigating after some validation, displaying feedback SnackBars, and similar
/// cases.
///
/// If you also need to react to `States`, please see [ViewModelConsumer].
///
/// ```dart
/// ViewModelListener<MyViewModel, MyEffect>() {
///   listener: (context, effect) {
///     // do something
///   },
///   child: const SizedBox(),
/// }
/// ```
///
/// If [viewModel] is not provided, [ViewModelListener] will look up the widget
/// tree using [ViewModelProvider] and the current `BuildContext` for a
/// compatible ViewModel.
///
class ViewModelListener<VM extends ViewModel<dynamic, EFFECT>, EFFECT>
    extends StatefulWidget {
  const ViewModelListener({
    Key? key,
    this.viewModel,
    required this.listener,
    this.listenWhen,
    required this.child,
  }) : super(key: key);

  /// The [ViewModel] that [ViewModelListener] will listen to.
  ///
  /// If [viewModel] is not provided, [ViewModelListener] will look up the
  /// widget tree using [ViewModelProvider] and the current `BuildContext` for a
  /// compatible ViewModel.
  final VM? viewModel;

  /// Is invoked every time the [viewModel] emits a new [effect],
  /// and the [listenWhen] function returns true.
  final void Function(BuildContext context, EFFECT effect) listener;

  /// Controls when [listener] should be called by using the [previous] effect
  /// and the [current] state.
  ///
  /// The default behavior is to always call [listener] when receiving a new
  /// effect from [viewModel].
  final bool Function(EFFECT? previous, EFFECT current)? listenWhen;

  /// The Widget to be rendered.
  final Widget child;

  @override
  State<ViewModelListener<VM, EFFECT>> createState() =>
      _ViewModelListenerState<VM, EFFECT>();
}

class _ViewModelListenerState<VM extends ViewModel<dynamic, EFFECT>, EFFECT>
    extends State<ViewModelListener<VM, EFFECT>> {
  late VM _viewModel;
  StreamSubscription<EFFECT>? _effectSubscription;
  EFFECT? _effect;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _effect = _viewModel.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelListener<VM, EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_effectSubscription != null) {
        _viewModel = currentViewModel;
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
      if (_effectSubscription != null) {
        _viewModel = viewModel;
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

    return widget.child;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _effectSubscription = _viewModel.effectStream.listen((effect) {
      if (widget.listenWhen?.call(_effect, effect) ?? true) {
        widget.listener.call(context, effect);
      }
      _effect = effect;
    });
  }

  void _unsubscribe() {
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
