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
    this.onEvent,
    this.buildWhen,
    this.reactToEventWhen,
  }) : super(key: key);

  final VM? viewModel;

  final Widget Function(BuildContext context, STATE state) builder;

  final void Function(BuildContext context, EVENT event)? onEvent;

  final bool Function(STATE previous, STATE current)? buildWhen;

  final bool Function(EVENT previous, EVENT current)? reactToEventWhen;

  @override
  State<ViewModelConsumer<VM, STATE, EVENT>> createState() =>
      _ViewModelConsumerState<VM, STATE, EVENT>();
}

class _ViewModelConsumerState<VM extends ViewModel<STATE, EVENT>, STATE, EVENT>
    extends State<ViewModelConsumer<VM, STATE, EVENT>> {
  late VM _viewModel;
  StreamSubscription<EVENT>? _eventSubscription;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;
  late EVENT _event;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _event = _viewModel.event;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelConsumer<VM, STATE, EVENT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_eventSubscription != null) {
        _viewModel = currentViewModel;
        _state = _viewModel.state;
        _event = _viewModel.event;
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
      if (_eventSubscription != null) {
        _viewModel = viewModel;
        _state = _viewModel.state;
        _event = _viewModel.event;
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

    _eventSubscription = _viewModel.eventStream.listen((event) {
      if (widget.reactToEventWhen?.call(_event, event) ?? _event != event) {
        widget.onEvent?.call(context, event);
      }
      _event = _viewModel.event;
    });
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
