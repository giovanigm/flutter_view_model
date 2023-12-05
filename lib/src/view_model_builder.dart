import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

/// A widget that uses `States` emitted by the [ViewModel] to construct new
/// widgets through the [builder] function.
///
/// If you also need to react to `Effects`, please see [ViewModelConsumer].
///
/// ```dart
/// ViewModelBuilder<MyViewModel, MyState>() {
///   builder: (context, state) {
///     return MyWidget();
///   },
/// }
/// ```
///
/// If [viewModel] is not provided, [ViewModelBuilder] will look up the widget
/// tree using [ViewModelProvider] and the current `BuildContext` for a
/// compatible ViewModel.
///
class ViewModelBuilder<VM extends ViewModel<STATE, dynamic>, STATE>
    extends StatefulWidget {
  const ViewModelBuilder({
    Key? key,
    required this.builder,
    this.viewModel,
    this.buildWhen,
  }) : super(key: key);

  /// The [ViewModel] that [ViewModelBuilder] will react to.
  ///
  /// If [viewModel] is not provided, [ViewModelBuilder] will look up the widget
  /// tree using [ViewModelProvider] and the current `BuildContext` for a
  /// compatible ViewModel.
  final VM? viewModel;

  /// Builds a new widget every time the [viewModel] emits a new [state],
  /// and the [buildWhen] function returns true.
  final Widget Function(BuildContext context, STATE state) builder;

  /// Controls when [builder] should be called by using the [previous] state and
  /// the [current] state.
  ///
  /// The default behavior is to always call [builder] when receiving a new
  /// state from [viewModel].
  final bool Function(STATE previous, STATE current)? buildWhen;

  @override
  State<ViewModelBuilder<VM, STATE>> createState() =>
      _ViewModelBuilderState<VM, STATE>();
}

class _ViewModelBuilderState<VM extends ViewModel<STATE, dynamic>, STATE>
    extends State<ViewModelBuilder<VM, STATE>> {
  late VM _viewModel;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelBuilder<VM, STATE> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_stateSubscription != null) {
        _viewModel = currentViewModel;
        _state = _viewModel.state;
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
      if (_stateSubscription != null) {
        _viewModel = viewModel;
        _state = _viewModel.state;
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
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }
}
