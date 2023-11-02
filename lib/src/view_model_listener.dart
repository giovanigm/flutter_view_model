import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

class ViewModelListener<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends StatefulWidget {
  const ViewModelListener({
    Key? key,
    this.viewModel,
    required this.onEvent,
    this.reactToEventWhen,
    required this.child,
  }) : super(key: key);

  final VM? viewModel;

  final void Function(BuildContext context, EVENT event)? onEvent;

  final bool Function(EVENT? previous, EVENT current)? reactToEventWhen;

  final Widget child;

  @override
  State<ViewModelListener<VM, EVENT>> createState() =>
      _ViewModelListenerState<VM, EVENT>();
}

class _ViewModelListenerState<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends State<ViewModelListener<VM, EVENT>> {
  late VM _viewModel;
  StreamSubscription<EVENT>? _eventSubscription;
  EVENT? _event;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _event = _viewModel.lastEvent;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelListener<VM, EVENT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_eventSubscription != null) {
        _viewModel = currentViewModel;
        _event = _viewModel.lastEvent;
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
        _event = _viewModel.lastEvent;
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
    _eventSubscription = _viewModel.eventStream.listen((event) {
      if (widget.reactToEventWhen?.call(_event, event) ?? _event != event) {
        widget.onEvent?.call(context, event);
      }
      _event = event;
    });
  }

  void _unsubscribe() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
