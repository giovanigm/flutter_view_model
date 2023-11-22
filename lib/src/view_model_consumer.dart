import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

class ViewModelConsumer<VM extends ViewModel<STATE, EVENT>, STATE, EVENT>
    extends StatefulWidget {
  const ViewModelConsumer({
    Key? key,
    required this.builder,
    this.viewModel,
    this.onEffect,
    this.buildWhen,
    this.reactToEffectWhen,
  }) : super(key: key);

  final VM? viewModel;

  final Widget Function(BuildContext context, STATE state) builder;

  final void Function(BuildContext context, EVENT effect)? onEffect;

  final bool Function(STATE previous, STATE current)? buildWhen;

  final bool Function(EVENT? previous, EVENT current)? reactToEffectWhen;

  @override
  State<ViewModelConsumer<VM, STATE, EVENT>> createState() =>
      _ViewModelConsumerState<VM, STATE, EVENT>();
}

class _ViewModelConsumerState<VM extends ViewModel<STATE, EVENT>, STATE, EVENT>
    extends State<ViewModelConsumer<VM, STATE, EVENT>> {
  late VM _viewModel;
  StreamSubscription<EVENT>? _effectSubscription;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;
  EVENT? _effect;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _effect = _viewModel.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelConsumer<VM, STATE, EVENT> oldWidget) {
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

    _effectSubscription = _viewModel.effectStream.listen((effect) {
      if (widget.reactToEffectWhen?.call(_effect, effect) ?? true) {
        widget.onEffect?.call(context, effect);
      }
      _effect = effect;
    });
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
