import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

class ViewModelConsumer<VM extends ViewModel<STATE, SIDE_EFFECT>, STATE,
    SIDE_EFFECT> extends StatefulWidget {
  const ViewModelConsumer({
    Key? key,
    required this.builder,
    this.viewModel,
    this.onSideEffect,
    this.buildWhen,
    this.reactToSideEffectWhen,
  }) : super(key: key);

  final VM? viewModel;

  final Widget Function(BuildContext context, STATE state) builder;

  final void Function(BuildContext context, SIDE_EFFECT sideEffect)?
      onSideEffect;

  final bool Function(STATE previous, STATE current)? buildWhen;

  final bool Function(SIDE_EFFECT previous, SIDE_EFFECT current)?
      reactToSideEffectWhen;

  @override
  State<ViewModelConsumer<VM, STATE, SIDE_EFFECT>> createState() =>
      _ViewModelConsumerState<VM, STATE, SIDE_EFFECT>();
}

class _ViewModelConsumerState<VM extends ViewModel<STATE, SIDE_EFFECT>, STATE,
    SIDE_EFFECT> extends State<ViewModelConsumer<VM, STATE, SIDE_EFFECT>> {
  late VM _viewModel;
  StreamSubscription<SIDE_EFFECT>? _sideEffectSubscription;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;
  late SIDE_EFFECT _sideEffect;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _sideEffect = _viewModel.sideEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelConsumer<VM, STATE, SIDE_EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_sideEffectSubscription != null) {
        _viewModel = currentViewModel;
        _state = _viewModel.state;
        _sideEffect = _viewModel.sideEffect;
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
      if (_sideEffectSubscription != null) {
        _viewModel = viewModel;
        _state = _viewModel.state;
        _sideEffect = _viewModel.sideEffect;
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

    _sideEffectSubscription = _viewModel.sideEffectStream.listen((sideEffect) {
      if (widget.reactToSideEffectWhen?.call(_sideEffect, sideEffect) ??
          _sideEffect != sideEffect) {
        widget.onSideEffect?.call(context, sideEffect);
      }
      _sideEffect = _viewModel.sideEffect;
    });
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _sideEffectSubscription?.cancel();
    _sideEffectSubscription = null;
  }
}
